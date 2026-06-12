// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'الحمد';

  @override
  String get onboardingTagline => 'دقيقتان كل يوم… تُحيي بهما قلبك بالشكر';

  @override
  String get onboardingStart => 'ابدأ';

  @override
  String get onboardingIstisharTitle => 'استشعار القيمة';

  @override
  String get onboardingIstisharBody =>
      'طريقةٌ قرآنيةٌ في التأمّل: تتخيّل بصدقٍ فقدَ نعمةٍ تعيش بها كلَّ يوم، ثم تعود إليها بقلبٍ يراها من جديد، فيمتلئ شكرًا وحمدًا.';

  @override
  String get onboardingUnderstood => 'فهمت';

  @override
  String get onboardingNotifTitle => 'نذكّرك بنعمةٍ واحدةٍ كل يوم. متى يناسبك؟';

  @override
  String get onboardingPickTime => 'اختر وقت التذكير';

  @override
  String get onboardingSkip => 'تخطّي';

  @override
  String get onboardingEnableReminder => 'تفعيل التذكير';

  @override
  String get greeting => 'السلام عليكم';

  @override
  String get todaysBlessing => 'نعمة اليوم';

  @override
  String get reflectCta => 'استشعر النعمة';

  @override
  String get reflectAgainCta => 'أعد الاستشعار';

  @override
  String get completedToday => 'حمدتَ اللهَ اليوم';

  @override
  String get noContentAvailable => 'لا يوجد محتوى منشور بعد';

  @override
  String get journalTitle => 'سجل الحمد';

  @override
  String get consistencyTitle => 'المداومة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String quranSurahRef(String surah, String ayah) {
    return 'سورة $surah — الآية $ayah';
  }

  @override
  String get paraphraseMarker => 'بمعناه';

  @override
  String get reflectionNext => 'التالي';

  @override
  String get reflectionExit => 'خروج';

  @override
  String get hamdButton => 'الحمد لله';

  @override
  String get completionWriteHint => 'اكتب حمدك…';

  @override
  String get saveToJournal => 'حفظ في سجل الحمد';

  @override
  String get later => 'لاحقًا';

  @override
  String get journalEmptyBody =>
      'سجلُّك ما زال صفحةً بيضاء… ابدأ اليوم باستشعار نعمة';

  @override
  String get journalEmptyCta => 'استشعر نعمة اليوم';

  @override
  String get delete => 'حذف';

  @override
  String get deleteEntryTitle => 'حذف هذا التدوين؟';

  @override
  String get deleteEntryBody =>
      'سيُحذف هذا التدوين من سجلّك ولا يمكن استرجاعه.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get consistencySubtitle => 'هذه صفحتُك مع نفسك… لا سِباقَ مع أحد';

  @override
  String get consistencyDayCompletedSemantics => 'يومٌ حمدتَ اللهَ فيه';

  @override
  String get settingsNotificationTime => 'وقت التذكير اليومي';

  @override
  String get settingsNotificationToggle => 'التذكير اليومي';

  @override
  String get settingsNotificationWebNote =>
      'التذكير اليومي غير متاح في نسخة الويب حاليًا. افتح التطبيق كل يوم لتجد نعمة اليوم بانتظارك.';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeAuto => 'تلقائي';

  @override
  String get settingsTextSize => 'حجم الخط';

  @override
  String get settingsTextSizeNormal => 'عادي';

  @override
  String get settingsTextSizeLarge => 'كبير';

  @override
  String get settingsAbout => 'عن التطبيق';

  @override
  String get settingsShare => 'شارك التطبيق';

  @override
  String get aboutMission =>
      '«الحمد» تطبيقٌ يعينك على عادةٍ يوميةٍ قصيرة: أن تستشعر نعمةً واحدةً من نعم الله عليك ثم تحمده عليها من قلبك.';

  @override
  String get aboutScholarNote =>
      'جميع النصوص الشرعية في التطبيق مُراجَعة من مختصّين، ولا يُنشر منها شيء قبل اعتماده.';

  @override
  String get aboutPrivacyNote =>
      'بياناتك تبقى على جهازك: لا حسابات، ولا إعلانات، ولا يغادر جهازَك إلا إحصاءاتُ استخدامٍ مجهولةُ الهوية.';

  @override
  String aboutContentVersion(String version) {
    return 'إصدار المحتوى: $version';
  }

  @override
  String get aboutPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get aboutPodcast => 'بودكاست «الحمد»';

  @override
  String get shareAppText =>
      'تطبيق «الحمد» — دقيقتان كل يوم تُحيي بهما قلبك بالشكر.';

  @override
  String get notifChannelName => 'التذكير اليومي';

  @override
  String get notifChannelDesc => 'تذكيرٌ يوميٌّ بنعمة اليوم';

  @override
  String get notifBody1 => 'نعمةُ اليوم بانتظارك… دقيقتان تُحييان قلبك';

  @override
  String get notifBody2 =>
      '﴿وَإِن تَعُدُّوا نِعْمَةَ اللَّهِ لَا تُحْصُوهَا﴾ — استشعر نعمة اليوم';

  @override
  String get notifBody3 => 'عُد إلى قلبك دقيقتين… واستشعر نعمة اليوم';

  @override
  String get timePickerConfirm => 'حسنًا';

  @override
  String get commonClose => 'إغلاق';
}
