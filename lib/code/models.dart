import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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

class UserData {
  String uid;
  Map<String, int> moves;
  Map<String, int> times;
  Timestamp lastSeen;
  UserData({
    required this.uid,
    required this.moves,
    required this.times,
    required this.lastSeen,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'moves': moves,
      'times': times,
      'lastSeen': lastSeen,
    };
  }

  factory UserData.newUser(String uid) {
    return UserData(
      uid: uid,
      moves: {
        "three": 0,
        "four": 0,
      },
      times: {
        "three": 0,
        "four": 0,
      },
      lastSeen: Timestamp.now(),
    );
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      uid: map['uid'] ?? '',
      moves: Map<String, int>.from(map['moves']),
      times: Map<String, int>.from(map['times']),
      lastSeen: (map['lastSeen']) ?? Timestamp.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) =>
      UserData.fromMap(json.decode(source));

  UserData copyWith({
    String? uid,
    Map<String, int>? moves,
    Map<String, int>? times,
    Timestamp? lastSeen,
  }) {
    return UserData(
      uid: uid ?? this.uid,
      moves: moves ?? this.moves,
      times: times ?? this.times,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

class ChartData {
  ChartData(
    this.x,
    this.y,
  );
  final int x;
  final int y;

  Map<String, int> toFirestore() {
    return {
      x.toString(): y,
    };
  }

  factory ChartData.fromFirestore(Map<String, int> map) {
    return ChartData(int.parse(map.keys.first), map.values.first);
  }

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
    };
  }

  factory ChartData.fromMap(Map<String, dynamic> map) {
    return ChartData(
      map['x']?.toInt() ?? 0,
      map['y']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChartData.fromJson(String source) =>
      ChartData.fromMap(json.decode(source));

  ChartData copyWith({
    int? x,
    int? y,
  }) {
    return ChartData(
      x ?? this.x,
      y ?? this.y,
    );
  }
}

class CommunityScores {
  final Map<String, List<ChartData>> moves;
  final Map<String, List<ChartData>> times;
  CommunityScores({
    required this.moves,
    required this.times,
  });
}
