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
    this.rows,
    this.columns,
    this.onRestart,
    this.maxLength,
  }) : super(key: key);

  final int rows;
  final int columns;
  final Function(int) onRestart;
  final int maxLength;

  @override
  _SnakeGridState createState() => _SnakeGridState();
}

class _SnakeGridState extends State<SnakeGrid> {
  FocusNode _focusNode;
  List<List<Color>> _whiteNodes;
  List<Cell> _snakePositions;
  Direction _direction;
  Timer _movingTimer;
  Timer _generateTimer;
  Cell _generate;
  int _generationCounter = 0;
  bool _lose;
  SnakeNodeController _snakeNodeController;
  List<int> _initialSnake;
  final Random _random = Random();

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
        (n) => i == (widget.columns / 2).round() && _initialSnake.contains(n)
            ? Colors.white
            : Colors.black,
      ),
    );
    _direction = Direction.none;
    _snakePositions = List<Cell>();
    for (int i in _initialSnake) {
      _snakePositions.add(Cell((widget.columns / 2).round(), i));
    }
    _initTimers();
  }

  void _initTimers() {
    if (!_lose) {
      if (_movingTimer == null) {
        _movingTimer =
            Timer.periodic(const Duration(milliseconds: 100), (timer) {
          _moveSnake();
        });
      }
      if (_generateTimer == null) {
        _generateTimer =
            Timer.periodic(const Duration(milliseconds: 2000), (timer) {
          _generateCell();
        });
      }
    }
  }

  void _moveSnake() {
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
    if (newHead != null) {
      if (_generate == null ||
          _generate.row != newHead.row ||
          _generate.column != newHead.column) {
        if (_whiteNodes[newHead.row][newHead.column] == Colors.white) {
          _lose = true;
          _clearTimers();
          return;
        }

        _snakePositions.removeAt(0);
        _whiteNodes[tail.row][tail.column] = Colors.black;
      } else {
        _generationCounter = 0;
        _generate = null;

        // var difLength = _snakePositions.length - _initialSnake.length;
        // var addTails = (difLength / 5).floor() - 1;
        // print('add tails: $addTails');
        // if (addTails > 0) {
        //   var preTail = _snakePositions[1];
        //   if (tail.row == preTail.row) {
        //     if (tail.column > preTail.column) {
        //       for (int i = 0; i < addTails; i++) {
        //         var cell = Cell(tail.row, tail.column + i + 1);
        //         _snakePositions.insert(0, cell);
        //         _whiteNodes[cell.row][cell.column] = Colors.white;
        //       }
        //     } else if (tail.column < preTail.column) {
        //       for (int i = 0; i < addTails; i++) {
        //         var cell = Cell(tail.row, tail.column - i - 1);
        //         _snakePositions.insert(0, cell);
        //         _whiteNodes[cell.row][cell.column] = Colors.white;
        //       }
        //     }
        //   } else if (tail.column == preTail.column) {
        //     if (tail.row > preTail.row) {
        //       for (int i = 0; i < addTails; i++) {
        //         var cell = Cell(tail.row + i + 1, tail.column);
        //         _snakePositions.insert(0, cell);
        //         _whiteNodes[cell.row][cell.column] = Colors.white;
        //       }
        //     } else if (tail.row < preTail.row) {
        //       for (int i = 0; i < addTails; i++) {
        //         var cell = Cell(tail.row - i - 1, tail.column);
        //         _snakePositions.insert(0, cell);
        //         _whiteNodes[cell.row][cell.column] = Colors.white;
        //       }
        //     }
        //   }
        // }
      }
      _snakePositions.add(newHead);

      _whiteNodes[newHead.row][newHead.column] = Colors.white;
      _snakeNodeController.trigger(
        _whiteNodes,
        _snakePositions.length,
        widget.maxLength,
      );
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
    if (_movingTimer != null) _movingTimer.cancel();
    if (_generateTimer != null) _generateTimer.cancel();
    _movingTimer = null;
    _generateTimer = null;
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
                color: _whiteNodes[row][column],
              ),
            ],
          ),
        );
      }
      widgetRows.add(Row(children: widgetColumns));
    }

    FocusScope.of(context).requestFocus(_focusNode);
    return RawKeyboardListener(
      key: Key('Keyboard${widget.key.toString()}'),
      focusNode: _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event.runtimeType.toString() == 'RawKeyDownEvent') {
          switch (event.logicalKey.keyLabel) {
            case 'l':
              if (_direction != Direction.left) _direction = Direction.right;
              return;
            case 'j':
              if (_direction != Direction.right) _direction = Direction.left;
              return;
            case 'i':
              if (_direction != Direction.down) _direction = Direction.up;
              return;
            case 'k':
              if (_direction != Direction.up) _direction = Direction.down;
              return;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (_direction != Direction.left) _direction = Direction.right;
            return;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (_direction != Direction.right) _direction = Direction.left;
            return;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            if (_direction != Direction.down) _direction = Direction.up;
            return;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            if (_direction != Direction.up) _direction = Direction.down;
            return;
          } else if (event.logicalKey == LogicalKeyboardKey.enter) {
            if (_lose) {
              _restart();
            } else if (_movingTimer == null)
              _initTimers();
            else
              _clearTimers();
            return;
          }
        }
      },
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
                                width: 60,
                                child: Text('Left'),
                              ),
                              Container(
                                width: 10,
                                child: Text('J'),
                              ),
                              Container(
                                width: 10,
                                child: Text('-'),
                              ),
                              Icon(
                                Icons.arrow_back,
                                color: Colors.black,
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
                                width: 60,
                                child: Text('Up'),
                              ),
                              Container(
                                width: 10,
                                child: Text('I'),
                              ),
                              Container(
                                width: 10,
                                child: Text('-'),
                              ),
                              Icon(
                                Icons.arrow_upward,
                                color: Colors.black,
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
                                width: 60,
                                child: Text('Right'),
                              ),
                              Container(
                                width: 10,
                                child: Text('L'),
                              ),
                              Container(
                                width: 10,
                                child: Text('-'),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.black,
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
                                width: 60,
                                child: Text('Down'),
                              ),
                              Container(
                                width: 10,
                                child: Text('K'),
                              ),
                              Container(
                                width: 10,
                                child: Text('-'),
                              ),
                              Icon(
                                Icons.arrow_downward,
                                color: Colors.black,
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
                          child: Text('Continue'),
                          onPressed: _initTimers,
                        ),
                        RaisedButton(
                          child: Text('Stop'),
                          onPressed: _clearTimers,
                        ),
                        RaisedButton(
                          child: Text('Restart'),
                          onPressed: _restart,
                        ),
                        SnakeBoard(
                          key: Key('SnakeBoard${widget.key.toString()}'),
                          length: _snakePositions.length,
                          maxLength: widget.maxLength,
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
}

enum Direction {
  none,
  up,
  down,
  left,
  right,
}

class Cell {
  Cell(this.row, this.column);
  int row;
  int column;
}
