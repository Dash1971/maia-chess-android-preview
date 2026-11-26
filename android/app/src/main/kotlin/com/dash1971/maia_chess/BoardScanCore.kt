package com.dash1971.maia_chess

import ai.onnxruntime.OnnxTensor
import ai.onnxruntime.OrtEnvironment
import ai.onnxruntime.OrtSession
import java.nio.FloatBuffer
import kotlin.math.*

/** Open Board Scanner port, AGPL-3.0-only. Upstream dee0475d, pipeline.py/geometry.py.
 * No Android dependencies: the production pipeline also runs in the JVM fixture checks.
 * RGB inputs are 0..255, NOT normalized; the normalization is inside both graphs.
 */
object BoardScanCore {
    const val SIZE = 256
    private const val SYMBOLS = " PNBRQKpnbrqk"
    data class Image(val width: Int, val height: Int, val rgb: IntArray) {
        init { require(width > 0 && height > 0 && rgb.size == width * height) }
    }
    data class Point(val x: Double, val y: Double)
    data class Reading(val placement: String, val turns: Int, val whiteAtBottom: Boolean,
                       val corners: List<Point>, val confidence: FloatArray)

    fun scan(image: Image, finder: ByteArray, reader: ByteArray): Reading {
        // The finder can confidently hallucinate a quadrilateral on a blank page.
        // Reject near-uniform inputs before they can become an editable reading.
        var low = 255; var high = 0
        for (i in image.rgb.indices step max(1, image.rgb.size / 16384)) {
            val p = image.rgb[i]
            val luminance = (((p shr 16) and 255) * 77 + ((p shr 8) and 255) * 150 + (p and 255) * 29) / 256
            low = min(low, luminance); high = max(high, luminance)
        }
        require(high - low >= 12) { "no_board" }
        val env = OrtEnvironment.getEnvironment()
        return OrtSession.SessionOptions().use { options ->
            options.setIntraOpNumThreads(2)
            options.setInterOpNumThreads(1)
            env.createSession(finder, options).use { find ->
                env.createSession(reader, options).use { read -> scan(image, env, find, read) }
            }
        }
    }

    private fun scan(image: Image, env: OrtEnvironment, finder: OrtSession, reader: OrtSession): Reading {
        var cx = (image.width - 1) / 2.0
        var cy = (image.height - 1) / 2.0
        var side = max(image.width, image.height) * 1.12
        var corners = emptyList<Point>()
        repeat(2) {
            val view = window(image, cx, cy, side)
            OnnxTensor.createTensor(env, FloatBuffer.wrap(chw(view)), longArrayOf(1, 3, 256, 256)).use { input ->
                finder.run(mapOf("image" to input)).use { output ->
                    val present = floats(output.get("present").get())[0]
                    require(present.isFinite() && present > 0f) { "no_board" }
                    val values = floats(output.get("corners").get())
                    require(values.size == 8 && values.all { it.isFinite() }) { "no_board" }
                    corners = (0..3).map { i ->
                        Point(cx + (values[i * 2] - .5) * side,
                              cy + (values[i * 2 + 1] - .5) * side)
                    }
                }
            }
            validateCorners(corners, image)
            val left = corners.minOf { it.x }; val right = corners.maxOf { it.x }
            val top = corners.minOf { it.y }; val bottom = corners.maxOf { it.y }
            cx = (left + right) / 2; cy = (top + bottom) / 2
            side = max(max(right - left, bottom - top), 8.0) * 1.35
        }
        val crop = rectify(image, corners)
        val batch = FloatArray(4 * 3 * SIZE * SIZE)
        for (turn in 0..3) chw(rotate(crop, turn)).copyInto(batch, turn * 3 * SIZE * SIZE)
        OnnxTensor.createTensor(env, FloatBuffer.wrap(batch), longArrayOf(4, 3, 256, 256)).use { input ->
            reader.run(mapOf("image" to input)).use { output ->
                return decode(floats(output.get("squares").get()), floats(output.get("rotation").get()),
                              floats(output.get("white_at_bottom").get()), corners)
            }
        }
    }

    private fun floats(value: ai.onnxruntime.OnnxValue): FloatArray {
        val buffer = (value as OnnxTensor).floatBuffer
        return FloatArray(buffer.remaining()).also { buffer.get(it) }
    }

    fun validateCorners(corners: List<Point>, image: Image) {
        require(corners.size == 4) { "no_board" }
        val limit = max(image.width, image.height).toDouble()
        require(corners.all { it.x.isFinite() && it.y.isFinite() &&
            it.x in -limit..image.width + limit && it.y in -limit..image.height + limit }) { "no_board" }
        val crosses = (0..3).map { i ->
            val a = corners[i]; val b = corners[(i + 1) % 4]; val c = corners[(i + 2) % 4]
            (b.x - a.x) * (c.y - b.y) - (b.y - a.y) * (c.x - b.x)
        }
        require(crosses.all { it > 1.0 }) { "no_board" }
        val area = abs((0..3).sumOf { i -> corners[i].x * corners[(i + 1) % 4].y -
            corners[(i + 1) % 4].x * corners[i].y }) / 2
        require(area >= 64) { "no_board" }
    }

