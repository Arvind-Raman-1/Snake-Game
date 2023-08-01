import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snakegame/blank_pixel.dart';
import 'package:snakegame/snake_pixel.dart';
import 'package:snakegame/food_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  // grid Dimensions
  int rowSize = 10;
  int totalNumberOfSquares = 100;
  int currentScore = 0;
  bool gameHasStarted = false;

  //snake position
  List<int> snakepos = [
    0,
    1,
    2,
  ];

  // SNAKE DIRECTION is initially to the right

  var currentDirection = snake_Direction.RIGHT;

  //food location
  int foodpos = 55;

  // Start Game

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        // keep snake moving
        moveSnake();
        // check if gameover
        if (gameOver()) {
          timer.cancel();
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text('game over!'),
                  content: Column(
                    children: [
                      Text('Your Score is: $currentScore'),
                      TextField(
                        decoration: InputDecoration(hintText: 'Enter Name'),
                      ),
                    ],
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        submitScore();
                      },
                      child: Text('Submit Score'),
                      color: Colors.pink,
                    )
                  ],
                );
              });
        }
      });
    });
  }

  void submitScore() {
    //submits the score
  }

  void eatFood() {
    // making sure food is seperate from snake
    currentScore++;
    while (snakepos.contains(foodpos)) {
      foodpos = Random().nextInt(totalNumberOfSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          //if snake is at right wall adjust
          if (snakepos.last % rowSize == 9) {
            snakepos.add(snakepos.last + 1 - rowSize);
          } else {
            snakepos.add(snakepos.last + 1);
          }
        }
        break;
      case snake_Direction.LEFT:
        {
          if (snakepos.last % rowSize == 0) {
            snakepos.add(snakepos.last - 1 + rowSize);
          } else {
            snakepos.add(snakepos.last - 1);
          }
        }
        break;
      case snake_Direction.UP:
        {
          if (snakepos.last < rowSize) {
            snakepos.add(snakepos.last - rowSize + totalNumberOfSquares);
          } else {
            snakepos.add(snakepos.last - rowSize);
          }
        }
        break;
      case snake_Direction.DOWN:
        {
          if (snakepos.last + rowSize > totalNumberOfSquares) {
            snakepos.add(snakepos.last + rowSize - totalNumberOfSquares);
          } else {
            snakepos.add(snakepos.last + rowSize);
          }
        }
        break;
      default:
    }
    if (snakepos.last == foodpos) {
      eatFood();
    } else {
      snakepos.removeAt(0);
    }
  }

  // gameOver method

  bool gameOver() {
    //when snake runs into itself
    // duplicate number in the snake list
    List<int> bodySnake = snakepos.sublist(0, snakepos.length - 1);
    if (bodySnake.contains(snakepos.last)) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          //highscores
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //user current score
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Current Score: '),
                    Text(
                      currentScore.toString(),
                      style: TextStyle(fontSize: 36),
                    ),
                  ],
                ),
                //top 5 high scores
                Text('High Scores: '),
              ],
            ),
          ),
          //gamegrid
          Expanded(
              flex: 3,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy > 0 &&
                      currentDirection != snake_Direction.UP) {
                    currentDirection = snake_Direction.DOWN;
                  } else if (details.delta.dy < 0 &&
                      currentDirection != snake_Direction.DOWN) {
                    currentDirection = snake_Direction.UP;
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if (details.delta.dx > 0 &&
                      currentDirection != snake_Direction.LEFT) {
                    currentDirection = snake_Direction.RIGHT;
                  } else if (details.delta.dx < 0 &&
                      currentDirection != snake_Direction.RIGHT) {
                    currentDirection = snake_Direction.LEFT;
                  }
                },
                child: GridView.builder(
                    itemCount: totalNumberOfSquares,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: rowSize),
                    itemBuilder: (context, index) {
                      if (snakepos.contains(index)) {
                        return const SnakePixel();
                      } else if (foodpos == index) {
                        return const FoodPixel();
                      } else {
                        return const BlankPixel();
                      }
                    }),
              )),
          //playbutton
          Expanded(
            child: Container(
                child: Center(
                    child: MaterialButton(
              child: Text('PLAY'),
              color: gameHasStarted ? Colors.grey : Colors.pink,
              onPressed: gameHasStarted ? () {} : startGame,
            ))),
          )
        ],
      ),
    );
  }
}
