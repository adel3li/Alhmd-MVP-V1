# تطبيق «الحمد» — Complete Build Specification
### Cross-Platform (Android · iOS · Web) — Built with Claude Fable 5 via Claude Code

> **Document purpose:** This is the single source of truth for building the الحمد MVP. It is written to be handed directly to Claude Code (running Claude Fable 5) as project context. Place this file in the repo root, and also create a `CLAUDE.md` from §13.2 so every Claude Code session inherits the project rules automatically.

---

## 1. Vision & Product Context

**الحمد** is a daily gratitude app for Muslims — the app pillar of a larger ecosystem (podcast «الحمد», social content, physical products). The app's purpose is to help users build a daily habit of حمد through short, contemplative, scholarly-grounded reflections.

**The spiritual and product core is استشعار القيمة** — a guided loss-visualization technique rooted in Quranic rhetorical method (e.g. ﴿قُلْ أَرَأَيْتُمْ إِنْ أَصْبَحَ مَاؤُكُمْ غَوْرًا فَمَن يَأْتِيكُم بِمَاءٍ مَّعِينٍ﴾). The user is asked to genuinely imagine losing a blessing before being guided back to gratitude for its presence. This flow is what differentiates الحمد from Muslim Pro, Sabr, Sakeenah, and Sakinly — it must receive the most design and engineering care.

**Non-negotiable principles:**

1. **Arabic-first, RTL throughout.** The entire UI is in فصحى Arabic. No mixed-language UI. English appears nowhere in the user-facing product (MVP).
2. **No gamification of worship.** No streaks, badges, points, or leaderboards. Consistency is framed as **محاسبة النفس**, anchored in the hadith «أحبُّ الأعمالِ إلى اللهِ أدومُها وإن قلَّ». The app shows a gentle consistency view (سجل المداومة) framed as self-accounting, never as a game.
3. **Scholarly accuracy is non-negotiable.** Every Quranic verse, hadith, and scholarly quotation in the content database carries verification metadata. Content flagged `reviewStatus != "approved"` must never ship in a release build (enforced by a CI check, see §10.4).
4. **Content precedes code.** The 365-blessing JSON database is the heart of the app. MVP launches with 30–60 fully reviewed blessings.
5. **Local-first.** No backend, no login, no accounts for MVP. Local storage + local notifications. Firebase Analytics only.

**Success metrics:** D1/D7/D30 retention and reflection-completion rate — *not* downloads.

---

## 2. Tech Stack Decision

**Framework: Flutter (Dart)** — one codebase compiling to native Android, native iOS, and Web (CanvasKit renderer).

Why Flutter over React Native for this project specifically:

- **First-class RTL support.** Flutter's `Directionality`, `EdgeInsetsDirectional`, `start/end` alignment, and automatic mirroring make a pure-RTL app far less error-prone than RN's RTL story.
- **Superior Arabic text rendering.** Custom font embedding (Amiri for Quranic display, IBM Plex Sans Arabic for UI) with full control over `TextStyle`, line height, and harakāt rendering. The web build uses CanvasKit, which renders Arabic shaping identically to mobile.
- **True three-platform parity** from one codebase, including Web — RN's web support (react-native-web) is a second-class citizen.
- **Animation toolkit** (implicit animations, `AnimationController`, Rive/Lottie support) suits the slow, breathing, contemplative motion language of the استشعار القيمة flow.

### 2.1 Pinned stack

| Layer | Choice | Notes |
|---|---|---|
| Framework | Flutter (latest stable channel) | Run `flutter upgrade` and pin the version in `CLAUDE.md` once chosen |
| Language | Dart 3.x | Null-safe, records & patterns allowed |
| State management | Riverpod 2.x (`flutter_riverpod`, `riverpod_generator`) | Compile-safe providers, easy testing |
| Local storage | `drift` (SQLite) for journal entries + `shared_preferences` for settings | Drift works on all 3 platforms (uses `sqlite3` WASM on web) |
| Content database | Bundled JSON asset (`assets/content/blessings_ar.json`) | Read-only, versioned, schema in §5 |
| Notifications | `flutter_local_notifications` (Android/iOS) | Web: no scheduled notifications in MVP — show in-app daily prompt instead (§7.3) |
| Analytics | `firebase_analytics` + `firebase_core` | Events in §8 |
| Fonts | `google_fonts` is **not** used — bundle Amiri + IBM Plex Sans Arabic locally in `assets/fonts/` for offline reliability and rendering consistency |
| Routing | `go_router` | Deep-link ready for the future |
| Audio (post-MVP hook) | `just_audio` | For podcast-episode embedding later; stub the interface now |
| Localization | `flutter_localizations` + ARB files (`intl`) | Even though MVP is Arabic-only, wire l10n from day one (`app_ar.arb`) so copy lives outside widgets |
| Lint | `very_good_analysis` or `flutter_lints` strict | Zero analyzer warnings policy |

