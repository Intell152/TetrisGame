import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:tetris_game/game/piece_class.dart';
import 'package:tetris_game/models/enums.dart';
import 'package:tetris_game/game/pixel_card.dart';

List<List<Tetromino?>> gameBoard = List.generate(
  columnLength,
  (i) => List.generate(
    rowLength,
    (j) => null,
  ),
);

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Piece currentPiece = Piece(type: Tetromino.L);
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: rowLength * columnLength,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rowLength),
              itemBuilder: (context, index) {
                int row = (index / rowLength).floor();
                int column = index % rowLength;

                if (currentPiece.position.contains(index)) {
                  return PixelCard(
                    color: tetrominoColors[currentPiece.type]!,
                  );
                } else if (gameBoard[row][column] != null) {
                  final Tetromino? tetrominoType = gameBoard[row][column];
                  return PixelCard(
                    color: tetrominoColors[tetrominoType]!,
                  );
                } else {
                  return PixelCard(
                    color: Colors.grey.shade900,
                  );
                }
              },
            ),
          ),
          Text(
            'Score: $currentScore',
            style: const TextStyle(color: Colors.white),
          ),
          Expanded(
            flex: 1,
            child: controlPanel(),
          ),
        ]),
      ),
    );
  }

  void startGame() {
    currentPiece.initializePiece();

    //Game Loop Down Piece
    Duration loopRate = const Duration(milliseconds: 400);
    gameLoop(loopRate);
  }

  bool gameOver() {
    for (var column = 0; column < rowLength; column++) {
      if (gameBoard[0][column] != null) {
        return true;
      }
    }

    return false;
  }

  void gameLoop(Duration loopRate) {
    Timer.periodic(loopRate, (timer) {
      setState(() {
        clearLines();
        detectLanding();

        if (isGameOver == true) {
          timer.cancel();
          showGameOverDialog();
        }

        currentPiece.movePiece(Direction.down);
      });
    });
  }

  bool detectCollision(Direction direction) {
    for (var i = 0; i < currentPiece.position.length; i++) {
      int row = (currentPiece.position[i] / rowLength).floor();
      int column = currentPiece.position[i] % rowLength;

      if (direction == Direction.left) {
        column -= 1;
      } else if (direction == Direction.right) {
        column += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      // Detect Border collision
      if (row >= columnLength || column < 0 || column >= rowLength) {
        return true;
      }

      // Detect collision between pieces
      if (row >= 0 && row < columnLength && column >= 0 && column < rowLength) {
        if (gameBoard[row][column] != null) {
          return true;
        }
      }
    }
    return false;
  }

  void detectLanding() {
    if (detectCollision(Direction.down)) {
      for (var i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int column = currentPiece.position[i] % rowLength;

        if (row >= 0 && column >= 0) {
          gameBoard[row][column] = currentPiece.type;
        }
      }
      newPiece();
    }
  }

  void newPiece() {
    Random rand = Random();

    Tetromino randomType =
        Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();

    if (gameOver()) {
      isGameOver = true;
    }
  }

  Widget controlPanel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            if (!detectCollision(Direction.left)) {
              setState(() {
                currentPiece.movePiece(Direction.left);
              });
            }
          },
          icon: const Icon(
            Icons.arrow_left,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              currentPiece.rotatePiece();
            });
          },
          icon: const Icon(
            Icons.rotate_90_degrees_cw_rounded,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            if (!detectCollision(Direction.right)) {
              setState(() {
                currentPiece.movePiece(Direction.right);
              });
            }
          },
          icon: const Icon(
            Icons.arrow_right,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void clearLines() {
    for (var row = columnLength - 1; row >= 0; row--) {
      bool rowCompleted = true;

      for (var column = 0; column < rowLength; column++) {
        if (gameBoard[row][column] == null) {
          rowCompleted = false;
          break;
        }
      }

      if (rowCompleted) {
        for (var i = row; i > 0; i--) {
          gameBoard[i] = List.from(gameBoard[i - 1]);
        }

        gameBoard[0] = List.generate(row, (index) => null);
        currentScore++;
      }
    }
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score is: $currentScore '),
        actions: [
          TextButton(
              onPressed: () {
                resetGame();
                Navigator.pop(context);
              },
              child: const Text('Play Again'))
        ],
      ),
    );
  }

  void resetGame() {
    gameBoard = List.generate(
      columnLength,
      (i) => List.generate(
        rowLength,
        (j) => null,
      ),
    );

    isGameOver = false;
    currentScore = 0;
    newPiece();
    startGame();
  }
}
