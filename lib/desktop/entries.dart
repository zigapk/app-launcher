import 'dart:io';
import 'package:threading/threading.dart';
import 'package:ini/ini.dart';
import 'package:path/path.dart';

// TODO: this parser only uses default, non localized desktop entry values (see vlc.desktop for example)

// TODO: should also read directories from XDG config
const DIRECTORIES = [
  '/usr/share/applications/', // system wide
  '~/.local/share/applications', // current user
  '/var/lib/snapd/desktop/applications/', // snap
  '/var/lib/flatpak/exports/share/applications', // flatpak
  '~/.local/share/flatpak/exports/share/applications', // flatpak
];

const SECTION_DESKTOP_ENTRY = 'Desktop Entry';
const ITEM_NAME = 'Name';
const ITEM_GENERIC_NAME = 'GenericName';
const ITEM_TYPE = 'Type';
const ITEM_KEYWORDS = 'Keywords';
const ITEM_COMMENT = 'Comment';
const ITEM_CATEGORIES = 'Categories';
const ITEM_ICON = 'Icon';
const TYPE_APPLICATION = 'Application';

class DesktopEntries {
  List<Map<String, dynamic>> entries = new List<Map<String, dynamic>>();

  Future parse() async {
    for (String dir in DIRECTORIES) {
      await _parseDirectory(dir);
    }
  }

  Future _parseDirectory(String path) async {
    Directory dir = new Directory(path);
    if (!dir.existsSync()) return;

    // parse files async but wait for them to finish
    var threads = <Thread>[];
    for (final FileSystemEntity e in dir.listSync()) {
      // skip non .desktop files
      if (!e.path.endsWith('.desktop')) continue;

      // start new thread to parse this file
      Thread thread = new Thread(() => _parseFile(e.path));
      threads.add(thread);
      await thread.start();
    }

    // wait for all the threads to finish
    for (int i = 0; i < threads.length; ++i) {
      await threads[i].join();
    }
  }

  void _parseFile(String path) {
    File file = new File(path);
    if (!file.existsSync()) return;

    try {
      Config config = new Config.fromStrings(file.readAsLinesSync());
      if (!config.hasSection(SECTION_DESKTOP_ENTRY)) return;

      if (config.get(SECTION_DESKTOP_ENTRY, ITEM_TYPE) != TYPE_APPLICATION)
        return;

      String name, genericName, comment, icon;
      List<String> keywords = new List();
      List<String> categories = new List();

      // throw exception if name or icon does not exist
      name = config.get(SECTION_DESKTOP_ENTRY, ITEM_NAME);
      icon = config.get(SECTION_DESKTOP_ENTRY, ITEM_ICON);

      // get other options if they exist
      if (config.hasOption(SECTION_DESKTOP_ENTRY, ITEM_GENERIC_NAME))
        genericName = config.get(SECTION_DESKTOP_ENTRY, ITEM_GENERIC_NAME);
      if (config.hasOption(SECTION_DESKTOP_ENTRY, ITEM_COMMENT))
        comment = config.get(SECTION_DESKTOP_ENTRY, ITEM_COMMENT);
      if (config.hasOption(SECTION_DESKTOP_ENTRY, ITEM_KEYWORDS))
        keywords = config.get(SECTION_DESKTOP_ENTRY, ITEM_KEYWORDS).split(';');
      if (config.hasOption(SECTION_DESKTOP_ENTRY, ITEM_CATEGORIES))
        keywords =
            config.get(SECTION_DESKTOP_ENTRY, ITEM_CATEGORIES).split(';');

      // name of the desktop file without .desktop appendix to use for gtk-launch
      String launchable = basename(file.path);
      // all passed to this function already end with ".desktop", which is 8 characters long
      launchable = launchable.substring(0, launchable.length - 8);

      // add to list of entries
      entries.add({
        'name': name,
        'genericName': genericName,
        'comment': comment,
        'icon': icon,
        'keywords': keywords,
        'categories': categories,
        'launchable': launchable,
      });
    } catch (Exception) {
      // ignore failed files
    }
  }
}
