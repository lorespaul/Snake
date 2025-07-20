import 'package:snake/controllers/abstract_snake_controller.dart';
import 'package:flutter/material.dart';

class SnakeBoard extends StatefulWidget {
  SnakeBoard({
    required Key key,
    required this.length,
    required this.maxLength,
    this.offset = 0,
    required this.controller,
  }) : super(key: key);
  final int length;
  final int maxLength;
  final int offset;
  final AbstractSnakeController controller;

  @override
  _SnakeBoardState createState() => _SnakeBoardState();
}

class _SnakeBoardState extends State<SnakeBoard> {
  late int _length;
  late int _maxLength;

  @override
  void initState() {
    super.initState();
    _length = widget.length;
    if (_length > widget.maxLength)
      _maxLength = _length;
    else
      _maxLength = widget.maxLength;
    widget.controller.addBoardListener(
      (int length, int maxLength) => setState(
        () {
          _length = length;
          if (length > maxLength)
            _maxLength = length;
          else
            _maxLength = maxLength;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var length = _length - widget.offset;
    if (length < 0) length = 0;
    var maxLength = _maxLength - widget.offset;
    if (maxLength < 0) maxLength = 0;
    return Column(
      children: [
        Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.only(top: 10, left: 6),
          child: Row(
            children: [
              Container(
                width: 15,
                height: 15,
                margin: EdgeInsets.only(right: 5),
                decoration: BoxDecoration(
                  color: Colors.red[300],
                  border: Border.all(color: Colors.red[600]!, width: 2.5),
                ),
              ),
              Container(
                width: 25,
                margin: EdgeInsets.only(right: 5),
                child: Text('$length'),
              ),
              Container(
                margin: EdgeInsets.only(right: 5),
                child: Icon(
                  Icons.flag,
                  color: Colors.amber[300],
                  size: 24,
                ),
              ),
              Container(
                width: 25,
                child: Text('$maxLength'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
