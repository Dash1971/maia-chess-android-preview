@file:Suppress("UNUSED_PARAMETER")
package android.content
import android.net.Uri
import java.io.ByteArrayInputStream
class Intent(val action: String = "") {
    companion object {
        const val ACTION_OPEN_DOCUMENT = "open"
        const val CATEGORY_OPENABLE = "openable"
        const val FLAG_GRANT_READ_URI_PERMISSION = 1
        const val FLAG_GRANT_WRITE_URI_PERMISSION = 2
    }
    var data: Uri? = null
    var type: String? = null
    var clipData: ClipData? = null
    fun putExtra(key: String, value: Any) {}
    fun addFlags(flags: Int) {}
    fun addCategory(category: String) {}
}
class ClipData {
    companion object { fun newRawUri(label: String, uri: Uri) = ClipData() }
}
class ContentResolver {
    fun openInputStream(uri: Uri) = ByteArrayInputStream(byteArrayOf(1, 2, 3))
}
