package com.dash1971.maia_chess

import android.app.Activity
import android.content.Intent
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.util.concurrent.Executors

/** Explicit, streaming export. No network/storage permission or arbitrary source path. */
class SamplingDocuments(private val activity: Activity) {
    private val io = Executors.newSingleThreadExecutor()
    private var pending: MethodChannel.Result? = null
    private val snapshot = File(activity.cacheDir, "sampling-export.jsonl")
    private var closed = false

    fun save(reply: MethodChannel.Result) {
        if (pending != null || closed) {
            reply.error("sampling_busy", "Sampling export unavailable", null)
            return
        }
        pending = reply
        io.execute {
            try {
                val source = File(activity.filesDir, "sampling-data/export.jsonl")
                if (source.length() > 70L * 1024 * 1024) throw IOException("Export exceeds limit")
                source.inputStream().use { input -> snapshot.outputStream().use { input.copyTo(it) } }
                activity.runOnUiThread {
                    if (closed) return@runOnUiThread
                    try {
                        activity.startActivityForResult(Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                            addCategory(Intent.CATEGORY_OPENABLE)
                            type = "application/x-ndjson"
                            putExtra(Intent.EXTRA_TITLE, "mobile-maia-sampling.jsonl")
                        }, 2201)
                    } catch (_: Exception) { finish(false) }
                }
            } catch (_: Exception) { activity.runOnUiThread { finish(false) } }
        }
    }

    fun onResult(request: Int, code: Int, intent: Intent?): Boolean {
        if (request != 2201) return false
        if (pending == null) return true
        val uri = intent?.data
        if (code != Activity.RESULT_OK || uri == null) { finish(null); return true }
        io.execute {
            val success = try {
                if (uri.scheme != "content") throw IOException("Expected document URI")
                activity.contentResolver.openOutputStream(uri, "wt")?.use { output ->
                    snapshot.inputStream().use { it.copyTo(output) }
                    output.flush()
                } ?: throw IOException("Could not open document")
                true
            } catch (_: Exception) { false }
            activity.runOnUiThread { finish(success) }
        }
        return true
    }

    private fun finish(success: Boolean?) {
        val reply = pending
        pending = null
        snapshot.delete()
        if (success == false) reply?.error("sampling_export_failed", "Could not export sampling data", null)
        else reply?.success(success)
    }

    fun close() {
        closed = true
        pending?.error("sampling_closed", "Activity closed during export", null)
        pending = null
        io.execute { snapshot.delete() }
        io.shutdown()
    }
}
