@file:Suppress("UNUSED_PARAMETER")
package com.dash1971.maia_chess
import android.app.Activity
import android.content.Intent
import android.content.res.AssetManager
import android.graphics.ScanFaults
import android.media.ExifInterface
import android.net.Uri
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

private class Reply : MethodChannel.Result {
    val done = CountDownLatch(1)
    var value: Any? = null
    var error: String? = null
    var count = 0
    override fun success(result: Any?) { value = result; count++; done.countDown() }
    override fun error(code: String, message: String?, details: Any?) { error = code; count++; done.countDown() }
    override fun notImplemented() { error("Unexpected method") }
    fun await(): Reply { check(done.await(10, TimeUnit.SECONDS)) { "MethodChannel never replied" }; check(count == 1); return this }
}

fun main(args: Array<String>) {
    val cache = File(args[0], "image-adapter-cache").apply { mkdirs() }
    val assets = File(args[1])
    var checks = 0
    fun token(images: BoardScanImages): String {
        val reply = Reply()
        images.pick(false, reply)
        check(images.onResult(2302, Activity.RESULT_OK, Intent().apply { data = Uri("selected") }))
        reply.await()
        check(reply.error == null) { "Retry failed: ${reply.error}" }
        return (reply.value as Map<*, *>)["token"] as String
    }
    for (stage in listOf("decode", "exif", "matrix", "transform", "thumbnail", "preview", "pixels", "inference")) {
        for (failure in listOf(OutOfMemoryError("allocation"), UnsatisfiedLinkError("native"))) {
            val images = BoardScanImages(Activity(cache, AssetManager(assets)), null)
            try {
                val recognition = stage in listOf("pixels", "inference")
                ExifInterface.orientation = if (stage == "transform") 3 else 1
                val existing = if (recognition) token(images) else null
                ScanFaults.hook = { if (it == stage) throw failure }
                val reply = Reply()
                if (recognition) images.recognize(existing, reply)
                else {
                    images.pick(false, reply)
                    images.onResult(2302, Activity.RESULT_OK, Intent().apply { data = Uri("selected") })
                }
                reply.await()
                check(reply.error == "scan_read_failed") { "$stage did not return an error" }
                check(File(cache, "board-scan").listFiles()!!.isEmpty()) { "$stage leaked image ownership" }
                if (stage !in listOf("decode", "inference")) check(ScanFaults.decoded!!.recycled) { "$stage leaked decoded bitmap" }
                ScanFaults.hook = {}
                ExifInterface.orientation = 1
                val next = token(images)
                val retried = Reply()
                images.recognize(next, retried)
                retried.await()
                check(retried.error == null && (retried.value as Map<*, *>)["placement"] == "6r1/3k4/8/3KP3/8/8/7R/8")
                check(File(cache, "board-scan").listFiles()!!.isEmpty())
                checks++
            } finally { ScanFaults.hook = {}; images.close() }
        }
    }
    // Restored activity has no Dart picker callback: discard its stale capture.
    val directory = File(cache, "board-scan")
    val stale = File(directory, "abcdef-123.jpg").apply { writeText("old camera photo") }
    val restored = BoardScanImages(Activity(cache, AssetManager(assets)), stale.name)
    try {
        check(restored.onResult(2301, Activity.RESULT_OK, null))
        check(!stale.exists())
        val next = token(restored)
        restored.discard(next)
        check(directory.listFiles()!!.isEmpty())
        checks++
    } finally { restored.close() }
    println("$checks production BoardScanImages failure/retry/lifecycle checks passed (JVM platform doubles; no Android build)")
}
