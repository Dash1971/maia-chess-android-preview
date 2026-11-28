package com.dash1971.maia_chess

import java.io.File
import javax.imageio.ImageIO
import kotlin.math.abs

/** JVM checks run the production core without an Android build. */
fun main(args: Array<String>) {
    var checks = 0
    fun verify(ok: Boolean, label: String) { check(ok) { label }; checks++ }
    fun rejected(label: String, block: () -> Unit) {
        var failed = false
        try { block() } catch (_: IllegalArgumentException) { failed = true }
        verify(failed, label)
    }
    verify(BoardScanCore.placement(IntArray(64)) == "8/8/8/8/8/8/8/8", "empty FEN")
    val grid = IntArray(64); grid[0] = 10; grid[63] = 6
    verify(BoardScanCore.placement(grid) == "r7/8/8/8/8/8/8/7K", "class order and final gap")
    rejected("bad class") { BoardScanCore.placement(IntArray(64) { 13 }) }
    rejected("bad grid dimensions") { BoardScanCore.placement(IntArray(63)) }
    for (turn in 0..3) {
        val expected = listOf(listOf(0, 1, 2, 3), listOf(1, 3, 0, 2),
                              listOf(3, 2, 1, 0), listOf(2, 0, 3, 1))[turn]
        verify((0..3).map { BoardScanCore.rotatedIndex(it / 2, it % 2, turn, 2) } == expected, "rotation $turn")
    }
    fun logits(white: Float): BoardScanCore.Reading {
        val squares = FloatArray(4 * 13 * 64) { -20f }
        val rotations = FloatArray(16) { -20f }
        for (batch in 0..3) {
            for (i in 0 until 64) {
                val original = BoardScanCore.rotatedIndex(i / 8, i % 8, batch, 8)
                squares[batch * 13 * 64 + grid[original] * 64 + i] = 20f
            }
            rotations[batch * 4 + ((4 - batch) % 4)] = 20f
        }
        return BoardScanCore.decode(squares, rotations, FloatArray(4) { white }, emptyList())
    }
    val upright = logits(20f)
    verify(upright.placement == BoardScanCore.placement(grid), "four-reader square alignment")
    verify(upright.turns == 0 && upright.whiteAtBottom, "four-reader rotation alignment")
    verify(upright.confidence.all { it > .99 }, "confidence normalization")
    verify(logits(-20f).placement == BoardScanCore.placement(grid.reversedArray()), "Black-bottom inversion")
    rejected("NaN model output") { BoardScanCore.decode(FloatArray(3328) { Float.NaN }, FloatArray(16), FloatArray(4), emptyList()) }
    val image = BoardScanCore.Image(100, 100, IntArray(10000))
    val corners = listOf(BoardScanCore.Point(0.0, 0.0), BoardScanCore.Point(99.0, 0.0),
        BoardScanCore.Point(99.0, 99.0), BoardScanCore.Point(0.0, 99.0))
    BoardScanCore.validateCorners(corners, image); checks++
    rejected("crossed corners") { BoardScanCore.validateCorners(listOf(corners[0], corners[2], corners[1], corners[3]), image) }
    rejected("non-finite corner") { BoardScanCore.validateCorners(corners.map { BoardScanCore.Point(Double.NaN, it.y) }, image) }
    rejected("degenerate board") { BoardScanCore.validateCorners(List(4) { corners[0] }, image) }

    if (args.size == 2) {
        val models = File(args[0]); val fixtures = File(args[1])
        val finder = File(models, "boardfinder-v1-int8.onnx").readBytes()
        val reader = File(models, "boardnet-v4-int8.onnx").readBytes()
        val expected = "8/1k6/4n2p/4P2P/N2P4/3R3P/3N4/2KR4"
        for ((name, fen, turn) in listOf(Triple("screenshot.png", expected, 0),
            Triple("book-photo.png", expected, 0),
            Triple("book-photo-sideways.png", "r3k3/2p1p1Br/pp6/3n1P1p/P4n2/5N1P/R2K2B1/4R3", 3))) {
            val png = ImageIO.read(File(fixtures, name))
            val pixels = png.getRGB(0, 0, png.width, png.height, null, 0, png.width)
            val result = BoardScanCore.scan(BoardScanCore.Image(png.width, png.height, pixels), finder, reader)
            println("$name: ${result.placement}, turns=${result.turns}, White-bottom=${result.whiteAtBottom}, corners=${result.corners}")
            verify(result.placement == fen, "$name exact-board result")
            verify(result.turns == turn && result.whiteAtBottom, "$name orientation")
            val expectedCorners = when(name) {
                "screenshot.png" -> listOf(12.6,85.5,237.8,84.5,237.5,310.5,12.4,310.8)
                "book-photo.png" -> listOf(411.4,389.5,713.1,399.5,704.8,697.1,399.6,690.7)
                else -> listOf(395.7,172.5,812.0,188.1,804.7,617.9,399.7,619.7)
            }
            verify(result.corners.flatMap { listOf(it.x, it.y) }.zip(expectedCorners).all { abs(it.first - it.second) <= 2 }, "$name corners within two pixels")
        }
        rejected("blank image does not become a game") {
            BoardScanCore.scan(BoardScanCore.Image(256, 256, IntArray(65536) { 0xffffff }), finder, reader)
        }
    }
    println("$checks BoardScanCore checks passed")
}
