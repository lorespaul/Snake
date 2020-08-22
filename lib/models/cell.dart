class Cell {
  Cell(this.row, this.column);
  int row;
  int column;

  @override
  bool operator ==(o) => o is Cell && o.row == row && o.column == column;

  @override
  int get hashCode => row.hashCode ^ column.hashCode;
}
