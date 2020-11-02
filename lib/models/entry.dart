import 'package:flutter/foundation.dart';

class Entry {
  String name;
  String genericName;
  String comment;
  String icon;
  String launchName;
  List<String> categories;
  List<String> keywords;

  Entry({
    @required this.name,
    @required this.launchName,
    @required this.icon,
    this.genericName,
    this.comment,
    this.categories,
    this.keywords,
  });
}
