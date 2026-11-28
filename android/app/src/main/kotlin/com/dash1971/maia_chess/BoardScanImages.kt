package com.dash1971.maia_chess

import android.app.Activity
import android.content.ClipData
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import android.net.Uri
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.security.MessageDigest
import java.util.UUID
import java.util.concurrent.Executors

/** Temporary scoped image grants, external camera, bounded decode and local inference.
 * No camera/storage permission, gallery insertion, image logging or network requests.
 */
class BoardScanImages(private val activity: Activity, restoredCapture: String?) {
    companion object {
        private const val CAMERA = 2301
        private const val PICK = 2302
        private const val MAX_BYTES = 16 * 1024 * 1024
        private const val MAX_SIDE = 1600
        private const val FINDER_SHA = "92df98ca72bf8c9c67196a134188b3cc005681d35262724172ba61f705625f4f"
        private const val READER_SHA = "bf07e26ed1f7cd27ee5b75049b5c8fd261b157de89b026e968e779355c16ef80"
    }
    private val io = Executors.newSingleThreadExecutor()
    private val directory = File(activity.cacheDir, "board-scan").apply { mkdirs() }
    @Volatile private var closed = false
    private var picker: MethodChannel.Result? = null
    private var preparing = false
    private var cameraFile: File? = restoredCapture?.let { File(directory, it) }
        ?.takeIf { it.parentFile == directory && it.name.matches(Regex("[a-f0-9-]+\\.jpg")) }
    @Volatile private var current: File? = null
    @Volatile private var reading = false

    init { directory.listFiles()?.filter { it != cameraFile }?.forEach { it.delete() } }
    fun saveState(): String? = cameraFile?.name

    fun pick(camera: Boolean, reply: MethodChannel.Result) {
        if (closed || picker != null || preparing || reading || current != null) {
            reply.error("scan_busy", "Scanner is busy", null); return
        }
        val intent: Intent
        if (camera) {
            val file = File(directory, "${UUID.randomUUID()}.jpg")
            cameraFile = file
            val uri = uri(file)
            intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE).apply {
                putExtra(MediaStore.EXTRA_OUTPUT, uri)
                putExtra(MediaStore.EXTRA_SIZE_LIMIT, MAX_BYTES.toLong())
                clipData = ClipData.newRawUri("board photo", uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            }
        } else intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            type = "image/*"; addCategory(Intent.CATEGORY_OPENABLE)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        picker = reply
        try { activity.startActivityForResult(intent, if (camera) CAMERA else PICK) }
        catch (_: Exception) {
            picker = null; clearCapture(); reply.error("scan_picker_unavailable", "Image source unavailable", null)
        }
    }

    fun onResult(request: Int, code: Int, data: Intent?): Boolean {
        if (request != CAMERA && request != PICK) return false
        val reply = picker; picker = null
        val capture = cameraFile
        if (reply == null || closed || code != Activity.RESULT_OK || (request == PICK && data?.data == null)) {
            clearCapture(); reply?.success(null); return true
        }
        // The camera grant is not needed after the activity has returned.
        capture?.let { revoke(it) }; cameraFile = null
        preparing = true
        io.execute {
            var target: File? = null
            BoardScanWork.run(work = {
                val file = if (request == CAMERA) requireNotNull(capture) else {
                    val file = File(directory, "${UUID.randomUUID()}.jpg")
                    target = file
                    activity.contentResolver.openInputStream(requireNotNull(data?.data)).use { input ->
                        requireNotNull(input) { "scan_read_failed" }
                        file.outputStream().use { output ->
                            val buffer = ByteArray(32768); var bytes = 0
                            while (true) {
                                val n = input.read(buffer); if (n < 0) break
                                bytes += n; require(bytes <= MAX_BYTES) { "scan_too_large" }
                                output.write(buffer, 0, n)
                            }
                        }
                    }
                    file
                }
                target = file
                require(file.length() in 1..MAX_BYTES.toLong()) { "scan_too_large" }
                val bitmap = decode(file)
                val preview = try {
                    val thumb = Bitmap.createScaledBitmap(bitmap,
                        maxOf(1, bitmap.width * 240 / maxOf(bitmap.width, bitmap.height)),
                        maxOf(1, bitmap.height * 240 / maxOf(bitmap.width, bitmap.height)), true)
                    try { ByteArrayOutputStream().use { out -> thumb.compress(Bitmap.CompressFormat.JPEG, 80, out); out.toByteArray() } }
                    finally { if (thumb !== bitmap) thumb.recycle() }
                } finally { bitmap.recycle() }
                Pair(file, preview)
            }, release = { failure ->
                if (failure != null) { target?.delete(); capture?.delete() }
            }, complete = { prepared, failure ->
                activity.runOnUiThread {
                    preparing = false
                    if (failure != null) reply.error(BoardScanWork.errorCode(failure), "Could not read image", null)
                    else {
                        val (file, preview) = requireNotNull(prepared)
                        if (closed) { file.delete(); reply.success(null) }
                        else { current = file; reply.success(mapOf("token" to file.name, "preview" to preview)) }
                    }
                }
            })
        }
        return true
    }

