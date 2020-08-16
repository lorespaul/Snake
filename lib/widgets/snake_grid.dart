import 'dart:async';

import 'package:Snake/controllers/snake_node_controller.dart';
import 'package:Snake/widgets/snake_board.dart';
import 'package:Snake/widgets/snake_node.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'package:flutter/services.dart';

class SnakeGrid extends StatefulWidget {
  SnakeGrid({
    Key key,
    @required this.rows,
    @required this.columns,
    @required this.maxLength,
    this.speed = SnakeSpeed.medium,
    this.onRestart,
    this.onOpenSettings,
  }) : super(key: key);

  final int rows;
  final int columns;
  final SnakeSpeed speed;
  final int maxLength;
  final Function(int) onRestart;
  final Function onOpenSettings;

  @override
  _SnakeGridState createState() => _SnakeGridState();
}

class _SnakeGridState extends State<SnakeGrid> with TickerProviderStateMixin {
  FocusNode _focusNode;
  List<List<Color>> _whiteNodes;
  List<Cell> _snakePositions;
  Direction _direction;
  Timer _generateTimer;
  Cell _generate;
  int _generationCounter = 0;
  bool _lose;
  SnakeNodeController _snakeNodeController;
  List<int> _initialSnake;
  List<RawKeyEvent> _nextKeys;
  final Random _random = Random();

  AnimationController _animationController;

  double _snakeNodeWidth;
  double _snakeNodeHeight;

  static const double MAX_WIDTH = 550;
  static const double MAX_HEIGHT = 550;

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _init() {
    _focusNode = FocusNode();
    _snakeNodeController = SnakeNodeController(widget.rows, widget.columns);
    _lose = false;
    _initialSnake = List.generate(3, (index) => index + 2);
    _whiteNodes = List.generate(
      widget.rows,
      (i) => List.generate(
        widget.columns,
        (n) => i == (widget.rows / 2).round() && _initialSnake.contains(n)
            ? Colors.white
            : Colors.black,
      ),
    );
    _direction = Direction.none;
    _snakePositions = List<Cell>();
    for (int i in _initialSnake) {
      _snakePositions.add(Cell((widget.rows / 2).round(), i));
    }
    _nextKeys = List<RawKeyEvent>();
    _processDimensions();
    _initTimers();
  }

  void _processDimensions() {
    if (widget.columns > widget.rows) {
      _snakeNodeWidth = MAX_WIDTH / widget.columns;
      _snakeNodeHeight = _snakeNodeWidth;
    } else if (widget.columns < widget.rows) {
      _snakeNodeHeight = MAX_WIDTH / widget.rows;
      _snakeNodeWidth = _snakeNodeHeight;
    } else {
      _snakeNodeWidth = MAX_WIDTH / widget.columns;
      _snakeNodeHeight = MAX_HEIGHT / widget.rows;
    }
  }

