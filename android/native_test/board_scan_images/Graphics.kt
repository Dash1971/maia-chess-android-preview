@file:Suppress("UNUSED_PARAMETER")
package android.graphics
import java.io.OutputStream
object ScanFaults {
    @Volatile var hook: (String) -> Unit = {}
    @Volatile var decoded: Bitmap? = null
    fun hit(stage: String) = hook(stage)
}
class Bitmap(val width: Int = 64, val height: Int = 64) {
    enum class Config { ARGB_8888 }
    enum class CompressFormat { JPEG }
    var recycled = false
    fun recycle() { recycled = true }
    fun compress(format: CompressFormat, quality: Int, output: OutputStream): Boolean {
        ScanFaults.hit("preview"); output.write(1); return true
    }
    fun getPixels(pixels: IntArray, offset: Int, stride: Int, x: Int, y: Int, w: Int, h: Int) {
        ScanFaults.hit("pixels")
    }
    companion object {
        fun createScaledBitmap(bitmap: Bitmap, width: Int, height: Int, filter: Boolean): Bitmap {
            ScanFaults.hit("thumbnail"); return Bitmap(width, height)
        }
        fun createBitmap(bitmap: Bitmap, x: Int, y: Int, w: Int, h: Int, matrix: Matrix, filter: Boolean): Bitmap {
            ScanFaults.hit("transform"); return Bitmap(w, h)
        }
    }
}
object BitmapFactory {
    class Options {
        var inJustDecodeBounds = false
        var outWidth = 64
        var outHeight = 64
        var inSampleSize = 1
        var inPreferredConfig = Bitmap.Config.ARGB_8888
    }
    fun decodeFile(path: String, options: Options): Bitmap? {
        if (options.inJustDecodeBounds) return null
        ScanFaults.hit("decode")
        return Bitmap().also { ScanFaults.decoded = it }
    }
}
class Matrix {
    init { ScanFaults.hit("matrix") }
    var isIdentity = true
    fun setScale(x: Float, y: Float) { isIdentity = false }
    fun setRotate(degrees: Float) { isIdentity = false }
    fun postScale(x: Float, y: Float) { isIdentity = false }
}
