@file:Suppress("DEPRECATION")
package com.dash1971.maia_chess

/** Inject failures at the same boundary used by preparation and JNI inference. */
fun main() {
    var checks = 0
    for (phase in listOf("preparation", "inference")) {
        for (failure in listOf(OutOfMemoryError("allocation"), UnsatisfiedLinkError("native"),
                               IllegalArgumentException("no_board"))) {
            val events = mutableListOf<String>()
            var busy = true
            var ownsImage = true
            var replies = 0
            BoardScanWork.run<String>(work = { throw failure }, release = { error ->
                check(error === failure)
                events.add("release"); ownsImage = false; busy = false
            }, complete = { value, error ->
                check(value == null && error === failure)
                check(!busy && !ownsImage) { "$phase must release before reply/retry" }
                check(BoardScanWork.errorCode(error) ==
                    if (failure is IllegalArgumentException) "scan_no_board" else "scan_read_failed")
                events.add("reply"); replies++
                // A callback can immediately start the next operation.
                BoardScanWork.run(work = { "retry" }, release = { check(it == null) },
                    complete = { result, retryError -> check(result == "retry" && retryError == null) })
            })
            check(replies == 1 && events == listOf("release", "reply")); checks++
        }
    }
    var replies = 0
    BoardScanWork.run(work = { "placement" }, release = { check(it == null) }, complete = { value, error ->
        check(value == "placement" && error == null); replies++
    })
    check(replies == 1); checks++
    val cleanupFailure = SecurityException("cleanup")
    BoardScanWork.run(work = { "placement" }, release = { throw cleanupFailure }, complete = { _, error ->
        check(error === cleanupFailure); replies++
    })
    check(replies == 2); checks++
    // Never suppress VM corruption or thread termination as a failed photo.
    for (fatal in listOf(StackOverflowError(), ThreadDeath())) {
        var released = false
        try {
            BoardScanWork.run<String>(work = { throw fatal }, release = { released = true }, complete = { _, _ ->
                error("Fatal errors must propagate")
            })
            error("Fatal error swallowed")
        } catch (error: Throwable) { check(error === fatal && released); checks++ }
    }
    check(BoardScanWork.errorCode(IllegalArgumentException("scan_too_large")) == "scan_too_large"); checks++
    println("$checks BoardScanWork failure/retry checks passed")
}
