import 'package:flutter/material.dart';

class TilesModel {
  int defaultIndex;
  int currentIndex;
  bool isWhite;
  TilesModel({
    required this.defaultIndex,
    required this.currentIndex,
    required this.isWhite,
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
