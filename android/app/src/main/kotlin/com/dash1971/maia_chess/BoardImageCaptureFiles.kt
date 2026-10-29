package com.dash1971.maia_chess

import java.io.File

/** App-private, single-use camera output. Never touch gallery or unrelated cache files. */
internal class BoardImageCaptureFiles(private val folder: File) {
    fun owned(): List<File> = folder.listFiles()?.filter {
        it.name.startsWith("capture-") && it.name.endsWith(".jpg") && !it.isDirectory
    } ?: emptyList()

    fun create(): File {
        check(folder.isDirectory || folder.mkdirs())
        check(owned().all { discard(it) })
        return File.createTempFile("capture-", ".jpg", folder)
    }

    fun discard(file: File): Boolean {
        require(file.parentFile.canonicalFile == folder.canonicalFile)
        require(file.name.startsWith("capture-") && file.name.endsWith(".jpg"))
        return !file.exists() || file.delete()
    }
}

/** EXIF's eight orientations: rotate first, then mirror horizontally if needed. */
internal data class BoardImageOrientation(val degrees: Float, val mirrorX: Boolean) {
    companion object {
        fun fromExif(value: Int): BoardImageOrientation = when (value) {
            2 -> BoardImageOrientation(0f, true)
            3 -> BoardImageOrientation(180f, false)
            4 -> BoardImageOrientation(180f, true)
            5 -> BoardImageOrientation(90f, true)
            6 -> BoardImageOrientation(90f, false)
            7 -> BoardImageOrientation(270f, true)
            8 -> BoardImageOrientation(270f, false)
            else -> BoardImageOrientation(0f, false)
        }
    }
}
