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

  bool _lose = false;
  double _animationValue;
  SnakeSide _snakeSide;
  Direction _direction;

  static const double SNAKE_BORDER_WIDTH = 2.5;
  static final Color _snakeBorderColor = Colors.green[700];

  @override
  void initState() {
    super.initState();
    _grid = widget.grid;
    _snake = widget.snake;
    _animationValue = 0.0;
    _direction = Direction.none;
    _updateSnakeIndex();
    _updateSnakeSide();
    var color = _grid[widget.row][widget.column];
    _color = color;
    widget.controller.addListener(
      widget.row,
      widget.column,
      (
        List<List<Color>> grid,
        List<Cell> snake,
        bool lose,
        double animationValue,
        Direction direction,
      ) {
        _snake = snake;
        _lose = lose;
        _animationValue = animationValue;
        if (_color == Colors.black) _direction = Direction.none;
        if (_isHead() || _isNextHead(direction)) _direction = direction;
        _updateSnakeSide();
        var color = grid[widget.row][widget.column];
        if (_color != color ||
            color == Colors.white ||
            _snakeSide == SnakeSide.nextHead) {
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

  void _updateSnakeSide() {
    _snakeSide = _isTail()
        ? SnakeSide.tail
        : _isHead()
            ? SnakeSide.head
            : _isNextHead(_direction) ? SnakeSide.nextHead : SnakeSide.none;
  }

  bool _isHead() {
    return _snakeIndex == _snake.length - 1;
  }

  bool _isNextHead(Direction direction) {
    var head = _snake.last;
    switch (direction) {
      case Direction.left:
        return widget.row == head.row &&
            (widget.column == head.column - 1 ||
                (head.column == 0 && widget.column == _maxColumn));
      case Direction.up:
        return widget.column == head.column &&
            (widget.row == head.row - 1 ||
                (head.row == 0 && widget.row == _maxRow));
      case Direction.right:
        return widget.row == head.row &&
            (widget.column == head.column + 1 ||
                (head.column == _maxColumn && widget.column == 0));
      case Direction.down:
        return widget.column == head.column &&
            (widget.row == head.row + 1 ||
                (head.row == _maxRow && widget.row == 0));
      default:
        return false;
    }
  }

  bool _isTail() {
    return _snakeIndex == 0;
  }

  BorderSide _getBorderSide(
      _Side side, Cell previous, Cell next, Color background) {
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
      return BorderSide(color: background, width: 0);
    }
    return BorderSide(
      color: _snakeBorderColor,
      width: SNAKE_BORDER_WIDTH,
    );
  }

  Border _getBorders(Color background) {
    if (_snakeIndex != -1 || _snakeSide == SnakeSide.nextHead) {
      Cell previous, next;
      if (_snakeSide == SnakeSide.nextHead) {
        previous = _snake.last;
      } else {
        previous = _snakeIndex - 1 >= 0 ? _snake[_snakeIndex - 1] : null;
        next = _snakeIndex + 1 < _snake.length ? _snake[_snakeIndex + 1] : null;
      }
      return Border(
        top: _getBorderSide(_Side.top, previous, next, background),
        bottom: _getBorderSide(_Side.bottom, previous, next, background),
        left: _getBorderSide(_Side.left, previous, next, background),
        right: _getBorderSide(_Side.right, previous, next, background),
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

  double _getDistance(_Side side) {
    double result = 0.0;
    switch (_snakeSide) {
      case SnakeSide.tail:
        if ((side == _Side.left && _direction == Direction.right) ||
            (side == _Side.right && _direction == Direction.left)) {
          result = _animationValue * widget.width;
        } else if ((side == _Side.top && _direction == Direction.down) ||
            (side == _Side.bottom && _direction == Direction.up)) {
          result = _animationValue * widget.height;
        }
        break;
      case SnakeSide.head:
        if ((side == _Side.left && _direction == Direction.left) ||
            (side == _Side.right && _direction == Direction.right)) {
          result = -(_animationValue * widget.width);
        } else if ((side == _Side.top && _direction == Direction.up) ||
            (side == _Side.bottom && _direction == Direction.down)) {
          result = -(_animationValue * widget.height);
        }
        break;
      case SnakeSide.nextHead:
        if ((side == _Side.left && _direction == Direction.left) ||
            (side == _Side.right && _direction == Direction.right)) {
          result = widget.width - (_animationValue * widget.width);
        } else if ((side == _Side.top && _direction == Direction.up) ||
            (side == _Side.bottom && _direction == Direction.down)) {
          result = widget.height - (_animationValue * widget.height);
        }
        break;
      default:
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // var text = _isHead() || _isNextHead() ? 'XX' : '';

    final text = '';
    final background =
        _color == Colors.white || _snakeSide == SnakeSide.nextHead
            ? !_lose
                ?
                // snakeSide == SnakeSide.nextHead ? _snakeBorderColor :
                Colors.white
                : Colors.red[200]
            : _color;

    final borders = _getBorders(background);
    var container = Positioned(
      // left: _isTail() ? (_animationValue * widget.width) : 0,
      // right: _isHead()
      //     ? -(_animationValue * widget.width)
      //     : _isNextHead() ? widget.width - (_animationValue * widget.width) : 0,
      left: _getDistance(_Side.left),
      top: _getDistance(_Side.top),
      right: _getDistance(_Side.right),
      bottom: _getDistance(_Side.bottom),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: background,
          border: borders,
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
      ),
    );

    return Container(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [container],
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

enum SnakeSide {
  none,
  tail,
  head,
  nextHead,
}
