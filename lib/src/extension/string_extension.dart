import 'package:inflection2/inflection2.dart';

extension StringExtension on String {
  String get plural => pluralize(this);
}