### 2.2 Repository layout

```
alhamd/
├── CLAUDE.md                      # Claude Code project memory (§13.2)
├── README.md
├── pubspec.yaml
├── analysis_options.yaml
├── assets/
│   ├── content/
│   │   └── blessings_ar.json      # The content database (§5)
│   ├── fonts/
│   │   ├── Amiri-Regular.ttf
│   │   ├── Amiri-Bold.ttf
│   │   ├── IBMPlexSansArabic-Regular.ttf
│   │   ├── IBMPlexSansArabic-Medium.ttf
│   │   └── IBMPlexSansArabic-SemiBold.ttf
│   └── images/                    # Onboarding illustrations, empty states
├── lib/
│   ├── main.dart
│   ├── app.dart                   # MaterialApp.router, theme, Directionality
│   ├── core/
│   │   ├── theme/                 # colors.dart, typography.dart, theme.dart
│   │   ├── routing/router.dart
│   │   ├── analytics/analytics_service.dart
│   │   └── utils/hijri_date.dart  # Hijri date display (package: hijri)
│   ├── data/
│   │   ├── models/blessing.dart   # Generated from JSON schema (§5)
│   │   ├── models/journal_entry.dart
│   │   ├── repositories/content_repository.dart
│   │   ├── repositories/journal_repository.dart
│   │   └── db/app_database.dart   # Drift
│   ├── features/
│   │   ├── onboarding/
│   │   ├── home/
│   │   ├── reflection/            # استشعار القيمة flow (§6.3) — the core
│   │   ├── journal/               # سجل الحمد
│   │   ├── consistency/           # محاسبة النفس view
│   │   └── settings/
│   └── l10n/app_ar.arb
├── test/                          # unit + widget tests
├── integration_test/
└── tool/
    └── validate_content.dart      # CI content validator (§10.4)
```

---

## 3. Design System

### 3.1 Palette — «وقار» (light) and «سكينة» (dark)

| Token | Light (default) | Dark | Usage |
|---|---|---|---|
| `background` | `#FAF6EE` warm cream | `#141B2E` midnight indigo | Scaffold |
| `surface` | `#FFFFFF` | `#1C2540` | Cards |
| `primary` | `#1F2A4A` deep indigo | `#E8DCC0` warm cream | Buttons, headers |
| `accent` | `#B89B5E` muted gold | `#C9AC6E` muted gold | Highlights, الحمد moments, dividers |
| `textPrimary` | `#22283B` | `#F2EDE2` | Body text |
| `textSecondary` | `#6B7080` | `#A9AFC0` | Captions, metadata |
| `quranBg` | `#F4EDDC` | `#1A2238` | Quranic verse containers |
| `success` | `#4C7A5C` muted green | `#6FA383` | Completion states |

**Contrast rule (carries over a flagged Stitch issue):** all text/background pairs must pass WCAG AA (≥ 4.5:1 body, ≥ 3:1 large text). Add a golden test asserting the theme tokens meet this (§11.2).

### 3.2 Typography

| Role | Font | Size / weight |
|---|---|---|
| Quranic verses | **Amiri** (Regular for body, Bold for emphasis) | 24–28sp, line-height 2.0, with harakāt |
| Hadith & scholar quotes | Amiri Regular | 20sp, line-height 1.9 |
| Screen titles | IBM Plex Sans Arabic SemiBold | 22sp |
| Body / UI | IBM Plex Sans Arabic Regular | 16sp, line-height 1.7 |
| Captions / metadata (grading, sources) | IBM Plex Sans Arabic Regular | 13sp, `textSecondary` |

