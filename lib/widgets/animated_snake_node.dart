import 'package:snake/controllers/animated_snake_node_controller.dart';
import 'package:snake/models/cell.dart';
import 'package:snake/models/enums/direction.dart';
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
    this.direction = Direction.none,
    required this.animationController,
  }) : super(key: key);

  final AnimatedSnakeNodeController controller;
  final int row;
  final int column;
  final double width;
  final double height;
  final List<List<Color>> grid;
  final List<Cell> snake;
  final Direction direction;
  final AnimationController animationController;

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
  late _SnakeSide _snakeSide;
  late Direction _direction;

  bool _init = true;
  bool _keepTail = false;

  static const double SNAKE_BORDER_WIDTH = 2.5;
  static final Color _snakeBorderColor = Colors.green[700]!;

  @override
  void initState() {
    super.initState();
    _grid = widget.grid;
    _snake = widget.snake;
    _updateSnakeIndex();
    _updateSnakeSide();
    _direction =
        _snakeSide != _SnakeSide.none ? widget.direction : Direction.none;
    var color = _grid[widget.row][widget.column];
    _color = color;

    if (_snakeSide == _SnakeSide.head) {
      widget.controller.addInitListener(widget.row, widget.column, (
        Direction direction,
      ) {
        _updateSnakeIndex();
        _updateSnakeSide();
        _direction = direction;
      });
    }

    widget.controller.addListener(
      widget.row,
      widget.column,
      (
        List<List<Color>> grid,
        List<Cell> snake,
        bool lose,
        int animationTurn,
        bool animationCompleted,
        bool keepTail,
        Direction direction,
      ) {
        _snake = snake;
        _lose = lose;
        _keepTail = keepTail;
        if (_color == Colors.black) _direction = Direction.none;
        var color = grid[widget.row][widget.column];
        if (_color != color || color == Colors.white) {
          _updateSnakeIndex();
          _updateSnakeSide();
          if (_snakeSide == _SnakeSide.head &&
              (_direction == Direction.none || animationCompleted)) {
            _direction = direction;
          }
          if (_lose || _color != color || _snakeSide != _SnakeSide.none) {
            setState(
              () => _color = color,
            );
          }
        }
      },
    );
  }

  void _updateSnakeIndex() {
    _snakeIndex = _snake.indexOf(_cell);
  }

  void _updateSnakeSide() {
    _snakeSide = _isTail()
        ? _SnakeSide.tail
        : _isHead()
            ? _SnakeSide.head
            : _isPreHead()
                ? _SnakeSide.preHead
                : _SnakeSide.none;
  }

  bool _isHead() {
    return _snakeIndex == _snake.length - 1;
  }

  bool _isPreHead() {
    return _snakeIndex == _snake.length - 2;
  }

  bool _isTail() {
    return _snakeIndex == 0;
  }

  BorderSide _getBorderSide(
      Side side, Cell? previous, Cell? next, Color background) {
    var white = false;
    if (_snakeSide == _SnakeSide.preHead && !_init) {
      next = null;
    }
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

  Border _getBorders(Color background) {
    if (_snakeIndex != -1) {
      Cell? previous, next;
      previous = _snakeIndex - 1 >= 0 ? _snake[_snakeIndex - 1] : null;
      next = _snakeIndex + 1 < _snake.length ? _snake[_snakeIndex + 1] : null;
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

  double _getDistance(Side side, double animationValue) {
    double result = 0.0;
    switch (_snakeSide) {
      case _SnakeSide.tail:
        if (_keepTail) {
          break;
        }
        if ((side == Side.left && _direction == Direction.right) ||
            (side == Side.right && _direction == Direction.left)) {
          result = animationValue * widget.width;
        } else if ((side == Side.top && _direction == Direction.down) ||
            (side == Side.bottom && _direction == Direction.up)) {
          result = animationValue * widget.height;
        }
        break;
      case _SnakeSide.preHead:
        if ((side == Side.left && _direction == Direction.left) ||
            (side == Side.right && _direction == Direction.right)) {
          result = -(animationValue * widget.width);
        } else if ((side == Side.top && _direction == Direction.up) ||
            (side == Side.bottom && _direction == Direction.down)) {
          result = -(animationValue * widget.height);
        }
        break;
      case _SnakeSide.head:
        if ((side == Side.left && _direction == Direction.left) ||
            (side == Side.right && _direction == Direction.right)) {
          result = widget.width - (animationValue * widget.width);
        } else if ((side == Side.top && _direction == Direction.up) ||
            (side == Side.bottom && _direction == Direction.down)) {
          result = widget.height - (animationValue * widget.height);
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

    final background = _color == Colors.white || _snakeSide == _SnakeSide.head
        ? !_lose
            ?
            // snakeSide == SnakeSide.nextHead ? _snakeBorderColor :
            Colors.white
            : Colors.red[200]!
        : _color;

    final borders = _getBorders(background);
    var container = AnimatedBuilder(
      animation: widget.animationController,
      builder: (_, child) {
        final value = widget.animationController.value;
        var content = Positioned(
          key: Key('Positioned${widget.key}'),
          left: _init ? 0.0 : _getDistance(Side.left, value),
          top: _init ? 0.0 : _getDistance(Side.top, value),
          right: _init ? 0.0 : _getDistance(Side.right, value),
          bottom: _init ? 0.0 : _getDistance(Side.bottom, value),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: background,
              border: borders,
            ),
            // child: FittedBox(
            //   fit: BoxFit.fitWidth,
            //   child: Text(
            //     text,
            //     style: TextStyle(
            //       color: !_lose ? Colors.black : Colors.red[600],
            //     ),
            //   ),
            // ),
          ),
        );
        _init = false;
        return content;
      },
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

enum _SnakeSide {
  none,
  tail,
  head,
  preHead,
}
