import 'package:app_launcher/desktop/entries.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// mamo reda 200 filov k jih je treba hitr sparasat pa searchat
// k se odpre mors hitr parsat ampak user ze lahko umes tipka
// user lahko aktivira piton mode z !p al pa shift enter

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Launcher',
      theme: ThemeData(
        backgroundColor: Colors.white,
        primarySwatch: Colors.blue,
      ),
      home: Center(
        // child: Text('asdf'),
        child: RaisedButton(
          child: Text('Linux app launcher.'),
          onPressed: () async {
            final stopwatch = Stopwatch()..start();
            DesktopEntries entries = new DesktopEntries();
            await entries.parse();
            print('Parse executed in ${stopwatch.elapsed} and found ${entries.entries.length} entries.');
          },
        ),
      ),
    );
  }
}
