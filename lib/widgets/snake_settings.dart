import 'package:snake/models/enums/snake_speed.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:uuid/uuid.dart';

class SnakeSettings extends StatefulWidget {
  SnakeSettings({
    required Key key,
    required this.defaultRows,
    required this.defaultColumns,
    required this.defaultSpeed,
    required this.defaultAnimated,
    required this.rows,
    required this.columns,
    required this.speed,
    required this.animated,
    required this.onSettingChange,
    required this.onCancel,
    required this.onApply,
  }) : super(key: key);

  final int defaultRows;
  final int defaultColumns;
  final SnakeSpeed defaultSpeed;
  final bool defaultAnimated;

  final int rows;
  final int columns;
  final SnakeSpeed speed;
  final bool animated;
  final Function(SnakeSettingType, Object) onSettingChange;
  final Function onCancel;
  final Function onApply;

  @override
  _SnakeSettingsState createState() => _SnakeSettingsState();
}

class _SnakeSettingsState extends State<SnakeSettings> {
  late int _rows;
  late int _columns;
  late SnakeSpeed _snakeSpeed;
  late bool _animated;

  late bool _blockAxis;

  late String _rowsKey;
  late String _columnsKey;

  static const double CONTAINER_HEIGHT = 50.0;
  static const int MIN_DIMENSION = 10;
  static const int MAX_DIMENSION = 40;

  @override
  void initState() {
    _rows = widget.rows;
    _columns = widget.columns;
    _snakeSpeed = widget.speed;
    _animated = widget.animated;
    _blockAxis = _rows == _columns;
    _initKeys();
    super.initState();
  }

  _initKeys() {
    _rowsKey = Uuid().v1();
    _columnsKey = Uuid().v1();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: Wrap(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 90,
                              height: CONTAINER_HEIGHT,
                              padding: EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,
                              child: Text('Rows'),
                            ),
                            Container(
                              height: 35,
                              margin: EdgeInsets.all(15),
                              child: NumberPicker(
                                key: Key(_rowsKey),
                                axis: Axis.horizontal,
                                haptics: true,
                                // listViewWidth: 150,
                                value: _rows,
                                minValue: MIN_DIMENSION,
                                maxValue: MAX_DIMENSION,
                                onChanged: (val) {
                                  setState(() {
                                    _rows = val;
                                    if (_blockAxis) {
                                      _columns = val;
                                      _columnsKey = Uuid().v1();
                                    }
                                  });
                                },
                              ),
                            ),
                            Container(width: 30),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 90,
                              height: CONTAINER_HEIGHT,
                              padding: EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,
                              child: Text('Columns'),
                            ),
                            Container(
                              height: 35,
                              margin: EdgeInsets.all(15),
                              child: NumberPicker(
                                key: Key(_columnsKey),
                                axis: Axis.horizontal,
                                haptics: true,
                                // listViewWidth: 150,
                                value: _columns,
                                minValue: MIN_DIMENSION,
                                maxValue: MAX_DIMENSION,
                                onChanged: (val) {
                                  setState(() {
                                    _columns = val;
                                    if (_blockAxis) {
                                      _rows = val;
                                      _rowsKey = Uuid().v1();
                                    }
                                  });
                                },
                              ),
                            ),
                            Container(width: 30),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 90,
                              height: 60,
                              padding: EdgeInsets.only(right: 20),
                              margin: EdgeInsets.only(right: 10),
                              alignment: Alignment.centerRight,
                              child: Text('Block axis'),
                            ),
                            Container(
                              height: 60,
                              child: Switch(
                                value: _blockAxis,
                                onChanged: (val) => setState(() {
                                  _blockAxis = val;
                                }),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 90,
                              height: CONTAINER_HEIGHT,
                              padding: EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,
                              child: Text('Speed'),
                            ),
                            Container(
                              height: 35,
                              margin: EdgeInsets.all(15),
                              child: DropdownButton<SnakeSpeed>(
                                underline: Container(),
                                dropdownColor: Colors.white,
                                items: SnakeSpeed.values.map((SnakeSpeed e) {
                                  var text = '';
                                  switch (e) {
                                    case SnakeSpeed.slow:
                                      text = 'Slow';
                                      break;
                                    case SnakeSpeed.medium:
                                      text = 'Medium';
                                      break;
                                    case SnakeSpeed.fast:
                                      text = 'Fast';
                                      break;
                                  }
                                  return DropdownMenuItem<SnakeSpeed>(
                                    value: e,
                                    child: Text(text),
                                  );
                                }).toList(),
                                value: _snakeSpeed,
                                onChanged: (val) => setState(
                                  () => _snakeSpeed = val!,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 90,
                              height: 65,
                              padding: EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,
                              child: Text('Animated'),
                            ),
                            Container(
                              height: 60,
                              child: Switch(
                                value: _animated,
                                onChanged: (val) => setState(() {
                                  _animated = val;
                                }),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 85,
                            ),
                            Container(
                              height: 60,
                              padding: EdgeInsets.all(17),
                              child: ElevatedButton(
                                child: Text('Reset defaults'),
                                onPressed: () => setState(
                                  () {
                                    _rows = widget.defaultRows;
                                    _columns = widget.defaultColumns;
                                    _snakeSpeed = widget.defaultSpeed;
                                    _animated = widget.defaultAnimated;
                                    _blockAxis = true;
                                    _initKeys();
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 30, right: 20),
                      child: ElevatedButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          widget.onCancel();
                        },
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 30),
                      child: ElevatedButton(
                        child: Text('Apply'),
                        onPressed: () {
                          widget.onSettingChange(
                            SnakeSettingType.rows,
                            _rows,
                          );
                          widget.onSettingChange(
                            SnakeSettingType.columns,
                            _columns,
                          );
                          widget.onSettingChange(
                            SnakeSettingType.speed,
                            _snakeSpeed,
                          );
                          widget.onSettingChange(
                            SnakeSettingType.animated,
                            _animated,
                          );
                          widget.onApply();
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum SnakeSettingType {
  rows,
  columns,
  speed,
  animated,
}
