import 'dart:ui';

import 'package:Snake/controllers/abstract_snake_controller.dart';
import 'package:Snake/models/cell.dart';

class SnakeNodeController extends AbstractSnakeController {
  SnakeNodeController(int rows, int columns) {
    _listeners = List.generate(
      rows,
      (i) => List.generate(
        columns,
        (n) => null,
      ),
    );
  }

  List<List<Function(List<List<Color>>, List<Cell>, bool)>> _listeners;
  Function(int, int) _boardListener;

  void addListener(int row, int column,
      Function(List<List<Color>>, List<Cell>, bool) listener) {
    _listeners[row][column] = listener;
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
  ) {
    for (int i = 0; i < colors.length; i++) {
      var colColors = colors[i];
      for (int n = 0; n < colColors.length; n++) {
        var callback = _listeners[i][n];
        if (callback != null) {
          callback(colors, snake, lose);
        }
      }
    }
    if (_boardListener != null) _boardListener(length, maxLength);
  }
}
