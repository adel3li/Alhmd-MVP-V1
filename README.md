# الحمد — Alhamd

تطبيق يوميٌّ لاستشعار نعم الله وشكرها — **عربيٌّ بالكامل، RTL، يعمل دون اتصال**.
دقيقتان كل يوم: تأمُّلٌ موجَّه («استشعار القيمة») في نعمةٍ واحدة، ثم حمدٌ يُدوَّن في سجلّك المحلي.

Flutter, one codebase → **Android · iOS · Web**. Full product spec: [`alhamd-app-build-spec.md`](./alhamd-app-build-spec.md) · project rules: [`CLAUDE.md`](./CLAUDE.md).

## Status — MVP scaffold complete

| Area | State |
|---|---|
| Theme «وقار/سكينة», Amiri + IBM Plex Arabic, WCAG AA asserted by test | ✅ |
| Home «نعمة اليوم» with deterministic daily selection | ✅ |
| استشعار القيمة guided flow (auto-pacing, step types, analytics funnel) | ✅ |
| سجل الحمد (Drift/SQLite, local-only) + completion record | ✅ |
| المداومة (Hijri month grid, محاسبة النفس framing — no gamification) | ✅ |
| Onboarding (3 screens; notification page omitted on web) | ✅ |
| Settings (reminder time, theme, text size, about, share) | ✅ |
| Daily notifications (mobile; rotating copy; web no-op per spec §7.3) | ✅ |
| Analytics abstraction (§8 events; debug=log only; Firebase when configured) | ✅ |
| Content validator + RTL check + CI | ✅ |
| 61 tests green · `flutter analyze` zero issues · web release build | ✅ |
| **Scholar-approved content** | ⚠️ 1 approved + 2 pending-review sample entries — release gate requires ≥30 approved |

## Development

Pinned: Flutter 3.44.1 · Dart 3.12.1.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift codegen
flutter run -d chrome        # web
flutter run                  # device/emulator
```

Quality gates (all enforced in CI):

```bash
dart run tool/validate_content.dart    # content schema + verification flags
bash tool/check_rtl.sh                 # no physical left/right layout APIs
flutter analyze                        # zero-warning policy
flutter test                           # unit + widget (incl. golden path)
flutter build web --release            # web parity gate
flutter test integration_test         # E2E on a device/emulator
```

## Content workflow (the heart of the app)

- `assets/content/blessings_ar.json` is the **single source of sacred content** (Quran/hadith/scholar quotes). It is read-only for tooling and AI assistants — see CLAUDE.md hard rule 1.
- `reviewStatus`: release builds publish **approved only**; debug builds also show `pending_review` so development isn't blocked during scholarly review.
- Release branches/tags fail CI with fewer than 30 approved entries, or any approved entry whose `quran.verified` / `hadith.gradeVerified` is false.
- The bundled sample content: `blessing_001` (from the spec example, approved there), plus two `pending_review` entries that must pass human Mushaf/grading verification before approval. **Every PR touching `assets/content/` needs human review.**

## Firebase Analytics (optional, release only)

The app runs fully without Firebase (analytics become a no-op). To enable:

```bash
dart pub global activate flutterfire_cli
flutterfire configure   # creates android/ios/web app config
```

Then pass the generated options to `Firebase.initializeApp` in
`lib/core/analytics/analytics_service.dart` (`createAnalyticsService`).
Debug builds never send analytics.

## Architecture

```
UI (widgets) → Providers (Riverpod 3, manual providers) → Repositories → Data sources
                                  ├── ContentRepository  → bundled JSON (read-only)
                                  ├── JournalStore       → Drift/SQLite (drift_flutter; sqlite3 WASM on web)
                                  └── SettingsRepository → SharedPreferences
```

- Feature-first folders under `lib/features/`; no business logic in widgets.
- All UI strings in `lib/l10n/app_ar.arb` (sacred texts come from content assets, never ARB).
- Web DB runtime files `web/sqlite3.wasm` + `web/drift_worker.js` are pinned to the lockfile's sqlite3/drift versions — re-download on upgrade (see drift web docs).

## Deviations from spec (deliberate, documented)

- **Riverpod 3 with manual providers** instead of Riverpod 2 + riverpod_generator — keeps codegen surface limited to Drift (noted in CLAUDE.md).
- **Light-theme `textSecondary` darkened** `#6B7080 → #656A79`: the spec value measured 4.23:1 on `quranBg`, below the spec's own WCAG AA rule (§3.1). Asserted in `test/theme_contrast_test.dart`.
- **`share_plus`** added for §6.6 «شارك التطبيق» (smallest standard option for the OS share sheet).
- Notification scheduling uses **inexact** daily alarms (14-day rolling window, refreshed each launch) — avoids the Android 14+ exact-alarm permission while keeping copy rotation (§7.1).

## Store release

Follow spec §12 (signing, listings, privacy). Before any release:
`dart run tool/validate_content.dart --release` must pass (≥30 approved entries)
and the §11.4 manual QA checklist must be signed off, including human
verification of every Quranic text against the Mushaf.

**والحمد لله الذي بنعمته تتم الصالحات.**
