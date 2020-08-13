import 'dart:ui';

import 'package:Snake/widgets/snake_grid.dart';

class SnakeNodeController {
  SnakeNodeController(int rows, int columns) {
    _listeners = List.generate(
      rows,
      (i) => List.generate(
        columns,
        (n) => null,
      ),
    );
  }

  List<List<Function(List<List<Color>>, List<Cell>)>> _listeners;
  Function(int, int) _boardListener;

  void addListener(
      int row, int column, Function(List<List<Color>>, List<Cell>) listener) {
    _listeners[row][column] = listener;
  }

  void addBoardListener(Function(int, int) listener) {
    _boardListener = listener;
  }

  void trigger(
      List<List<Color>> colors, List<Cell> snake, int length, int maxLength) {
    for (int i = 0; i < colors.length; i++) {
      var colColors = colors[i];
      for (int n = 0; n < colColors.length; n++) {
        var callback = _listeners[i][n];
        if (callback != null) {
          callback(colors, snake);
        }
      }
    }
    if (_boardListener != null) _boardListener(length, maxLength);
  }
}
