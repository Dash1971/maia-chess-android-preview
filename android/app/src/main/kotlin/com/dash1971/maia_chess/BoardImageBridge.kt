package com.dash1971.maia_chess

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import ai.onnxruntime.OnnxTensor
import ai.onnxruntime.OrtEnvironment
import ai.onnxruntime.OrtSession
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.nio.FloatBuffer
import java.security.MessageDigest
import java.util.concurrent.Executors

/** Scoped image grants only. No image/model copies, URIs or positions enter logs. */
internal class BoardImageBridge(private val activity: Activity, private val channel: MethodChannel) {
    companion object {
        const val REQUEST_IMAGE = 17901
        const val MODEL_BYTES = 835_655
        const val MODEL_SHA256 = "2408717e2e0e2ed438e2f9f89f85c2e544326cef34a0c91b95168bd17336df47"
        private const val MAX_ENCODED_BYTES = 16 * 1024 * 1024
        private const val MAX_SIDE = 1536
    }

    private val executor = Executors.newSingleThreadExecutor()
    private var pending: MethodChannel.Result? = null
    private var waitingForPicker = false
    @Volatile private var closed = false

    init { channel.setMethodCallHandler(::handle) }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        if (call.method !in setOf("pickImage", "classifySquares")) {
            result.notImplemented(); return
        }
        if (BuildConfig.FLAVOR !in setOf("preview", "dev") || closed || pending != null) {
            result.error("image_busy", "Image import is unavailable.", null); return
        }
        pending = result
        if (call.method == "pickImage") {
            waitingForPicker = true
            try {
                if (Build.VERSION.SDK_INT >= 33) {
                    try {
                        activity.startActivityForResult(Intent("android.provider.action.PICK_IMAGES").apply {
                            type = "image/*"
                        }, REQUEST_IMAGE)
                        return
                    } catch (_: ActivityNotFoundException) { /* Google-free SAF fallback. */ }
                }
                activity.startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "image/*"
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }, REQUEST_IMAGE)
            } catch (_: Exception) { fail("image_picker_unavailable") }
        } else {
            val input = call.argument<FloatArray>("input")
            if (input == null || input.size != 64 * 32 * 32 || input.any { !it.isFinite() || it < 0f || it > 1f }) {
                fail("invalid_image_input"); return
            }
            work { classify(input) }
        }
    }

    fun onResult(request: Int, result: Int, data: Intent?): Boolean {
        if (request != REQUEST_IMAGE) return false
        if (closed || pending == null || !waitingForPicker) return true
        waitingForPicker = false
        val uri = data?.data
        if (result != Activity.RESULT_OK || uri == null) finish(null)
        else work { decode(uri) }
        return true
    }

    private fun work(block: () -> Any) {
        executor.execute {
            try {
                val value = block()
                activity.runOnUiThread { if (!closed) finish(value) }
            } catch (_: OutOfMemoryError) {
                activity.runOnUiThread { if (!closed) fail("image_resources") }
            } catch (_: Exception) {
                activity.runOnUiThread { if (!closed) fail("image_import_failed") }
            }
        }
    }

    private fun decode(uri: Uri): ByteArray {
        require(uri.scheme == "content")
        require(activity.contentResolver.getType(uri)?.startsWith("image/") == true)
        val bytes = activity.contentResolver.openInputStream(uri)!!.use { input ->
            val out = ByteArrayOutputStream()
            val buffer = ByteArray(32 * 1024)
            while (true) {
                check(!closed && !Thread.currentThread().isInterrupted)
                val n = input.read(buffer)
                if (n < 0) break
                require(out.size() + n <= MAX_ENCODED_BYTES)
                out.write(buffer, 0, n)
            }
            out.toByteArray()
        }
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeByteArray(bytes, 0, bytes.size, bounds)
        require(bounds.outWidth in 64..20_000 && bounds.outHeight in 64..20_000)
        require(bounds.outWidth.toLong() * bounds.outHeight <= 100_000_000L)
        var sample = 1
        while (maxOf(bounds.outWidth, bounds.outHeight) / sample > MAX_SIDE) sample *= 2
        val options = BitmapFactory.Options().apply {
            inSampleSize = sample
            inPreferredConfig = Bitmap.Config.ARGB_8888
        }
        val bitmap = requireNotNull(BitmapFactory.decodeByteArray(bytes, 0, bytes.size, options))
        try {
            require(bitmap.width <= MAX_SIDE && bitmap.height <= MAX_SIDE)
            return ByteArrayOutputStream().use { out ->
                check(bitmap.compress(Bitmap.CompressFormat.PNG, 100, out))
                require(out.size() <= MAX_ENCODED_BYTES)
                out.toByteArray()
            }
        } finally { bitmap.recycle() }
    }

    private fun classify(input: FloatArray): FloatArray {
        val bytes = activity.assets.open("flutter_assets/assets/models/board_squares.onnx").use {
            val data = it.readBytes()
            require(data.size == MODEL_BYTES)
            val hash = MessageDigest.getInstance("SHA-256").digest(data).joinToString("") { b -> "%02x".format(b) }
            require(hash == MODEL_SHA256)
            data
        }
        check(!closed)
        val environment = OrtEnvironment.getEnvironment()
        return OrtSession.SessionOptions().use { options ->
            options.setIntraOpNumThreads(2)
            options.setInterOpNumThreads(1)
            options.setExecutionMode(OrtSession.SessionOptions.ExecutionMode.SEQUENTIAL)
            environment.createSession(bytes, options).use { session ->
                OnnxTensor.createTensor(environment, FloatBuffer.wrap(input), longArrayOf(64, 1, 32, 32)).use { tensor ->
                    session.run(mapOf("input" to tensor)).use { outputs ->
                        @Suppress("UNCHECKED_CAST")
                        val rows = outputs.get("logits").get().value as Array<FloatArray>
                        require(rows.size == 64 && rows.all { it.size == 13 && it.all { value -> value.isFinite() } })
                        FloatArray(64 * 13) { rows[it / 13][it % 13] }
                    }
                }
            }
        }
    }

    private fun finish(value: Any?) { val reply = pending; pending = null; reply?.success(value) }
    private fun fail(code: String) { waitingForPicker = false; val reply = pending; pending = null; reply?.error(code, "Image import is unavailable.", null) }

    fun close() {
        if (closed) return
        closed = true
        channel.setMethodCallHandler(null)
        fail("image_cancelled")
        executor.shutdownNow()
    }
}
