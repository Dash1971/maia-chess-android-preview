@file:Suppress("UNUSED_PARAMETER")
package android.media
import android.graphics.ScanFaults
class ExifInterface(path: String) {
    init { ScanFaults.hit("exif") }
    fun getAttributeInt(tag: String, default: Int) = orientation
    companion object {
        var orientation = 1
        const val TAG_ORIENTATION = "orientation"
        const val ORIENTATION_NORMAL = 1
        const val ORIENTATION_FLIP_HORIZONTAL = 2
        const val ORIENTATION_ROTATE_180 = 3
        const val ORIENTATION_FLIP_VERTICAL = 4
        const val ORIENTATION_TRANSPOSE = 5
        const val ORIENTATION_ROTATE_90 = 6
        const val ORIENTATION_TRANSVERSE = 7
        const val ORIENTATION_ROTATE_270 = 8
    }
}
