import 'package:Snake/controllers/snake_node_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SnakeBoard extends StatefulWidget {
  SnakeBoard({
    Key key,
    this.length,
    this.maxLength,
    this.controller,
  }) : super(key: key);
  final int length;
  final int maxLength;
  final SnakeNodeController controller;

  @override
  _SnakeBoardState createState() => _SnakeBoardState();
}

class _SnakeBoardState extends State<SnakeBoard> {
  int _baseLength;
  int _length;
  int _maxLength;

  @override
  void initState() {
    super.initState();
    _baseLength = widget.length;
    _length = widget.length;
    if (_length > widget.maxLength)
      _maxLength = _length;
    else
      _maxLength = widget.maxLength;
    if (widget.controller != null) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Container(
                width: 15,
                height: 15,
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.red[300],
                  border: Border.all(color: Colors.red[600], width: 2.5),
                ),
              ),
              Container(
                width: 25,
                margin: EdgeInsets.only(right: 5),
                child: Text('${_length - _baseLength}'),
              ),
              Container(
                margin: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.favorite,
                  color: Colors.amber[300],
                  size: 20,
                ),
              ),
              Container(
                width: 25,
                child: Text('${_maxLength - _baseLength}'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
