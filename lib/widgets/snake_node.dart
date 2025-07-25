import 'package:snake/controllers/snake_node_controller.dart';
import 'package:snake/models/cell.dart';
import 'package:snake/models/enums/side.dart';
import 'package:flutter/material.dart';

class SnakeNode extends StatefulWidget {
  SnakeNode({
    required Key key,
    required this.controller,
    required this.row,
    required this.column,
    required this.width,
    required this.height,
    required this.grid,
    required this.snake,
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

  late Color _color;
  late List<List<Color>> _grid;
  late List<Cell> _snake;
  late int _snakeIndex;

  final Cell _cell;
  final int _maxRow;
  final int _maxColumn;

  bool _lose = false;

  static const double SNAKE_BORDER_WIDTH = 2.5;
  static final Color _snakeBorderColor = Colors.green[700]!;

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
      (List<List<Color>> grid, List<Cell> snake, bool lose) {
        _snake = snake;
        _lose = lose;
        var color = grid[widget.row][widget.column];
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

  BorderSide _getBorderSide(
      Side side, Cell? previous, Cell? next, Color background) {
    var white = false;
    switch (side) {
      case Side.top:
        white = (previous != null &&
                (previous.row == widget.row - 1 ||
                    (previous.row == _maxRow && widget.row == 0)) &&
                previous.column == widget.column) ||
            (next != null &&
                (next.row == widget.row - 1 ||
                    (next.row == _maxRow && widget.row == 0)) &&
                next.column == widget.column);
        break;
      case Side.bottom:
        white = (previous != null &&
                (previous.row == widget.row + 1 ||
                    (previous.row == 0 && widget.row == _maxRow)) &&
                previous.column == widget.column) ||
            (next != null &&
                (next.row == widget.row + 1 ||
                    (next.row == 0 && widget.row == _maxRow)) &&
                next.column == widget.column);
        break;
      case Side.left:
        white = (previous != null &&
                (previous.column == widget.column - 1 ||
                    (previous.column == _maxColumn && widget.column == 0)) &&
                previous.row == widget.row) ||
            (next != null &&
                (next.column == widget.column - 1 ||
                    (next.column == _maxColumn && widget.column == 0)) &&
                next.row == widget.row);
        break;
      case Side.right:
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
      return BorderSide(color: background, width: 0);
    }
    return BorderSide(
      color: _snakeBorderColor,
      width: SNAKE_BORDER_WIDTH,
    );
  }

  BoxBorder _getBoxBorders(Color background) {
    if (_snakeIndex != -1) {
      var previous = _snakeIndex - 1 >= 0 ? _snake[_snakeIndex - 1] : null;
      var next =
          _snakeIndex + 1 < _snake.length ? _snake[_snakeIndex + 1] : null;
      return Border(
        top: _getBorderSide(Side.top, previous, next, background),
        bottom: _getBorderSide(Side.bottom, previous, next, background),
        left: _getBorderSide(Side.left, previous, next, background),
        right: _getBorderSide(Side.right, previous, next, background),
      );
    } else if (_color == Colors.red[300]) {
      return Border.all(
        color: Colors.red[600]!,
        width: SNAKE_BORDER_WIDTH,
      );
    } else {
      return Border.all(
        color: _color == Colors.black ? Colors.grey[800]! : _color,
        width: 0,
      );
    }
  }

  bool _isHead() {
    return _snakeIndex == _snake.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    var text = _isHead() ? 'XX' : '';
    var background = _color == Colors.white
        ? !_lose
            ? _color
            : Colors.red[200]!
        : _color;
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: background,
        border: _getBoxBorders(background),
      ),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          text,
          style: TextStyle(
            color: !_lose ? Colors.black : Colors.red[600],
          ),
        ),
      ),
    );
  }
}
