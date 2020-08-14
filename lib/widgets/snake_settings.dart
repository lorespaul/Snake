import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import './snake_grid.dart';

class SnakeSettings extends StatefulWidget {
  SnakeSettings({
    Key key,
    @required this.defaultRows,
    @required this.defaultColumns,
    @required this.defaultSpeed,
    @required this.rows,
    @required this.columns,
    @required this.speed,
    @required this.onSettingChange,
    @required this.onCancel,
    @required this.onApply,
  }) : super(key: key);

  final int defaultRows;
  final int defaultColumns;
  final SnakeSpeed defaultSpeed;

  final int rows;
  final int columns;
  final SnakeSpeed speed;
  final Function(SnakeSettingType, Object) onSettingChange;
  final Function onCancel;
  final Function onApply;

  @override
  _SnakeSettingsState createState() => _SnakeSettingsState();
}

class _SnakeSettingsState extends State<SnakeSettings> {
  int _rows;
  int _columns;
  SnakeSpeed _snakeSpeed;

  String _rowsKey;
  String _columnsKey;

  @override
  void initState() {
    _rows = widget.rows;
    _columns = widget.columns;
    _snakeSpeed = widget.speed;
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 90,
                              padding: EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,
                              child: Text('Rows'),
                            ),
                            Container(
                              width: 70,
                              margin: EdgeInsets.all(15),
                              child: TextFormField(
                                key: Key(_rowsKey),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 1,
                                    horizontal: 15,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                initialValue: _rows.toString(),
                                onChanged: (val) {
                                  var intVal = int.parse(val);
                                  setState(() => _rows = intVal);
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
                              padding: EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,
                              child: Text('Columns'),
                            ),
                            Container(
                              width: 70,
                              margin: EdgeInsets.all(15),
                              child: TextFormField(
                                key: Key(_columnsKey),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 1,
                                    horizontal: 15,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                initialValue: _columns.toString(),
                                onChanged: (val) {
                                  var intVal = int.parse(val);
                                  setState(() => _columns = intVal);
                                },
                              ),
                            ),
                            Container(width: 30),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 70,
                              padding: EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,
                              child: Text('Speed'),
                            ),
                            Container(
                              margin: EdgeInsets.all(15),
                              child: DropdownButton<SnakeSpeed>(
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
                                  () => _snakeSpeed = val,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(15),
                              child: RaisedButton(
                                child: Text('Reset defaults'),
                                onPressed: () => setState(
                                  () {
                                    _rows = widget.defaultRows;
                                    _columns = widget.defaultColumns;
                                    _snakeSpeed = widget.defaultSpeed;
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
                      child: RaisedButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          widget.onCancel();
                        },
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 30),
                      child: RaisedButton(
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
}
