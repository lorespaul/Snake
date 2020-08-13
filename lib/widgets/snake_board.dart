import 'package:Snake/controllers/snake_node_controller.dart';
import 'package:flutter/cupertino.dart';

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
  int _length;
  int _maxLength;

  @override
  void initState() {
    super.initState();
    _length = widget.length;
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
          margin: EdgeInsets.only(top: 10),
        ),
        Text('Legth: $_length'),
        Container(
          margin: EdgeInsets.only(top: 5),
        ),
        Text('Max legth: $_maxLength'),
      ],
    );
  }
}
