import 'dart:async';

import 'package:snake/widgets/animated_snake_grid.dart';
import 'package:snake/widgets/snake_grid.dart';
import 'package:snake/widgets/snake_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'models/enums/snake_speed.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
        canvasColor: Colors.transparent,
      ),
      home: MyHomePage(key: Key('HomePage'), title: 'Snake'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({required Key key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;
  static const int ROWS = 17;
  static const int COLUMNS = 17;
  static const SnakeSpeed SNAKE_SPEED = SnakeSpeed.medium;
  static const bool ANIMATED = false;

  late int _rows;
  late int _columns;
  late SnakeSpeed _snakeSpeed;
  late bool _animated;
  String _snakeKey = 'A';
  int _maxLength = 0;

  @override
  void initState() {
    _initDefaults();
    _snakeKey = Uuid().v1();
    super.initState();
  }

  void _initDefaults() {
    _rows = ROWS;
    _columns = COLUMNS;
    _snakeSpeed = SNAKE_SPEED;
    _animated = ANIMATED;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: _animated
              ? AnimatedSnakeGrid(
                  key: Key(_snakeKey),
                  rows: _rows,
                  columns: _columns,
                  speed: _snakeSpeed,
                  maxLength: _maxLength,
                  onStop: onStop,
                  onRestart: restart,
                  onOpenSettings: openSettingsModal,
                )
              : SnakeGrid(
                  key: Key(_snakeKey),
                  rows: _rows,
                  columns: _columns,
                  speed: _snakeSpeed,
                  maxLength: _maxLength,
                  onStop: onStop,
                  onRestart: restart,
                  onOpenSettings: openSettingsModal,
                ),
        ),
      ),
    );
  }

  void onStop(int length) {
    if (length > _maxLength) {
      _maxLength = length;
    }
  }

  void restart(int length) => setState(() {
        if (length > _maxLength) {
          _maxLength = length;
        }
        _snakeKey = Uuid().v1();
      });

  void openSettingsModal() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: SnakeSettings(
              key: Key('SnakeSettings'),
              defaultRows: ROWS,
              defaultColumns: COLUMNS,
              defaultSpeed: SNAKE_SPEED,
              defaultAnimated: ANIMATED,
              rows: _rows,
              columns: _columns,
              speed: _snakeSpeed,
              animated: _animated,
              onSettingChange: (
                SnakeSettingType type,
                Object value,
              ) {
                switch (type) {
                  case SnakeSettingType.rows:
                    _rows = value as int;
                    break;
                  case SnakeSettingType.columns:
                    _columns = value as int;
                    break;
                  case SnakeSettingType.speed:
                    _snakeSpeed = value as SnakeSpeed;
                    break;
                  case SnakeSettingType.animated:
                    bool boolValue = value as bool;
                    if (!_animated && boolValue)
                      _maxLength++;
                    else if (_animated && !boolValue) _maxLength--;
                    _animated = boolValue;
                    break;
                }
              },
              onCancel: () {
                Navigator.pop(
                  context,
                );
              },
              onApply: () {
                Navigator.pop(
                  context,
                  'Apply',
                );
              },
            ),
          ),
        );
      },
    ).then((value) {
      if (value == 'Apply') {
        Timer(
          const Duration(milliseconds: 200),
          () => setState(() {
            _snakeKey = Uuid().v1();
          }),
        );
      }
    });
  }
}