Rules:
- Quranic text is **always** rendered in Amiri, always inside the `quranBg` container with ﴿ ﴾ ornamental brackets, with surah:ayah reference beneath in caption style.
- Hadith always displays its grading (صحيح / حسن) and source in caption style beneath — pulled from content metadata, never hardcoded.
- Never letter-space Arabic text. Never justify Quranic text; use start-alignment.

### 3.3 RTL & layout

- Wrap the app in `Directionality(textDirection: TextDirection.rtl)` AND set `locale: Locale('ar')` — both, so Material widgets localize correctly.
- Use only `EdgeInsetsDirectional`, `AlignmentDirectional`, `start/end` — **never** `left/right` in any widget. Add a lint/grep CI check for `EdgeInsets.only(left:` and `right:`.
- Back navigation chevron points right (Material handles this when locale is `ar` — verify in widget tests).
- Numerals: use Eastern Arabic numerals (٠١٢٣) for dates and counters via `intl` `NumberFormat` with `ar` locale.
- Hijri date shown alongside Gregorian on Home (e.g. «١٥ ذو الحجة ١٤٤٧»).

### 3.4 Motion language

Contemplative, slow, breathing — never bouncy or playful:
- Page transitions: 400ms fade-through.
- استشعار القيمة flow: 600–800ms cross-fades, a subtle slow-pulse "breathing" scale (1.0 → 1.03, 4s cycle) on the central element.
- No confetti, no celebratory bursts. Completion is marked by a quiet gold glow + the word «الحمد لله» fading in.

---

## 4. Architecture

**Pattern:** Feature-first folders + Repository pattern + Riverpod.

```
UI (widgets) → Providers (Riverpod) → Repositories → Data sources
                                          ├── ContentRepository → bundled JSON asset (read-only)
                                          ├── JournalRepository → Drift/SQLite (local)
                                          └── SettingsRepository → SharedPreferences
```

Rules for Claude Code when generating code:

1. **No business logic in widgets.** Widgets read providers; providers call repositories.
2. **All user-facing strings live in `lib/l10n/app_ar.arb`** — never inline Arabic strings in widgets (Quranic/hadith content comes from the JSON database, not ARB).
3. **Deterministic daily blessing selection:** `blessingOfDay = blessings[dayOfYear % publishedBlessings.length]`, where `publishedBlessings` = entries with `reviewStatus == "approved"`, sorted by `order`. Same blessing for all users on the same date; survives restarts; works offline.
4. **Offline-first:** every feature must work in airplane mode. Analytics queue offline and flush automatically (Firebase handles this).
5. **Web parity:** every PR must build for web (`flutter build web`). Platform-specific code goes behind an abstraction (e.g. `NotificationService` with mobile/web implementations selected via conditional imports).

---

## 5. Content Database — `blessings_ar.json`

The most important artifact in the project. Schema (one entry):

