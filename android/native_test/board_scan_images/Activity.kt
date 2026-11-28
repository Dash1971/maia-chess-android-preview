@file:Suppress("UNUSED_PARAMETER")
package android.app
import android.content.Intent
import android.content.ContentResolver
import android.content.res.AssetManager
import android.net.Uri
import java.io.File
class Activity(val cacheDir: File, val assets: AssetManager) {
    companion object { const val RESULT_OK = -1 }
    val contentResolver = ContentResolver()
    val packageName = "test.mobile.maia"
    fun runOnUiThread(action: Runnable) = action.run()
    fun startActivityForResult(intent: Intent, request: Int) {}
    fun revokeUriPermission(uri: Uri, flags: Int) {}
}
