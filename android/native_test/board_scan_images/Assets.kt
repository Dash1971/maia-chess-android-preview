@file:Suppress("UNUSED_PARAMETER")
package android.content.res
import java.io.File
class AssetManager(private val root: File) {
    fun open(name: String) = File(root, name.removePrefix("flutter_assets/")).inputStream()
}
