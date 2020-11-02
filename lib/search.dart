import 'package:app_launcher/desktop/entries.dart';
import 'package:app_launcher/models/app_state.dart';
import 'package:app_launcher/models/entry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:full_text_search/full_text_search.dart';
import 'package:full_text_search/term_search_result.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

const OutlineInputBorder transparentRoundedBorder = OutlineInputBorder(
    borderRadius: const BorderRadius.all(
  const Radius.circular(32.0),
));

class _SearchState extends State<Search> {
  List<Entry> _matchedEntries;

  void initState() {
    super.initState();
    _loadEntries();
  }

  _loadEntries() async {
    AppState appState = Provider.of<AppState>(context, listen: false);
    DesktopEntries desktopEntries = new DesktopEntries();
    await desktopEntries.parse();
    appState.updateEntries(desktopEntries.entries);
  }

  _filterEntries(List<Entry> entries, String q) async {
    if (q == null || q.length == 0) {
      _matchedEntries = null;
      return;
    }

    List<TermSearchResult> matches = await FullTextSearch(
      term: q,
      items: entries,
      isMatchAll: false,
      isStartsWith: false,
      tokenize: (Entry item) => [
        item.name,
        item.keywords.join(' '),
        item.genericName,
        item.categories.join(' '),
        item.comment
      ],
    ).execute();

    this.setState(() {
      _matchedEntries = List<Entry>.from(matches.map((e) => e.result).toList());
    });
  }

  Widget _getSearchBar(List<Entry> entries) {
    return new TextField(
      autofocus: true,
      textAlign: TextAlign.center,
      onChanged: (String q) => _filterEntries(entries, q),
      style: TextStyle(
        fontSize: 16,
      ),
      decoration: new InputDecoration(
          contentPadding: EdgeInsets.symmetric(),
          border: transparentRoundedBorder,
          focusedBorder: transparentRoundedBorder,
          enabledBorder: transparentRoundedBorder,
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(
              Icons.search,
              color: Colors.grey[900],
            ),
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.all(8),
          ),
          filled: true,
          hintStyle: new TextStyle(color: Colors.black),
          hintText: "Find your favourite app.",
          fillColor: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Entry> entries =
        context.select<AppState, List<Entry>>((appState) => appState.entries);

    return Card(
      color: Colors.black.withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        height: 300,
        width: 700,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
                padding: EdgeInsets.all(24),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 460),
                  child: _getSearchBar(entries),
                )),
            Text(
              _matchedEntries != null && _matchedEntries.length > 0
                  ? _matchedEntries[0].name
                  : 'asdf',
              style: TextStyle(color: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}
