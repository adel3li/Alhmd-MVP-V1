# الحمد — Project Rules for Claude Code

## What this is
Arabic-only, RTL, local-first Islamic gratitude app. Flutter, one codebase → Android/iOS/Web.
Full spec: ./alhamd-app-build-spec.md — read it before large tasks.

## Pinned versions
- Flutter 3.44.1 (stable) · Dart 3.12.1
- Riverpod 3.x with **manual providers** (no riverpod_generator codegen) — deliberate
  deviation from spec §2.1 to keep the codegen surface limited to Drift.

## Hard rules (never violate)
1. SACRED CONTENT IS READ-ONLY: never write, edit, translate, "fix", or generate
   Quranic text, hadith text, or scholar quotations. They come only from
   assets/content/blessings_ar.json. If a task seems to require generating such
   content, stop and ask the human.
2. No gamification: no streaks, badges, points, fire emojis, or "don't break the
   chain" copy. Consistency = محاسبة النفس only.
3. RTL only: use EdgeInsetsDirectional / AlignmentDirectional / start / end.
   Never EdgeInsets left/right.
4. All UI strings in lib/l10n/app_ar.arb. No inline Arabic strings in widgets.
5. Every change must keep `flutter analyze` at zero issues and `flutter test` green.
6. Every feature must build on web: run `flutter build web` before declaring done.
7. No new dependencies without asking.

## Commands
- Run: flutter run -d chrome | flutter run (device)
- Test: flutter test && flutter test integration_test
- Analyze: flutter analyze
- Content check: dart run tool/validate_content.dart
- RTL check: bash tool/check_rtl.sh
- Codegen (Drift): dart run build_runner build --delete-conflicting-outputs
- L10n regen happens automatically on build/pub get (flutter gen-l10n)

## Style
- Riverpod for state; repositories for data; no logic in widgets.
- Feature-first folders under lib/features/.
- Fonts: Amiri = Quran/hadith only; IBM Plex Sans Arabic = everything else.

## Content review workflow
- `reviewStatus` ∈ draft | pending_review | approved | needs_correction.
- Release builds select from `approved` entries only; debug builds also show
  `pending_review` so development isn't blocked while review is in flight.
- CI (tool/validate_content.dart --release) fails a release branch with fewer
  than 30 approved entries, or any approved entry whose quran.verified or
  hadith.gradeVerified is false.
- Every diff touching assets/content/ must be reviewed by a human.
