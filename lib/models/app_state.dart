import 'package:app_launcher/models/entry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // data stored in state

  // list of all boxes assigned to this user
  List<Entry> _entries;

  AppState() {
    _entries = new List<Entry>();
  }

  // update boxes from api response
  void updateEntries(List<Entry> entries) {
    _entries = entries;
    notifyListeners();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState && listEquals(_entries, other._entries);

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      _entries.map((t) => t.hashCode).reduce((hash, h) => hash ^ h);

  // getters
  List<Entry> get entries => _entries;

  int get numberOfEntries => _entries?.length;
}