  void _initTimers() {
    if (!_lose) {
      if (_animationController == null) {
        _animationController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: _getSnakeSpeed()),
        )..addListener(() => _animateSnake(_animationController.value));
      } else {
        if (_animationController.isCompleted) _animationController.reset();
        _animationController.forward();
        _animationStopped = false;
      }
      if (_generateTimer == null) {
        _generateTimer = Timer.periodic(
          const Duration(milliseconds: 2000),
          (timer) {
            _generateCell();
          },
        );
      }
    }
  }

  int _getSnakeSpeed() {
    switch (widget.speed) {
      case SnakeSpeed.slow:
        return 150;
      case SnakeSpeed.fast:
        return 80;
      default:
        return 100;
    }
  }

  int _animationTurn = 0;
  bool _removeTail = false;
  bool _animationStopped = false;

  void _animateSnake(double animationValue) {
    if (_nextKeys.isNotEmpty &&
        (_animationController.isCompleted || _direction == Direction.none)) {
      var next = _nextKeys.first;
      _nextKeys.removeAt(0);
      _updateDirection(next);
    }

    var tail = _snakePositions.first;
    var head = _snakePositions.last;
    Cell newHead;
    switch (_direction) {
      case Direction.right:
        newHead = Cell(head.row, (head.column + 1) % widget.columns);
        break;
      case Direction.left:
        newHead = Cell(
          head.row,
          head.column > 0 ? head.column - 1 : widget.columns - 1,
        );
        break;
      case Direction.up:
        newHead = Cell(
          head.row > 0 ? head.row - 1 : widget.rows - 1,
          head.column,
        );
        break;
      case Direction.down:
        newHead = Cell((head.row + 1) % widget.rows, head.column);
        break;
      case Direction.none:
        return;
    }

    if (_animationTurn == 0) {
      if (newHead != null) {
        if (_generate == null ||
            _generate.row != newHead.row ||
            _generate.column != newHead.column) {
          if (_whiteNodes[newHead.row][newHead.column] == Colors.white) {
            _lose = true;
            _snakeNodeController.trigger(
              _whiteNodes,
              _snakePositions,
              _snakePositions.length,
              widget.maxLength,
              true,
              0.0,
              _animationController.isCompleted,
              true,
              Direction.none,
            );
            _stopAnimation();
            _clearTimers();
            // return;
          }

          _removeTail = true;
        } else {
          _generationCounter = 0;
          _generate = null;
        }
        _snakePositions.add(newHead);
        _whiteNodes[newHead.row][newHead.column] = Colors.white;
      }
    }

    if (_animationController.isCompleted && _removeTail) {
      _removeTail = false;
      _snakePositions.removeAt(0);
      _whiteNodes[tail.row][tail.column] = Colors.black;
    }

    _snakeNodeController.trigger(
      _whiteNodes,
      _snakePositions,
      _snakePositions.length,
      widget.maxLength,
      _lose,
      animationValue,
      _animationController.isCompleted || _animationStopped,
      !_removeTail,
      _direction,
    );

    _animationTurn++;
    if (_animationController.isCompleted) {
      _animationTurn = 0;
      try {
        _animationController.reset();
        if (!_animationStopped) _animationController.forward();
      } catch (e) {
        print(e);
      }
    }
  }

  void _restart() {
    if (widget.onRestart != null) {
      widget.onRestart(_snakePositions.length);
    }
  }

  void _generateCell() {
    if (_direction == Direction.none) return;
    if (_generate == null) {
      int row, column;
      do {
        row = _random.nextInt(widget.rows);
        column = _random.nextInt(widget.columns);
      } while (_whiteNodes[row][column] == Colors.white);
      _generate = Cell(row, column);
      _whiteNodes[row][column] = Colors.red[300];
    } else if (_generationCounter == 5) {
      _whiteNodes[_generate.row][_generate.column] = Colors.black;
      _generationCounter = 0;
      _generate = null;
    } else {
      _generationCounter++;
    }
  }

  @override
  void dispose() {
    _clearTimers();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearTimers() {
    if (_animationController != null) {
      _animationController.stop();
      // _animationController.dispose();
    }
    if (_generateTimer != null) _generateTimer.cancel();
    // _animationController = null;
    _generateTimer = null;
  }

  void _stopAnimation() {
    _animationStopped = true;
  }

  @override
  Widget build(BuildContext context) {
    var widgetRows = List<Row>();

    for (int i = 0; i < widget.rows; i++) {
      var widgetColumns = List<Column>();

      for (int n = 0; n < widget.columns; n++) {
        final row = i;
        final column = n;

        widgetColumns.add(
          Column(
            children: <SnakeNode>[
              SnakeNode(
                key: Key('SnakeNode$row$column${widget.key.toString()}'),
                controller: _snakeNodeController,
                row: row,
                column: column,
                width: _snakeNodeWidth,
                height: _snakeNodeHeight,
                grid: _whiteNodes,
                snake: _snakePositions,
                direction: _whiteNodes[row][column] == Colors.white
                    ? Direction.right
                    : Direction.none,
              ),
            ],
          ),
        );
      }
      widgetRows.add(Row(children: widgetColumns));
    }

    _focusNode.requestFocus();
    return RawKeyboardListener(
      key: Key('Keyboard${widget.key.toString()}'),
      focusNode: _focusNode,
      onKey: _keyListener,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 7,
                  child: Container(
                    width: 150,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 5, left: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 55,
                                child: Text('Left'),
                              ),
                              Container(
                                width: 15,
                                child: Text('J'),
                              ),
                              Container(
                                width: 10,
                                child: Text('-'),
                              ),
                              Icon(
                                Icons.arrow_back,
                                color: Colors.grey[700],
                                size: 18,
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 5, left: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 55,
                                child: Text('Up'),
                              ),
                              Container(
                                width: 15,
                                child: Text('I'),
                              ),
                              Container(
                                width: 10,
                                child: Text('-'),
                              ),
                              Icon(
                                Icons.arrow_upward,
                                color: Colors.grey[700],
                                size: 18,
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 5, left: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 55,
                                child: Text('Right'),
                              ),
                              Container(
                                width: 15,
                                child: Text('L'),
                              ),
                              Container(
                                width: 10,
                                child: Text('-'),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.grey[700],
                                size: 18,
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 5, left: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 55,
                                child: Text('Down'),
                              ),
                              Container(
                                width: 15,
                                child: Text('K'),
                              ),
                              Container(
                                width: 10,
                                child: Text('-'),
                              ),
                              Icon(
                                Icons.arrow_downward,
                                color: Colors.grey[700],
                                size: 18,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 7,
                  child: Container(
                    width: 150,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        RaisedButton(
                          child: Text('Settings'),
                          onPressed: () {
                            if (widget.onOpenSettings != null) {
                              _stopAnimation();
                              widget.onOpenSettings();
                            }
                          },
                        ),
                        RaisedButton(
                          child: Text('Continue'),
                          onPressed: _initTimers,
                        ),
                        RaisedButton(
                          child: Text('Stop'),
                          onPressed: _stopAnimation,
                        ),
                        RaisedButton(
                          child: Text('Restart'),
                          onPressed: _restart,
                        ),
                        SnakeBoard(
                          key: Key('SnakeBoard${widget.key.toString()}'),
                          length: _snakePositions.length,
                          maxLength: widget.maxLength,
                          offset: _snakePositions.length + 1,
                          controller: _snakeNodeController,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: 30,
            ),
            Card(
              elevation: 7,
              color: Colors.black,
              child: Container(
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[700], width: 0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widgetRows,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _keyListener(RawKeyEvent event) {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        if (_lose)
          _restart();
        else if (!_animationController.isAnimating ||
            _animationController.isCompleted)
          _initTimers();
        else
          _stopAnimation();
        return;
      } else if (!_animationStopped) {
        if (_direction == Direction.none &&
            event.logicalKey != LogicalKeyboardKey.arrowLeft &&
            event.logicalKey.keyLabel != 'j') {
          var direction = _getDirection(event);
          _snakeNodeController.triggerInit(direction);
          _animationController.forward();
        }
        if (_nextKeys.isEmpty || _nextKeys.last != event) {
          _nextKeys.add(event);
        }
      }
    }
  }

  Direction _getDirection(RawKeyEvent event) {
    switch (event.logicalKey.keyLabel) {
      case 'l':
        if (_direction != Direction.left) return Direction.right;
        break;
      case 'j':
        if (_direction != Direction.right && _direction != Direction.none)
          return Direction.left;
        break;
      case 'i':
        if (_direction != Direction.down) return Direction.up;
        break;
      case 'k':
        if (_direction != Direction.up) return Direction.down;
        break;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      if (_direction != Direction.left) return Direction.right;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      if (_direction != Direction.right && _direction != Direction.none)
        return Direction.left;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_direction != Direction.down) return Direction.up;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_direction != Direction.up) return Direction.down;
    }
    return Direction.none;
  }

  void _updateDirection(RawKeyEvent event) {
    final direction = _getDirection(event);
    if (direction != Direction.none) {
      _direction = direction;
    }
    // switch (event.logicalKey.keyLabel) {
    //   case 'l':
    //     if (_direction != Direction.left) _direction = Direction.right;
    //     return;
    //   case 'j':
    //     if (_direction != Direction.right && _direction != Direction.none)
    //       _direction = Direction.left;
    //     return;
    //   case 'i':
    //     if (_direction != Direction.down) _direction = Direction.up;
    //     return;
    //   case 'k':
    //     if (_direction != Direction.up) _direction = Direction.down;
    //     return;
    // }
    // if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
    //   if (_direction != Direction.left) _direction = Direction.right;
    //   return;
    // } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
    //   if (_direction != Direction.right && _direction != Direction.none)
    //     _direction = Direction.left;
    //   return;
    // } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
    //   if (_direction != Direction.down) _direction = Direction.up;
    //   return;
    // } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
    //   if (_direction != Direction.up) _direction = Direction.down;
    //   return;
    // }
  }
}

enum Direction {
  none,
  up,
  down,
  left,
  right,
}

enum SnakeSpeed {
  slow,
  medium,
  fast,
}

class Cell {
  Cell(this.row, this.column);
  int row;
  int column;

  @override
  bool operator ==(o) => o is Cell && o.row == row && o.column == column;

  @override
  int get hashCode => row.hashCode ^ column.hashCode;
}
