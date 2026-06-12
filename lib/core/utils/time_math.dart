/// Pure scheduling math, unit-tested in test/time_math_test.dart (spec §11.1).
library;

/// The next occurrence of [hour]:[minute] strictly after [now].
///
/// If today's occurrence hasn't passed yet it is returned; otherwise the same
/// wall-clock time tomorrow. Uses calendar arithmetic (not `Duration`) so DST
/// transitions keep the wall-clock time the user picked.
DateTime nextDailyOccurrence(DateTime now, int hour, int minute) {
  var candidate = DateTime(now.year, now.month, now.day, hour, minute);
  if (!candidate.isAfter(now)) {
    candidate = DateTime(now.year, now.month, now.day + 1, hour, minute);
  }
  return candidate;
}
