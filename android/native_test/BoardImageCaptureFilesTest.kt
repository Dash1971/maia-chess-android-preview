package com.dash1971.maia_chess

import java.io.File
import java.nio.file.Files
import kotlin.math.abs
import kotlin.math.cos
import kotlin.math.sin

fun boardImageCaptureChecks() {
    val root = Files.createTempDirectory("maia-camera").toFile()
    try {
        val folder = File(root, "camera")
        val files = BoardImageCaptureFiles(folder)
        check(files.owned().isEmpty())
        val first = files.create().apply { writeText("private camera bytes") }
        val unrelated = File(folder, "notes.jpg").apply { writeText("unrelated") }
        val outside = File(root, "capture-outside.jpg").apply { writeText("preserve") }
        check(files.owned() == listOf(first))
        val second = files.create()
        check(!first.exists() && second.exists() && second != first)
        check(unrelated.readText() == "unrelated")
        check(runCatching { files.discard(outside) }.isFailure && outside.exists())
        check(runCatching { files.discard(unrelated) }.isFailure && unrelated.exists())
        check(files.discard(second) && files.discard(second))
        val interrupted = files.create().apply { writeText("process-death orphan") }
        val recreated = BoardImageCaptureFiles(folder)
        recreated.owned().forEach { check(recreated.discard(it)) }
        check(!interrupted.exists() && unrelated.exists() && outside.exists())
        val link = File(folder, "capture-link.jpg")
        Files.createSymbolicLink(link.toPath(), outside.toPath())
        recreated.owned().forEach { check(recreated.discard(it)) }
        check(!Files.exists(link.toPath()) && outside.readText() == "preserve")
    } finally { root.deleteRecursively() }

    val expected = listOf(.25 to .75, -.25 to .75, -.25 to -.75, .25 to -.75,
        .75 to .25, -.75 to .25, -.75 to -.25, .75 to -.25)
    for (tag in 1..8) {
        val o = BoardImageOrientation.fromExif(tag)
        val radians = Math.toRadians(o.degrees.toDouble())
        val x = (.25 * cos(radians) - .75 * sin(radians)) * if (o.mirrorX) -1 else 1
        val y = .25 * sin(radians) + .75 * cos(radians)
        check(abs(x - expected[tag - 1].first) < .000001)
        check(abs(y - expected[tag - 1].second) < .000001)
    }
    check(BoardImageOrientation.fromExif(-1) == BoardImageOrientation.fromExif(1))
    check(BoardImageOrientation.fromExif(99) == BoardImageOrientation.fromExif(1))
    println("Camera private-cache isolation, cancellation/recreation cleanup and all EXIF orientations passed")
}