```json
{
  "schemaVersion": 2,
  "blessings": [
    {
      "id": "blessing_001",
      "order": 1,
      "category": "din",
      "categoryLabel": "نعم الدين",
      "title": "نعمة الإسلام",
      "shortTitle": "الإسلام",
      "openingLine": "أعظمُ نعمةٍ أنعمَ اللهُ بها عليك: أن هداكَ للإسلام.",
      "quran": {
        "textUthmani": "ٱلْيَوْمَ أَكْمَلْتُ لَكُمْ دِينَكُمْ وَأَتْمَمْتُ عَلَيْكُمْ نِعْمَتِى وَرَضِيتُ لَكُمُ ٱلْإِسْلَـٰمَ دِينًا",
        "surahName": "المائدة",
        "surahNumber": 5,
        "ayahNumber": 3,
        "verified": true
      },
      "hadith": {
        "text": "…",
        "source": "صحيح مسلم",
        "number": "…",
        "grade": "صحيح",
        "gradeVerified": true
      },
      "scholarQuote": {
        "text": "…",
        "scholar": "ابن القيم",
        "work": "مدارج السالكين",
        "attributionType": "paraphrase",
        "verifiedVerbatim": false
      },
      "istisharSteps": [
        { "step": 1, "type": "ground",    "text": "خذ نفسًا عميقًا… واستحضر قلبك.", "durationSec": 10 },
        { "step": 2, "type": "visualize", "text": "تخيَّل لو أصبحتَ يومًا ولا تعرف الله…", "durationSec": 20 },
        { "step": 3, "type": "deepen",    "text": "لا صلاة تطمئن بها… ولا قرآن يهديك… ولا دعاء تلجأ إليه…", "durationSec": 20 },
        { "step": 4, "type": "return",    "text": "ثم افتح عينيك… أنت مسلم. هداكَ اللهُ ولم تسأله الهداية.", "durationSec": 15 },
        { "step": 5, "type": "hamd",      "text": "فقل من قلبك: الحمد لله الذي هدانا لهذا وما كنا لنهتدي لولا أن هدانا الله.", "durationSec": 15 }
      ],
      "tadabbur": "…",
      "duaa": "اللهم لك الحمد كما ينبغي لجلال وجهك وعظيم سلطانك…",
      "journalPrompt": "اكتب: ما الذي شعرتَ به حين تخيَّلتَ فقدَ هذه النعمة؟",
      "relatedPodcastEpisode": "ep_001",
      "reviewStatus": "approved",
      "reviewedBy": "—",
      "reviewDate": "2026-05-01",
      "contentVersion": 1
    }
  ]
}
```

**Schema rules:**

- `category` ∈ `din | nafs | aql | nasl | mal | amn | afiyah | rizq` — ordering follows Maqasid al-Shari'ah + the prophetic ranking (أمن، عافية، رزق).
- `reviewStatus` ∈ `draft | pending_review | approved | needs_correction`. **The release build filters to `approved` only**, and CI fails if fewer than 30 approved entries exist at release time.
- `attributionType` ∈ `verbatim | paraphrase`. Paraphrased quotes render with «بمعناه» in the caption.
- Quranic `textUthmani` must be copied from a verified Uthmani source (e.g. the official Madinah Mushaf digital text) — never typed by hand, never generated by an AI model. Claude Code must treat all `quran`, `hadith`, and `scholarQuote` fields as **read-only sacred content**: it may move them, never edit them. This rule goes in `CLAUDE.md`.
- MVP target: **30–60 approved entries** before store submission; grow toward 365.

---

## 6. Screens & Features (MVP scope)

Build order (matches the agreed sequence): **Home → Reflection entry → Journal (empty + populated) → استشعار القيمة flow → Onboarding → Settings → Consistency view.**

### 6.1 Onboarding (3 screens, shown once)

1. **«الحمد»** — logo, tagline: «دقيقتان كل يوم… تُحيي بهما قلبك بالشكر». Button: «ابدأ».
2. **استشعار القيمة explained** — one short paragraph + the Quranic anchor ﴿قُلْ أَرَأَيْتُمْ إِنْ أَصْبَحَ مَاؤُكُمْ غَوْرًا﴾ in the Quran container. Button: «فهمت».
3. **Notification permission** — «نذكّرك بنعمةٍ واحدةٍ كل يوم. متى يناسبك؟» Time picker (default ٧:٠٠ صباحًا) + «تخطّي». Request OS permission only after the user picks a time (pre-permission pattern → higher grant rate).

### 6.2 Home — «نعمة اليوم»

- Header: «السلام عليكم» + Hijri & Gregorian date.
- Central card: today's blessing — `categoryLabel` chip, `title` in large Amiri-adjacent display, `openingLine`, and the Quranic verse container.
- Primary CTA (gold): «استشعر النعمة» → launches the reflection flow.
- Secondary row: «سجل الحمد» (journal) · «المداومة» (consistency) · settings icon.
- If today's reflection is completed: card shows a quiet gold check + «حمدتَ اللهَ اليوم» and the CTA becomes «أعد الاستشعار».

### 6.3 استشعار القيمة — the core flow ★

A full-screen, immersive, step-by-step guided experience driven by `istisharSteps`:

