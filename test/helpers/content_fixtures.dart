import 'package:alhamd/data/models/blessing.dart';

/// Minimal valid blessing JSON for tests; override fields as needed.
Map<String, Object?> blessingJson({
  String id = 'blessing_x',
  int order = 1,
  String reviewStatus = 'approved',
  Map<String, Object?>? quran,
  Map<String, Object?>? hadith,
  List<Map<String, Object?>>? steps,
}) {
  return {
    'id': id,
    'order': order,
    'category': 'din',
    'categoryLabel': 'نعم الدين',
    'title': 'عنوان',
    'shortTitle': 'قصير',
    'openingLine': 'سطر افتتاحي',
    'istisharSteps': steps ??
        [
          {'step': 1, 'type': 'ground', 'text': 'خطوة', 'durationSec': 5},
          {'step': 2, 'type': 'hamd', 'text': 'حمد', 'durationSec': 5},
        ],
    'reviewStatus': reviewStatus,
    'contentVersion': 1,
    'quran': ?quran,
    'hadith': ?hadith,
  };
}

Blessing makeBlessing({
  String id = 'blessing_x',
  int order = 1,
  String reviewStatus = 'approved',
}) {
  return Blessing.fromJson(
    blessingJson(id: id, order: order, reviewStatus: reviewStatus),
  );
}
