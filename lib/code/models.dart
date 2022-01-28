import 'package:flutter/material.dart';

class TilesModel {
  int defaultIndex;
  int currentIndex;
  bool isWhite;
  Coordinates coordinates;
  TilesModel({
    required this.defaultIndex,
    required this.currentIndex,
    required this.isWhite,
    required this.coordinates,
  });
}

class Coordinates {
  int row;
  int column;
  Coordinates({
    required this.row,
    required this.column,
  });
}

class TweenModel {
  double? tweenTopOffset;
  double? tweenLeftOffset;
  bool? isRow;
  Axis? axis;
  TweenModel({
    this.tweenTopOffset,
    this.tweenLeftOffset,
    this.isRow,
    this.axis,
  });
}

enum Direction { left, right, up, down }