    fun recognize(token: String?, reply: MethodChannel.Result) {
        val file = current
        if (closed || reading || file == null || token != file.name) {
            reply.error("scan_stale", "Image is no longer available", null); return
        }
        reading = true
        io.execute {
            BoardScanWork.run(work = {
                val image = decode(file)
                val rgb = try {
                    val pixels = IntArray(image.width * image.height)
                    image.getPixels(pixels, 0, image.width, 0, 0, image.width, image.height)
                    BoardScanCore.Image(image.width, image.height, pixels)
                } finally { image.recycle() }
                val result = BoardScanCore.scan(rgb,
                    model("boardfinder-v1-int8.onnx", 1428260, FINDER_SHA),
                    model("boardnet-v4-int8.onnx", 2030978, READER_SHA))
                result.placement
            }, release = {
                try { file.delete() }
                finally { if (current == file) current = null; reading = false }
            }, complete = { placement, failure ->
                // Finalize ownership before replying: immediate retry must not see
                // the previous job as busy or delete the next job's file.
                activity.runOnUiThread {
                    if (closed) reply.error("scan_stale", "Scanner closed", null)
                    else if (failure != null) reply.error(BoardScanWork.errorCode(failure), "Could not read board", null)
                    else reply.success(mapOf("placement" to placement))
                }
            })
        }
    }
    fun discard(token: String?) {
        val file = current ?: return
        if (token != file.name || reading) return
        file.delete(); current = null
    }
    fun close() {
        closed = true; clearCapture(); picker?.success(null); picker = null
        if (!reading) { current?.delete(); current = null }
        io.shutdown() // In-flight inference releases its sessions and image in finally.
    }
    private fun uri(file: File): Uri = FileProvider.getUriForFile(activity, "${activity.packageName}.files", file)
    private fun revoke(file: File) { activity.revokeUriPermission(uri(file),
        Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION) }
    private fun clearCapture() { cameraFile?.let { revoke(it); it.delete() }; cameraFile = null }
    private fun model(name: String, size: Int, hash: String): ByteArray {
        val bytes = activity.assets.open("flutter_assets/assets/board_scanner/$name").use { it.readBytes() }
        require(bytes.size == size && MessageDigest.getInstance("SHA-256").digest(bytes)
            .joinToString("") { "%02x".format(it) } == hash) { "scan_model_invalid" }
        return bytes
    }
    private fun decode(file: File): Bitmap {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(file.path, bounds)
        require(bounds.outWidth in 1..32768 && bounds.outHeight in 1..32768) { "scan_read_failed" }
        var sample = 1
        while ((maxOf(bounds.outWidth, bounds.outHeight) + sample - 1) / sample > MAX_SIDE) sample *= 2
        val bitmap = requireNotNull(BitmapFactory.decodeFile(file.path, BitmapFactory.Options().apply {
            inSampleSize = sample; inPreferredConfig = Bitmap.Config.ARGB_8888
        })) { "scan_read_failed" }
        try {
            // Some older Android ExifInterface versions do not support PNG/WebP.
            // A successfully decoded screenshot does not need EXIF to be usable.
            val orientation = try {
                ExifInterface(file.path).getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)
            } catch (_: java.io.IOException) { ExifInterface.ORIENTATION_NORMAL }
            val matrix = Matrix()
            when (orientation) {
                ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.setScale(-1f, 1f)
                ExifInterface.ORIENTATION_ROTATE_180 -> matrix.setRotate(180f)
                ExifInterface.ORIENTATION_FLIP_VERTICAL -> matrix.setScale(1f, -1f)
                ExifInterface.ORIENTATION_TRANSPOSE -> { matrix.setRotate(90f); matrix.postScale(-1f, 1f) }
                ExifInterface.ORIENTATION_ROTATE_90 -> matrix.setRotate(90f)
                ExifInterface.ORIENTATION_TRANSVERSE -> { matrix.setRotate(270f); matrix.postScale(-1f, 1f) }
                ExifInterface.ORIENTATION_ROTATE_270 -> matrix.setRotate(270f)
            }
            if (matrix.isIdentity) return bitmap
            val transformed = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
            if (transformed !== bitmap) bitmap.recycle()
            return transformed
        } catch (error: Throwable) {
            bitmap.recycle()
            throw error
        }
    }
}
