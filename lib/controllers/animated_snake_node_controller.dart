import 'dart:ui';

import 'package:snake/controllers/abstract_snake_controller.dart';
import 'package:snake/models/cell.dart';
import 'package:snake/models/enums/direction.dart';

class AnimatedSnakeNodeController extends AbstractSnakeController {
  AnimatedSnakeNodeController(int rows, int columns) {
    _listeners = List.generate(
      rows,
      (i) => List.generate(
        columns,
        (n) => null,
      ),
    );
    _initListeners = List.generate(
      rows,
      (i) => List.generate(
        columns,
        (n) => null,
      ),
    );
  }

  late List<
      List<
          Function(List<List<Color>>, List<Cell>, bool, int, bool, bool,
              Direction)?>> _listeners;
  late List<List<Function(Direction)?>> _initListeners;
  Function(int, int)? _boardListener;

  void addListener(
      int row,
      int column,
      Function(List<List<Color>>, List<Cell>, bool, int, bool, bool, Direction)
          listener) {
    _listeners[row][column] = listener;
  }

  void addInitListener(int row, int column, Function(Direction) listener) {
    _initListeners[row][column] = listener;
  }

  void addBoardListener(Function(int, int) listener) {
    _boardListener = listener;
  }

  void trigger(
      List<List<Color>> colors,
      List<Cell> snake,
      int length,
      int maxLength,
      bool lose,
      int animationTurn,
      bool animationCompleted,
      bool keepTail,
      Direction direction) {
    for (int i = 0; i < colors.length; i++) {
      var colColors = colors[i];
      for (int n = 0; n < colColors.length; n++) {
        var callback = _listeners[i][n];
        if (callback != null) {
          callback(
            colors,
            snake,
            lose,
            animationTurn,
            animationCompleted,
            keepTail,
            direction,
          );
        }
      }
    }
    if (_boardListener != null) _boardListener!(length, maxLength);
  }

  void triggerInit(Direction direction) {
    for (int i = 0; i < _initListeners.length; i++) {
      var colInitListeners = _initListeners[i];
      for (var initListener in colInitListeners) {
        if (initListener != null) {
          initListener(direction);
        }
      }
    }
  }
}
