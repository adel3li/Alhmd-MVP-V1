import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar')];

  /// App name
  ///
  /// In ar, this message translates to:
  /// **'الحمد'**
  String get appTitle;

  /// No description provided for @onboardingTagline.
  ///
  /// In ar, this message translates to:
  /// **'دقيقتان كل يوم… تُحيي بهما قلبك بالشكر'**
  String get onboardingTagline;

  /// No description provided for @onboardingStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get onboardingStart;

  /// No description provided for @onboardingIstisharTitle.
  ///
  /// In ar, this message translates to:
  /// **'استشعار القيمة'**
  String get onboardingIstisharTitle;

  /// No description provided for @onboardingIstisharBody.
  ///
  /// In ar, this message translates to:
  /// **'طريقةٌ قرآنيةٌ في التأمّل: تتخيّل بصدقٍ فقدَ نعمةٍ تعيش بها كلَّ يوم، ثم تعود إليها بقلبٍ يراها من جديد، فيمتلئ شكرًا وحمدًا.'**
  String get onboardingIstisharBody;

  /// No description provided for @onboardingUnderstood.
  ///
  /// In ar, this message translates to:
  /// **'فهمت'**
  String get onboardingUnderstood;

  /// No description provided for @onboardingNotifTitle.
  ///
  /// In ar, this message translates to:
  /// **'نذكّرك بنعمةٍ واحدةٍ كل يوم. متى يناسبك؟'**
  String get onboardingNotifTitle;

  /// No description provided for @onboardingPickTime.
  ///
  /// In ar, this message translates to:
  /// **'اختر وقت التذكير'**
  String get onboardingPickTime;

  /// No description provided for @onboardingSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطّي'**
  String get onboardingSkip;

  /// No description provided for @onboardingEnableReminder.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل التذكير'**
  String get onboardingEnableReminder;

  /// No description provided for @greeting.
  ///
  /// In ar, this message translates to:
  /// **'السلام عليكم'**
  String get greeting;

  /// No description provided for @todaysBlessing.
  ///
  /// In ar, this message translates to:
  /// **'نعمة اليوم'**
  String get todaysBlessing;

  /// No description provided for @reflectCta.
  ///
  /// In ar, this message translates to:
  /// **'استشعر النعمة'**
  String get reflectCta;

  /// No description provided for @reflectAgainCta.
  ///
  /// In ar, this message translates to:
  /// **'أعد الاستشعار'**
  String get reflectAgainCta;

  /// No description provided for @completedToday.
  ///
  /// In ar, this message translates to:
  /// **'حمدتَ اللهَ اليوم'**
  String get completedToday;

  /// No description provided for @noContentAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد محتوى منشور بعد'**
  String get noContentAvailable;

  /// No description provided for @journalTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل الحمد'**
  String get journalTitle;

  /// No description provided for @consistencyTitle.
  ///
  /// In ar, this message translates to:
  /// **'المداومة'**
  String get consistencyTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @quranSurahRef.
  ///
  /// In ar, this message translates to:
  /// **'سورة {surah} — الآية {ayah}'**
  String quranSurahRef(String surah, String ayah);

  /// No description provided for @paraphraseMarker.
  ///
  /// In ar, this message translates to:
  /// **'بمعناه'**
  String get paraphraseMarker;

  /// No description provided for @reflectionNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get reflectionNext;

  /// No description provided for @reflectionExit.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get reflectionExit;

  /// No description provided for @hamdButton.
  ///
  /// In ar, this message translates to:
  /// **'الحمد لله'**
  String get hamdButton;

  /// No description provided for @completionWriteHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب حمدك…'**
  String get completionWriteHint;

  /// No description provided for @saveToJournal.
  ///
  /// In ar, this message translates to:
  /// **'حفظ في سجل الحمد'**
  String get saveToJournal;

  /// No description provided for @later.
  ///
  /// In ar, this message translates to:
  /// **'لاحقًا'**
  String get later;

  /// No description provided for @journalEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'سجلُّك ما زال صفحةً بيضاء… ابدأ اليوم باستشعار نعمة'**
  String get journalEmptyBody;

  /// No description provided for @journalEmptyCta.
  ///
  /// In ar, this message translates to:
  /// **'استشعر نعمة اليوم'**
  String get journalEmptyCta;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @deleteEntryTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف هذا التدوين؟'**
  String get deleteEntryTitle;

  /// No description provided for @deleteEntryBody.
  ///
  /// In ar, this message translates to:
  /// **'سيُحذف هذا التدوين من سجلّك ولا يمكن استرجاعه.'**
  String get deleteEntryBody;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @consistencySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'هذه صفحتُك مع نفسك… لا سِباقَ مع أحد'**
  String get consistencySubtitle;

  /// No description provided for @consistencyDayCompletedSemantics.
  ///
  /// In ar, this message translates to:
  /// **'يومٌ حمدتَ اللهَ فيه'**
  String get consistencyDayCompletedSemantics;

  /// No description provided for @settingsNotificationTime.
  ///
  /// In ar, this message translates to:
  /// **'وقت التذكير اليومي'**
  String get settingsNotificationTime;

  /// No description provided for @settingsNotificationToggle.
  ///
  /// In ar, this message translates to:
  /// **'التذكير اليومي'**
  String get settingsNotificationToggle;

  /// No description provided for @settingsNotificationWebNote.
  ///
  /// In ar, this message translates to:
  /// **'التذكير اليومي غير متاح في نسخة الويب حاليًا. افتح التطبيق كل يوم لتجد نعمة اليوم بانتظارك.'**
  String get settingsNotificationWebNote;

  /// No description provided for @settingsTheme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeAuto.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get settingsThemeAuto;

  /// No description provided for @settingsTextSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get settingsTextSize;

  /// No description provided for @settingsTextSizeNormal.
  ///
  /// In ar, this message translates to:
  /// **'عادي'**
  String get settingsTextSizeNormal;

  /// No description provided for @settingsTextSizeLarge.
  ///
  /// In ar, this message translates to:
  /// **'كبير'**
  String get settingsTextSizeLarge;

  /// No description provided for @settingsAbout.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get settingsAbout;

  /// No description provided for @settingsShare.
  ///
  /// In ar, this message translates to:
  /// **'شارك التطبيق'**
  String get settingsShare;

  /// No description provided for @aboutMission.
  ///
  /// In ar, this message translates to:
  /// **'«الحمد» تطبيقٌ يعينك على عادةٍ يوميةٍ قصيرة: أن تستشعر نعمةً واحدةً من نعم الله عليك ثم تحمده عليها من قلبك.'**
  String get aboutMission;

  /// No description provided for @aboutScholarNote.
  ///
  /// In ar, this message translates to:
  /// **'جميع النصوص الشرعية في التطبيق مُراجَعة من مختصّين، ولا يُنشر منها شيء قبل اعتماده.'**
  String get aboutScholarNote;

  /// No description provided for @aboutPrivacyNote.
  ///
  /// In ar, this message translates to:
  /// **'بياناتك تبقى على جهازك: لا حسابات، ولا إعلانات، ولا يغادر جهازَك إلا إحصاءاتُ استخدامٍ مجهولةُ الهوية.'**
  String get aboutPrivacyNote;

  /// No description provided for @aboutContentVersion.
  ///
  /// In ar, this message translates to:
  /// **'إصدار المحتوى: {version}'**
  String aboutContentVersion(String version);

  /// No description provided for @aboutPrivacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get aboutPrivacyPolicy;

  /// No description provided for @aboutPodcast.
  ///
  /// In ar, this message translates to:
  /// **'بودكاست «الحمد»'**
  String get aboutPodcast;

  /// No description provided for @shareAppText.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق «الحمد» — دقيقتان كل يوم تُحيي بهما قلبك بالشكر.'**
  String get shareAppText;

  /// No description provided for @notifChannelName.
  ///
  /// In ar, this message translates to:
  /// **'التذكير اليومي'**
  String get notifChannelName;

  /// No description provided for @notifChannelDesc.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرٌ يوميٌّ بنعمة اليوم'**
  String get notifChannelDesc;

  /// No description provided for @notifBody1.
  ///
  /// In ar, this message translates to:
  /// **'نعمةُ اليوم بانتظارك… دقيقتان تُحييان قلبك'**
  String get notifBody1;

  /// No description provided for @notifBody2.
  ///
  /// In ar, this message translates to:
  /// **'﴿وَإِن تَعُدُّوا نِعْمَةَ اللَّهِ لَا تُحْصُوهَا﴾ — استشعر نعمة اليوم'**
  String get notifBody2;

  /// No description provided for @notifBody3.
  ///
  /// In ar, this message translates to:
  /// **'عُد إلى قلبك دقيقتين… واستشعر نعمة اليوم'**
  String get notifBody3;

  /// No description provided for @timePickerConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حسنًا'**
  String get timePickerConfirm;

  /// No description provided for @commonClose.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get commonClose;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
