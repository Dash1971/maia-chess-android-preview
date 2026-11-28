package com.dash1971.maia_chess

/** Boundary for image preparation and JNI inference. Release ownership before
 * returning to Flutter, including after memory exhaustion or native-link errors.
 * A dying/corrupt VM is not a recoverable scan failure.
 */
internal object BoardScanWork {
    fun <T> run(work: () -> T, release: (Throwable?) -> Unit,
                complete: (T?, Throwable?) -> Unit) {
        var value: T? = null
        var failure: Throwable? = null
        try { value = work() }
        catch (error: Throwable) { failure = error; recoverable(error) }
        finally {
            try { release(failure) }
            catch (error: Throwable) { recoverable(error); if (failure == null) failure = error }
        }
        complete(value, failure)
    }

    @Suppress("DEPRECATION") // Android can still terminate a worker this way.
    private fun recoverable(error: Throwable) {
        if (error is ThreadDeath || (error is VirtualMachineError && error !is OutOfMemoryError)) throw error
    }

    fun errorCode(error: Throwable): String = when (error.message) {
        "no_board" -> "scan_no_board"
        "scan_too_large" -> "scan_too_large"
        else -> "scan_read_failed"
    }
}