- **Visual:** dark «سكينة» palette regardless of theme (immersion). Background: very slow radial gradient drift. Centered text, one step at a time, large IBM Plex Arabic (steps) / Amiri (Quran & hamd step).
- **Pacing:** each step auto-advances after `durationSec` with a thin gold progress arc; user can also tap «التالي». A skip is deliberately *not* offered mid-visualization (steps 2–3) — only a quiet exit «خروج» top-start corner.
- **Step types render differently:**
  - `ground`: breathing pulse circle.
  - `visualize` / `deepen`: text only, slightly dimmed surroundings; haptic soft tick (mobile) on step change.
  - `return`: brightness gently rises.
  - `hamd`: gold accents bloom; the duʿāʾ text appears; button «الحمد لله» (the only bright element).
- **Completion screen:** the `journalPrompt` + an optional text field «اكتب حمدك…» → saving creates a journal entry; «حفظ في سجل الحمد» / «لاحقًا».
- **Analytics:** `reflection_started`, `reflection_step_completed(step)`, `reflection_completed`, `reflection_abandoned(step)` — completion rate is the #1 product metric.

### 6.4 سجل الحمد — Journal

- Populated: reverse-chronological cards — date (Hijri), blessing `shortTitle` chip, the user's written hamd. Tap to expand; long-press → حذف (with confirm).
- Empty state: gentle illustration + «سجلُّك ما زال صفحةً بيضاء… ابدأ اليوم باستشعار نعمة» + CTA to today's reflection. (Fixes the flagged unstyled-archive-card issue: cards use `surface` + 16dp radius + gold start-border 3dp.)
- Entries are local-only (Drift). Export as plain text via OS share sheet (post-MVP: nice-to-have, keep behind a flag).

### 6.5 المداومة — محاسبة النفس view (NOT gamification)

- A simple monthly grid (Hijri month) marking days a reflection was completed — neutral dots, no flames, no streak counters, no "don't break the chain" copy.
- Header hadith: «أحبُّ الأعمالِ إلى اللهِ أدومُها وإن قلَّ» (متفق عليه) — with grading caption.
- Copy frames it as self-accounting: «هذه صفحتُك مع نفسك… لا سِباقَ مع أحد».
- Missed days are simply empty — never red, never "broken".

### 6.6 Settings

- Notification time (reschedules local notification).
- Theme: فاتح / داكن / تلقائي.
- Text size: عادي / كبير (scales Quran/body text — accessibility).
- «عن التطبيق»: mission, scholarly-review statement, podcast link, content version, privacy policy link.
- «شارك التطبيق» (OS share sheet).


---

## 7. Notifications

### 7.1 Mobile (Android & iOS)
- `flutter_local_notifications` with `zonedSchedule` repeating daily at the user's chosen time.
- Notification copy rotates from a small pool, e.g.: «نعمةُ اليوم بانتظارك… دقيقتان تُحييان قلبك»، «﴿وَإِن تَعُدُّوا نِعْمَةَ اللَّهِ لَا تُحْصُوهَا﴾ — استشعر نعمة اليوم».
- Android 13+: request `POST_NOTIFICATIONS` runtime permission. iOS: request via the plugin after onboarding time-pick.
- Tapping the notification deep-links (go_router) straight to today's reflection.

### 7.2 Timezone correctness
Use the `timezone` package + `flutter_timezone` to schedule in the device's local zone; reschedule on app launch if the saved time has passed validation (DST/zone changes).

### 7.3 Web
No reliable scheduled notifications without a backend/push service. MVP behavior on web: omit the notification settings section and instead show today's blessing prominently on load. (Post-MVP: FCM Web Push.)

---

## 8. Analytics (Firebase)

Events — all `snake_case`, no PII, no journal content ever sent:

| Event | Params | Why |
|---|---|---|
| `onboarding_completed` | `notification_optin: bool` | Funnel start |
| `daily_blessing_viewed` | `blessing_id, category` | Engagement |
| `reflection_started` | `blessing_id` | Core funnel |
| `reflection_step_completed` | `blessing_id, step, step_type` | Find drop-off step |
| `reflection_completed` | `blessing_id, duration_sec` | **#1 metric** |
| `reflection_abandoned` | `blessing_id, step` | Core funnel |
| `journal_entry_saved` | `blessing_id, has_text: bool` | Depth |
| `notification_opened` | `blessing_id` | Re-engagement |
| `settings_changed` | `setting` | Diagnostics |

