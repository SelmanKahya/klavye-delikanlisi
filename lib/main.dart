import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyAppHome(),
    );
  }
}

class MyAppHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppHomeState();
  }
}

class _MyAppHomeState extends State<MyAppHome> {
  String userName = "";
  int typedCharLength = 0;
  String lorem =
      '                                      Lorem ipsum dolor sit amet, adipiscing elit, sed dosmod temr ut labore et dolore magna aliqua. Phasellus vestibulum lorem sed risus ultricies tristique nulla aliquet. Adipiscing commodo elit at imperdiet dui accumsan. Tincidunt vitae semper quis lectus nulla at volutpat diam ut. Laoreet suspendisse interdum consectetur libero. In nulla posuere sollicitudin aliquam ultrices sagittis orci a. In ante metus dictum at tempor commodo ullamcorper a. Tempus iaculis urna id volutpat lacus laoreet non curabitur. Natoque penatibus et magnis dis. Mattis enim ut tellus elementum sagittis vitae et leo. Ut placerat orci nulla pellentesque dignissim enim sit. Purus sit amet volutpat consequat mauris nunc congue.'
          .toLowerCase()
          .replaceAll(',', '')
          .replaceAll('.', '');

  int step = 0;
  int lastTypedAt;

  void updateLastTypedAt() {
    this.lastTypedAt = DateTime.now().millisecondsSinceEpoch;
  }

  void onType(String value) {
    updateLastTypedAt();
    String trimmedValue = lorem.trimLeft();
    setState(() {
      if (trimmedValue.indexOf(value) != 0) {
        step = 2;
      } else {
        typedCharLength = value.length;
      }
    });
  }

  void onUserNameType(String value) {
    setState(() {
      this.userName = value.substring(0, 3);
    });
  }

  void resetGame() {
    setState(() {
      typedCharLength = 0;
      step = 1;
    });
  }

  void onStartClick() {
    setState(() {
      updateLastTypedAt();
      step++;
    });
    var timer = Timer.periodic(new Duration(seconds: 1), (timer) async {
      int now = DateTime.now().millisecondsSinceEpoch;

      setState(() {
        if (step == 1 && now - lastTypedAt > 4000) {
          // GAME OVER
          step++;
        }
      });
      if (step != 1) {
        await http.post(
            "https://klavye-delikanlisi-api.herokuapp.com/users/score",
            body: {
              'userName': userName,
              'score': typedCharLength.toString(),
            });
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var shownWidget;

    if (step == 0)
      shownWidget = <Widget>[
        Text('Oyuna hosgeldin, coronadan kacmaya hazir misin?'),
        Container(
          padding: EdgeInsets.all(20),
          child: TextField(
            onChanged: onUserNameType,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Ismin nedir klavye delikanlisi?',
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 10),
          child: RaisedButton(
            child: Text('BASLA!'),
            onPressed: userName.length == 0 ? null : onStartClick,
          ),
        ),
      ];
    else if (step == 1)
      shownWidget = <Widget>[
        Text('$typedCharLength'),
        Container(
          height: 40,
          child: Marquee(
            text: lorem,
            style: TextStyle(fontSize: 24, letterSpacing: 2),
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            blankSpace: 20.0,
            velocity: 125,
            startPadding: 0,
            accelerationDuration: Duration(seconds: 20),
            accelerationCurve: Curves.ease,
            decelerationDuration: Duration(milliseconds: 500),
            decelerationCurve: Curves.easeOut,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
          child: TextField(
            autofocus: true,
            onChanged: onType,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Yaz bakalım',
            ),
          ),
        )
      ];
    else
      shownWidget = <Widget>[
        Text('Coronadan kacamadin, skorun: $typedCharLength'),
        RaisedButton(
          child: Text('Yeniden dene!'),
          onPressed: resetGame,
        )
      ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Klavye Delikanlısı'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: shownWidget,
        ),
      ),
    );
  }
}
