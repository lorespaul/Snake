import 'dart:ui';

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

  List<List<Function(Color)>> _listeners;
  Function(int, int) _boardListener;

  void addListener(int row, int column, Function(Color) listener) {
    _listeners[row][column] = listener;
  }

  void addBoardListener(Function(int, int) listener) {
    _boardListener = listener;
  }

  void trigger(List<List<Color>> colors, int length, int maxLength) {
    for (int i = 0; i < colors.length; i++) {
      var colColors = colors[i];
      for (int n = 0; n < colColors.length; n++) {
        var callback = _listeners[i][n];
        if (callback != null) {
          callback(colColors[n]);
        }
      }
    }
    if (_boardListener != null) _boardListener(length, maxLength);
  }
}
