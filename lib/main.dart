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
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: Container(
          width: 512,
          height: 200,
          color: Colors.grey[500].withOpacity(0.8),
          child: Center(
            child: FlatButton(
              child: Text('asdf'),
              onPressed: () => print('asdf'),
            ),
          ),
        ),
      ),
    );
  }
}