User properties: `theme`, `notification_enabled`, `text_size`. Retention (D1/D7/D30) comes free from Firebase. Disable Analytics collection automatically in debug builds.

Privacy: local-first means the **only** data leaving the device is anonymous analytics. State this clearly in the privacy policy (required by both stores, §12.5).

---

## 9. Building It with Claude Fable 5 (Claude Code)

You will build this app by pairing with **Claude Code** running the **Claude Fable 5** model.

### 9.1 Setup
1. Install Claude Code — follow the official docs: https://docs.claude.com/en/docs/claude-code/overview (also available as a desktop app and VS Code extension).
2. In the repo root, run `claude` and select the Fable 5 model (use the `/model` command inside Claude Code; the API model string is `claude-fable-5`).
3. Put **this file** in the repo root and create `CLAUDE.md` (below). Claude Code automatically reads `CLAUDE.md` every session.

### 9.2 `CLAUDE.md` (copy into repo root)

```markdown
# الحمد — Project Rules for Claude Code

## What this is
Arabic-only, RTL, local-first Islamic gratitude app. Flutter, one codebase → Android/iOS/Web.
Full spec: ./alhamd-app-build-spec.md — read it before large tasks.

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
- Codegen: dart run build_runner build --delete-conflicting-outputs

## Style
- Riverpod for state; repositories for data; no logic in widgets.
- Feature-first folders under lib/features/.
- Fonts: Amiri = Quran/hadith only; IBM Plex Sans Arabic = everything else.
```

### 9.3 Recommended task sequence (one Claude Code session each)

1. «Scaffold the Flutter project per §2.2: pubspec with pinned deps, theme from §3, RTL app shell, go_router, ARB l10n, fonts wired.»
2. «Implement the Blessing model + ContentRepository loading blessings_ar.json, with the deterministic daily-selection rule from §4, plus unit tests.»
3. «Build the Home screen per §6.2 with a 3-entry sample JSON.»
4. «Build the استشعار القيمة flow per §6.3 — timers, step renderers, analytics events, completion screen.»
5. «Drift database + JournalRepository + Journal screens (empty/populated) per §6.4.»
6. «Consistency view per §6.5, Settings per §6.6, Onboarding per §6.1.»
7. «NotificationService abstraction: mobile impl + web no-op, deep link to reflection.»
8. «Firebase Analytics service + all §8 events; disabled in debug.»
9. «tool/validate_content.dart + GitHub Actions CI per §10.4–10.5.»
10. «Test pass per §11; then release prep per §12.»

Tips: keep tasks scoped to one feature; ask Claude to write tests *with* each feature, not after; use plan mode for the reflection flow before letting it write code; review every diff touching `assets/content/` manually.

---

## 10. Environment Setup & Build Instructions

### 10.1 Prerequisites
- **Flutter SDK** (stable): https://docs.flutter.dev/get-started/install — then `flutter doctor` until all green.
- **Android:** Android Studio + SDK + an emulator; accept licenses: `flutter doctor --android-licenses`.
- **iOS (macOS only):** Xcode (latest from App Store) + CocoaPods (`sudo gem install cocoapods`) + an Apple Developer Program membership ($99/yr) for device testing & store release.
- **Web:** Chrome.
- **Firebase:** create one Firebase project «alhamd», then `dart pub global activate flutterfire_cli` and `flutterfire configure` → registers Android, iOS, and Web apps and generates `firebase_options.dart`.

### 10.2 Daily development
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Riverpod/Drift codegen
flutter run -d chrome        # web
flutter run                  # connected device/emulator
```

### 10.3 Release builds
```bash
# Android (App Bundle for Play Store)
flutter build appbundle --release

# iOS (then archive in Xcode / upload)
flutter build ipa --release

