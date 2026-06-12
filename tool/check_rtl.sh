#!/usr/bin/env bash
# RTL discipline check — spec §3.3 / CLAUDE.md hard rule 3.
# Fails if physical (left/right) layout APIs appear in lib/ — the app is
# RTL-only and must use Directional equivalents (start/end).
set -u

violations=$(grep -rnE \
  -e 'EdgeInsets\.only\([^)]*(left|right)\s*:' \
  -e 'EdgeInsets\.fromLTRB' \
  -e 'Alignment\.(top|center|bottom)(Left|Right)' \
  -e 'TextAlign\.(left|right)\b' \
  -e 'Positioned\(\s*(left|right)\s*:' \
  -e 'BorderRadius\.only\(' \
  --include='*.dart' \
  lib \
  | grep -v 'lib/l10n/generated' \
  | grep -v '\.g\.dart' || true)

if [ -n "$violations" ]; then
  echo "✗ RTL violations found (use EdgeInsetsDirectional / AlignmentDirectional / start / end):"
  echo "$violations"
  exit 1
fi
echo "✓ RTL check passed"
