const t = @import("std").time;

/// A dead simple timer implementation. Times are captured in microsecond granularity unless using
/// functions postfixed with "MS" which expects milliseconds.
const Timer = @This();
time: i64,
started_at: i64,
done: bool,

/// Return a new `Timer` that will wait `time` microseconds before firing. At new timers are created
/// in a finished state to force caling `reset()` before using them. Otherwise the starting time can
/// not be captured properly.
pub fn init(time: i64) Timer {
    return Timer{
        .time = time,
        .started_at = 0,
        .done = true,
    };
}

/// Same as `init` but expects milliseconds.
pub fn initMS(time: i64) Timer {
    return Timer{
        .time = time * 1000,
        .started_at = 0,
        .done = true,
    };
}

/// Returns whether or not the `Timer` is done, caching the result if so.
pub fn isDone(self: *Timer) bool {
    self.done = self.done or t.microTimestamp() - self.started_at > self.time;
    return self.done;
}

/// Returns the result of `isDone()`, but only if the `Timer` wasn't already finished. This
/// allows for one-shot behavior.
pub fn fired(self: *Timer) bool {
    if (self.done) {
        return false;
    }

    return self.isDone();
}

/// Allows for manually setting a `Timer` to done.
pub fn finish(self: *Timer) void {
    self.done = true;
}

/// Starts the `Timer` over with the same duration.
pub fn reset(self: *Timer) void {
    self.started_at = t.microTimestamp();
    self.done = false;
}

/// Like `reset()` but sets a new time.
pub fn setTime(self: *Timer, time: f32) void {
    self.time = time;
    self.reset();
}

/// Same as `setTime()` but expects milliseconds.
pub fn setTimeMS(time: i64) Timer {
    return Timer{
        .time = time * 1000,
        .started_at = t.microTimestamp(),
    };
}
