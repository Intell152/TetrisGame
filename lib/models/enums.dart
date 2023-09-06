import 'package:flutter/material.dart';

const int rowLength = 10;
const int columnLength = 15;
int currentScore = 0;

enum Tetromino {
  I,
  J,
  L,
  O,
  S,
  T,
  Z,
}

enum Direction {
  left,
  right,
  down,
}

const Map<Tetromino, Color> tetrominoColors = {
  Tetromino.I: Colors.orange,
  Tetromino.J: Colors.blue,
  Tetromino.L: Colors.pink,
  Tetromino.O: Colors.amber,
  Tetromino.S: Colors.green,
  Tetromino.T: Colors.red,
  Tetromino.Z: Colors.purple,
};