    private fun chw(image: Image): FloatArray {
        val n = image.width * image.height
        return FloatArray(n * 3).also { values -> image.rgb.forEachIndexed { i, c ->
            values[i] = ((c shr 16) and 255).toFloat()
            values[n + i] = ((c shr 8) and 255).toFloat()
            values[n * 2 + i] = (c and 255).toFloat()
        } }
    }

    private fun window(source: Image, cx: Double, cy: Double, side: Double): Image {
        val scale = SIZE / side
        var image = source
        var shrink = 1.0
        if (scale < .6) { shrink = scale * 1.25; image = resizeArea(source, shrink) }
        return Image(SIZE, SIZE, IntArray(SIZE * SIZE) { i ->
            val x = cx + (i % SIZE - (SIZE - 1) / 2.0) / scale
            val y = cy + (i / SIZE - (SIZE - 1) / 2.0) / scale
            sample(image, (x + .5) * shrink - .5, (y + .5) * shrink - .5, false)
        })
    }

    private fun resizeArea(image: Image, scale: Double): Image {
        val w = max(1, (image.width * scale).roundToInt())
        val h = max(1, (image.height * scale).roundToInt())
        val out = IntArray(w * h)
        for (y in 0 until h) for (x in 0 until w) {
            val x0 = x / scale; val x1 = min(image.width.toDouble(), (x + 1) / scale)
            val y0 = y / scale; val y1 = min(image.height.toDouble(), (y + 1) / scale)
            val sum = DoubleArray(3); var weight = 0.0
            for (sy in floor(y0).toInt() until ceil(y1).toInt())
                for (sx in floor(x0).toInt() until ceil(x1).toInt()) {
                    if (sx !in 0 until image.width || sy !in 0 until image.height) continue
                    val a = (min(x1, sx + 1.0) - max(x0, sx.toDouble())) *
                            (min(y1, sy + 1.0) - max(y0, sy.toDouble()))
                    val pixel = image.rgb[sy * image.width + sx]
                    for (c in 0..2) sum[c] += ((pixel shr (16 - c * 8)) and 255) * a
                    weight += a
                }
            out[y * w + x] = pack(DoubleArray(3) { if (weight > 0) sum[it] / weight else 0.0 })
        }
        return Image(w, h, out)
    }

    private fun sample(image: Image, x: Double, y: Double, replicate: Boolean): Int {
        val ix = floor(x).toInt(); val iy = floor(y).toInt()
        // OpenCV's INTER_LINEAR table uses 1/32-pixel steps.
        val fx = ((x - ix) * 32).roundToInt() / 32.0
        val fy = ((y - iy) * 32).roundToInt() / 32.0
        val sum = DoubleArray(3)
        for (dy in 0..1) for (dx in 0..1) {
            var sx = ix + dx; var sy = iy + dy
            if (replicate) { sx = sx.coerceIn(0, image.width - 1); sy = sy.coerceIn(0, image.height - 1) }
            if (sx !in 0 until image.width || sy !in 0 until image.height) continue
            val p = image.rgb[sy * image.width + sx]
            val a = (if (dx == 0) 1 - fx else fx) * (if (dy == 0) 1 - fy else fy)
            for (c in 0..2) sum[c] += ((p shr (16 - c * 8)) and 255) * a
        }
        return pack(sum)
    }
    private fun pack(channels: DoubleArray): Int = channels.fold(0) { out, c ->
        (out shl 8) or c.roundToInt().coerceIn(0, 255)
    }

    private fun blur(image: Image, sigma: Double): Image {
        val radius = ceil(sigma * 3).toInt().coerceIn(1, 48)
        val kernel = DoubleArray(radius * 2 + 1) { exp(-((it - radius).toDouble().pow(2)) / (2 * sigma * sigma)) }
        val total = kernel.sum(); for (i in kernel.indices) kernel[i] /= total
        val horizontal = FloatArray(image.rgb.size * 3)
        fun reflect(v: Int, size: Int): Int {
            if (size == 1) return 0
            var n = v
            while (n < 0 || n >= size) n = if (n < 0) -n else size * 2 - n - 2
            return n
        }
        for (y in 0 until image.height) for (x in 0 until image.width) {
            for (k in -radius..radius) {
                val p = image.rgb[y * image.width + reflect(x + k, image.width)]
                for (c in 0..2) horizontal[(y * image.width + x) * 3 + c] +=
                    (((p shr (16 - c * 8)) and 255) * kernel[k + radius]).toFloat()
            }
        }
        return Image(image.width, image.height, IntArray(image.rgb.size) { i ->
            val x = i % image.width; val y = i / image.width
            pack(DoubleArray(3) { c -> (-radius..radius).sumOf { k ->
                horizontal[(reflect(y + k, image.height) * image.width + x) * 3 + c] * kernel[k + radius]
            } })
        })
    }

