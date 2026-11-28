@file:Suppress("UNUSED_PARAMETER")
package com.dash1971.maia_chess
import android.graphics.ScanFaults
// The adapter test substitutes inference, not image-ownership/failure handling.
// Real geometry and model inference have separate BoardScanCoreTest coverage.
object BoardScanCore {
    class Image(val width: Int, val height: Int, val pixels: IntArray)
    class Reading(val placement: String)
    fun scan(image: Image, finder: ByteArray, reader: ByteArray): Reading {
        ScanFaults.hit("inference")
        return Reading("6r1/3k4/8/3KP3/8/8/7R/8")
    }
}
