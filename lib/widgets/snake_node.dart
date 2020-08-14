import 'package:Snake/controllers/snake_node_controller.dart';
import 'package:Snake/widgets/snake_grid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SnakeNode extends StatefulWidget {
  SnakeNode({
    Key key,
    @required this.controller,
    @required this.row,
    @required this.column,
    @required this.width,
    @required this.height,
    @required this.grid,
    @required this.snake,
  }) : super(key: key);

  final SnakeNodeController controller;
  final int row;
  final int column;
  final double width;
  final double height;
  final List<List<Color>> grid;
  final List<Cell> snake;

  @override
  _SnakeNodeState createState() =>
      _SnakeNodeState(grid.length - 1, grid[0].length - 1, Cell(row, column));
}

class _SnakeNodeState extends State<SnakeNode> {
  _SnakeNodeState(this._maxRow, this._maxColumn, this._cell);

  Color _color;
  List<List<Color>> _grid;
  List<Cell> _snake;
  int _snakeIndex;

  final Cell _cell;
  final int _maxRow;
  final int _maxColumn;

  static const double SNAKE_BORDER_WIDTH = 2.5;
  static final Color _snakeBorderColor = Colors.green[700];

  @override
  void initState() {
    super.initState();
    _grid = widget.grid;
    _snake = widget.snake;
    _updateSnakeIndex();
    var color = _grid[widget.row][widget.column];
    _color = color;
    widget.controller.addListener(
      widget.row,
      widget.column,
      (List<List<Color>> grid, List<Cell> snake) {
        var color = grid[widget.row][widget.column];
        _snake = snake;
        if (_color != color || color == Colors.white) {
          _updateSnakeIndex();
          setState(
            () => _color = color,
          );
        }
      },
    );
  }

  void _updateSnakeIndex() {
    _snakeIndex = _snake.indexOf(_cell);
  }

  BorderSide _getBorderSide(_Side side, Cell previous, Cell next) {
    var white = false;
    switch (side) {
      case _Side.top:
        white = (previous != null &&
                (previous.row == widget.row - 1 ||
                    (previous.row == _maxRow && widget.row == 0)) &&
                previous.column == widget.column) ||
            (next != null &&
                (next.row == widget.row - 1 ||
                    (next.row == _maxRow && widget.row == 0)) &&
                next.column == widget.column);
        break;
      case _Side.bottom:
        white = (previous != null &&
                (previous.row == widget.row + 1 ||
                    (previous.row == 0 && widget.row == _maxRow)) &&
                previous.column == widget.column) ||
            (next != null &&
                (next.row == widget.row + 1 ||
                    (next.row == 0 && widget.row == _maxRow)) &&
                next.column == widget.column);
        break;
      case _Side.left:
        white = (previous != null &&
                (previous.column == widget.column - 1 ||
                    (previous.column == _maxColumn && widget.column == 0)) &&
                previous.row == widget.row) ||
            (next != null &&
                (next.column == widget.column - 1 ||
                    (next.column == _maxColumn && widget.column == 0)) &&
                next.row == widget.row);
        break;
      case _Side.right:
        white = (previous != null &&
                (previous.column == widget.column + 1 ||
                    (previous.column == 0 && widget.column == _maxColumn)) &&
                previous.row == widget.row) ||
            (next != null &&
                (next.column == widget.column + 1 ||
                    (next.column == 0 && widget.column == _maxColumn)) &&
                next.row == widget.row);
        break;
    }
    if (white) {
      return BorderSide(color: Colors.white, width: 0);
    }
    return BorderSide(
      color: _snakeBorderColor,
      width: SNAKE_BORDER_WIDTH,
    );
  }

  BoxBorder _getBoxBorders() {
    if (_snakeIndex != -1) {
      var previous = _snakeIndex - 1 >= 0 ? _snake[_snakeIndex - 1] : null;
      var next =
          _snakeIndex + 1 < _snake.length ? _snake[_snakeIndex + 1] : null;
      return Border(
        top: _getBorderSide(_Side.top, previous, next),
        bottom: _getBorderSide(_Side.bottom, previous, next),
        left: _getBorderSide(_Side.left, previous, next),
        right: _getBorderSide(_Side.right, previous, next),
      );
    } else if (_color == Colors.red[300]) {
      return Border.all(
        color: Colors.red[600],
        width: SNAKE_BORDER_WIDTH,
      );
    } else {
      return Border.all(
        color: _color == Colors.black ? Colors.grey[700] : _color,
        width: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var text = _snakeIndex == _snake.length - 1 ? 'XX' : '';
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: _color,
        border: _getBoxBorders(),
      ),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(text),
      ),
    );
  }
}

enum _Side {
  top,
  bottom,
  left,
  right,
}
