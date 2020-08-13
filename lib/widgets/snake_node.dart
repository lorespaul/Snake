import 'package:Snake/controllers/snake_node_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SnakeNode extends StatefulWidget {
  SnakeNode({Key key, this.controller, this.row, this.column, this.color})
      : super(key: key);
  final SnakeNodeController controller;
  final int row;
  final int column;
  final Color color;

  @override
  _SnakeNodeState createState() => _SnakeNodeState();
}

class _SnakeNodeState extends State<SnakeNode> {
  Color _color;

  @override
  void initState() {
    super.initState();
    if (widget.color != null)
      _color = widget.color;
    else
      _color = Colors.black;
    if (widget.controller != null) {
      widget.controller.addListener(
        widget.row,
        widget.column,
        (Color color) {
          if (_color != color) {
            setState(
              () => _color = color,
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: _color,
        border: Border.all(
          color: _color == Colors.black ? Colors.grey[700] : _color,
          width: 1,
        ),
      ),
    );
  }
}
