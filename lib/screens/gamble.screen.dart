import 'dart:math';
import 'package:flutter/material.dart';

// gamble_screen.dart

class GambleScreen extends StatefulWidget {
  const GambleScreen({
    super.key,
  });

  @override
  State<GambleScreen> createState() => _GambleScreenState();
}

class _GambleScreenState extends State<GambleScreen> {
  final List<int> dices = List.generate(6, (_) => Random().nextInt(6) + 1);
  List<String> diceEyeImagePaths = [];
  List<String> realDiceImagePaths = [];

  @override
  void initState() {
    super.initState();
    _updateAllDiceVisuals();
  }

  void _updateAllDiceVisuals() {
    diceEyeImagePaths.clear();
    realDiceImagePaths.clear();
    for (int diceValue in dices) {
      diceEyeImagePaths.add('assets/img/dice_eyes/dice_eyes_$diceValue.jpg');
      realDiceImagePaths.add('assets/img/real_dice/real_dice_$diceValue.jpg');
    }
  }

  void rollDice() {
    setState(() {
      for (int i = 0; i < dices.length; i++) {
        dices[i] = Random().nextInt(6) + 1;
      }
      _updateAllDiceVisuals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gamble Screen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Roll Results:',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            //all columns
            Expanded(
              child: ListView.builder(
                itemCount: dices.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0), // Spacing between dice rows
                    child: Row(
                      children: <Widget>[
                        //column eyes
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Image.asset(
                              diceEyeImagePaths[index],
                              height: 50,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                print(
                                    "Error loading dice eye image: ${diceEyeImagePaths[index]}, Error: $error");
                                return const Icon(Icons.remove_red_eye_outlined,
                                    size: 40, color: Colors.grey);
                              },
                            ),
                          ),
                        ),

                        // Column value
                        Expanded(
                          child: Center(
                            child: Text(
                              dices[index].toString(),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ),

                        // Column real dice
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Image.asset(
                              realDiceImagePaths[index],
                              height: 50,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                print(
                                    "Error loading real dice image: ${realDiceImagePaths[index]}, Error: $error");
                                return const Icon(Icons.casino_outlined,
                                    size: 40, color: Colors.grey);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            //button roll dice
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: rollDice,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('Roll Dice', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