# Web
flutter build web --release          # CanvasKit is the default renderer
```

### 10.4 Content validator — `tool/validate_content.dart`
A Dart script run in CI and pre-release that fails the build if:
- JSON doesn't parse or violates the §5 schema (required fields, enum values);
- any `reviewStatus == "approved"` entry has `quran.verified == false` or `hadith.gradeVerified == false`;
- fewer than 30 approved entries exist on a release branch;
- duplicate `id` or `order` values exist.

### 10.5 CI (GitHub Actions) — `.github/workflows/ci.yml`
On every PR: checkout → setup Flutter → `flutter pub get` → `dart run tool/validate_content.dart` → `flutter analyze` → `flutter test --coverage` → `flutter build web --release` → `flutter build apk --debug`. (iOS build verification requires a macOS runner; run it at least on release branches.)


---

## 11. Testing Strategy

### 11.1 Unit tests (`test/`)
- Daily-selection determinism (same date → same blessing; only `approved` entries eligible; stable across restarts).
- Content schema parsing (valid sample + malformed samples → clear errors).
- JournalRepository CRUD; Hijri date formatting; notification scheduling math (next-occurrence logic across midnight/DST).

### 11.2 Widget & golden tests
- Every screen renders under `Directionality.rtl` + `Locale('ar')` with no overflow at widths 320, 390, 768, 1280 (web).
- Golden tests for: Home card, Quran verse container, journal card, each استشعار step type — light & dark.
- A theme test asserting all §3.1 token pairs meet WCAG AA contrast.
- Text-scale test: everything still renders at `textScaleFactor: 1.3` (large text setting).

### 11.3 Integration tests (`integration_test/`)
The golden-path E2E: onboarding → home → complete a full استشعار flow (fake timers) → save journal entry → entry visible in سجل الحمد → consistency grid shows today marked. Run on an Android emulator and iOS simulator in CI (release branches) and on Chrome via `flutter drive`.

### 11.4 Manual QA checklist (before every store submission)
- [ ] Airplane mode: full app works, reflection completes, journal saves.
- [ ] Notification fires at chosen time on a real Android device and a real iPhone; tap deep-links to today's reflection.
- [ ] Arabic shaping & harakāt render correctly on: low-end Android, iPhone, Chrome, Safari (web).
- [ ] Quranic text on every approved blessing visually checked against the Mushaf by a human.
- [ ] RTL sweep: no left-aligned strays, back chevron points right, share sheet works.
- [ ] Kill app mid-reflection → reopen → state is sane (no corrupted journal rows).
- [ ] Dark/light/auto theme switching; large-text mode.
- [ ] Date rollover at midnight changes نعمة اليوم; Hijri date correct (compare with a calendar).
- [ ] Web: refresh mid-flow doesn't crash; deep links work; layout fine at mobile and desktop widths.
- [ ] **Scholar sign-off recorded for every `approved` content entry in this release.**

---

## 12. Store Deployment — Step by Step

### 12.1 Identity & versioning
- App name: **الحمد** (store listing can be «الحمد — استشعر نعم الله» for searchability).
- Bundle ID / applicationId: `com.<yourorg>.alhamd` — set in `android/app/build.gradle` and Xcode → Runner → General. **Cannot be changed after first publish.**
- Versioning in `pubspec.yaml`: `version: 1.0.0+1` (`name+code`); bump the `+code` on every store upload.

### 12.2 Android — Google Play
1. **Play Console account** (one-time $25): https://play.google.com/console. Note: new personal accounts require a closed test with ≥12 testers for 14 days before production access — plan this into the timeline (verify current policy in the Console).
2. **Signing key:**
   ```bash
   keytool -genkey -v -keystore ~/keys/alhamd-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   Create `android/key.properties` (git-ignored) and wire signing in `build.gradle` per Flutter docs (https://docs.flutter.dev/deployment/android). **Back the keystore up twice; losing it is unrecoverable for updates** (Play App Signing mitigates this — enroll in it).
3. Set `minSdkVersion 23+`, add the notification permission, app icon via `flutter_launcher_icons`.
4. `flutter build appbundle --release` → upload `build/app/outputs/bundle/release/app-release.aab`.
5. Console requirements: store listing in **Arabic as primary language** (title ≤30 chars, short description ≤80, full ≤4000), screenshots (phone + 7" and 10" tablet), feature graphic 1024×500, privacy policy URL, Data Safety form (declare: analytics only, no personal data collected), content rating questionnaire (likely "Everyone"), target audience.
6. Track flow: **Internal testing** (instant, up to 100 testers) → **Closed testing** → **Production**. First production review typically takes a few days.

### 12.3 iOS — App Store
1. **Apple Developer Program** ($99/yr): https://developer.apple.com/programs/.
2. In Xcode (`open ios/Runner.xcworkspace`): set Team (automatic signing), Bundle ID, Display Name «الحمد», deployment target iOS 13+.
3. App Store Connect (https://appstoreconnect.apple.com): create the app record with the same Bundle ID; primary language **Arabic**; category Lifestyle (secondary: Reference).
4. Build & upload:
   ```bash
   flutter build ipa --release
   ```
   Upload `build/ios/ipa/*.ipa` via the **Transporter** app (or `xcrun altool`/Xcode Organizer).
5. **TestFlight:** internal testers immediately; external testers after a light beta review. Run the §11.4 checklist here on real devices.
6. Submission assets: screenshots for 6.7" and 6.5" iPhones (+ iPad if you enable iPad), description in Arabic, keywords (الحمد، شكر، امتنان، أذكار، تدبر), support URL, privacy policy URL, **App Privacy** declaration (analytics/usage data, not linked to identity), age rating.
7. Review notes tip: briefly explain the app's religious-content sourcing and that all content is scholar-reviewed; reviews typically take ~1–2 days.

### 12.4 Web — Firebase Hosting
1. `npm install -g firebase-tools && firebase login && firebase init hosting` (public dir: `build/web`, single-page app: yes).
2. Deploy:
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```
3. Connect the custom domain (e.g. `app.alhamd.example`) in Firebase Hosting → automatic SSL.
4. Set `<html lang="ar" dir="rtl">`, Arabic `<title>` and meta description in `web/index.html`; add PWA manifest (Flutter generates one — edit name/colors/icons) so users can «إضافة إلى الشاشة الرئيسية».

### 12.5 Legal & policy (both stores require)
- **Privacy policy** (Arabic + English page, hosted at a public URL): states local-only data, anonymous analytics via Firebase, no accounts, no ads, contact email.
- Terms of use (simple), and an in-app «عن التطبيق» link to both.
- Religious-content note in the listing: «جميع النصوص الشرعية في التطبيق مُراجَعة من مختصّين» — this also preempts store-review questions.

### 12.6 Release checklist (every release)
- [ ] `dart run tool/validate_content.dart` passes on the release branch
- [ ] CI green (analyze, tests, web build)
- [ ] Manual QA checklist §11.4 done
- [ ] Version bumped (`pubspec.yaml`)
- [ ] Release notes written in Arabic
- [ ] Android: AAB uploaded → staged rollout 20% → 100% after 48h of clean vitals
- [ ] iOS: TestFlight pass → submit with phased release ON
- [ ] Web deployed and smoke-tested on mobile Safari + Chrome
- [ ] Tag the git release; archive the exact `blessings_ar.json` shipped

---

## 13. Post-MVP Roadmap (do not build now — design for it)

1. **Content growth:** 60 → 120 → 365 blessings (remote-config or in-app content updates so new blessings don't require store releases — e.g. download a newer signed `blessings_ar.json` over HTTPS, validated against the same schema).
2. **Podcast integration:** `relatedPodcastEpisode` field already exists — embed audio player (`just_audio`) linking each blessing to its «الحمد» episode.
3. **Web push** (FCM) for the web version's daily reminder.
4. **Journal export / backup** (local file first; optional encrypted cloud later — would introduce accounts, decide deliberately).
5. **Widgets** (Android home-screen / iOS WidgetKit): آية اليوم + نعمة اليوم.
6. **Ramadan mode:** themed content sequence + gift-box product tie-in.
7. **B2B/white-label** considerations only after retention proves out.

---

## 14. Definition of Done — MVP

The MVP is complete when: a user can install the app on Android, iOS, or open it on the web, see نعمة اليوم in fully correct Arabic RTL UI, complete an immersive استشعار القيمة reflection, write and save a hamd entry to سجل الحمد, see their مداومة framed as محاسبة النفس, and receive a daily local notification (mobile) — entirely offline, with 30–60 scholar-approved blessings, zero analyzer warnings, green CI, and the §11.4 checklist signed off.

**والحمد لله الذي بنعمته تتم الصالحات.**