    private fun rectify(source: Image, corners: List<Point>): Image {
        val edge = hypot(corners[1].x - corners[0].x, corners[1].y - corners[0].y)
        val image = if (edge > SIZE * 1.5) blur(source, edge / SIZE * .5) else source
        val target = listOf(Point(-.5, -.5), Point(SIZE - .5, -.5),
                            Point(SIZE - .5, SIZE - .5), Point(-.5, SIZE - .5))
        val m = Array(8) { DoubleArray(9) }
        for (i in 0..3) {
            val x = target[i].x; val y = target[i].y; val u = corners[i].x; val v = corners[i].y
            m[i * 2] = doubleArrayOf(x, y, 1.0, 0.0, 0.0, 0.0, -u * x, -u * y, u)
            m[i * 2 + 1] = doubleArrayOf(0.0, 0.0, 0.0, x, y, 1.0, -v * x, -v * y, v)
        }
        for (col in 0..7) {
            val pivot = (col..7).maxBy { abs(m[it][col]) }; val swap = m[col]; m[col] = m[pivot]; m[pivot] = swap
            val divisor = m[col][col]; require(abs(divisor) > 1e-10) { "no_board" }
            for (j in col..8) m[col][j] /= divisor
            for (row in 0..7) if (row != col) {
                val factor = m[row][col]; for (j in col..8) m[row][j] -= factor * m[col][j]
            }
        }
        val h = DoubleArray(8) { m[it][8] }
        return Image(SIZE, SIZE, IntArray(SIZE * SIZE) { i ->
            val x = (i % SIZE).toDouble(); val y = (i / SIZE).toDouble()
            val divisor = h[6] * x + h[7] * y + 1
            require(abs(divisor) > 1e-10) { "no_board" }
            sample(image, (h[0] * x + h[1] * y + h[2]) / divisor,
                          (h[3] * x + h[4] * y + h[5]) / divisor, true)
        })
    }

    private fun rotate(image: Image, turns: Int): Image = Image(SIZE, SIZE,
        IntArray(SIZE * SIZE) { i -> image.rgb[rotatedIndex(i / SIZE, i % SIZE, turns, SIZE)] })
    // Destination -> source for numpy.rot90 (anticlockwise).
    fun rotatedIndex(row: Int, col: Int, turns: Int, size: Int): Int = when ((turns % 4 + 4) % 4) {
        0 -> row * size + col
        1 -> col * size + size - 1 - row
        2 -> (size - 1 - row) * size + size - 1 - col
        else -> (size - 1 - col) * size + row
    }

    fun decode(squares: FloatArray, rotation: FloatArray, white: FloatArray, corners: List<Point>): Reading {
        require(squares.size == 4 * 13 * 64 && rotation.size == 16 && white.size == 4)
        require(squares.all { it.isFinite() } && rotation.all { it.isFinite() } && white.all { it.isFinite() })
        val average = FloatArray(13 * 64); val orientation = FloatArray(4)
        for (batch in 0..3) {
            for (i in 0 until 64) {
                val values = softmax(FloatArray(13) { squares[batch * 13 * 64 + it * 64 + i] })
                val source = rotatedIndex(i / 8, i % 8, batch, 8)
                for (c in 0..12) average[c * 64 + source] += values[c] / 4
            }
            val p = softmax(rotation.copyOfRange(batch * 4, batch * 4 + 4))
            for (c in 0..3) orientation[(c + batch) % 4] += p[c] / 4
        }
        val turns = orientation.indices.maxBy { orientation[it] }
        val bottom = white.sumOf { 1.0 / (1 + exp(-it.toDouble())) } >= 2
        val confidence = FloatArray(64)
        val grid = IntArray(64) { i ->
            val upright = if (bottom) i else 63 - i
            val source = rotatedIndex(upright / 8, upright % 8, turns, 8)
            val best = (0..12).maxBy { average[it * 64 + source] }
            confidence[i] = average[best * 64 + source]; best
        }
        return Reading(placement(grid), turns, bottom, corners, confidence)
    }
    private fun softmax(values: FloatArray): FloatArray {
        val max = values.max(); val exps = DoubleArray(values.size) { exp((values[it] - max).toDouble()) }
        val sum = exps.sum(); return FloatArray(values.size) { (exps[it] / sum).toFloat() }
    }
    fun placement(grid: IntArray): String {
        require(grid.size == 64 && grid.all { it in 0..12 })
        return (0..7).joinToString("/") { row -> buildString {
            var gap = 0
            for (col in 0..7) {
                val value = grid[row * 8 + col]
                if (value == 0) gap++ else { if (gap > 0) append(gap); gap = 0; append(SYMBOLS[value]) }
            }
            if (gap > 0) append(gap)
        } }
    }
}
