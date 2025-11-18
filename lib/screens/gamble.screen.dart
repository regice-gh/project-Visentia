import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GambleScreen extends StatefulWidget {
  const GambleScreen({super.key});

  @override
  State<GambleScreen> createState() => _GambleScreenState();
}

class _GambleScreenState extends State<GambleScreen> {
  final List<int> dices = List.generate(
      5, (_) => Random().nextInt(6) + 1); //(_) loop index parameter, not used
  final List<String> diceEyeImagePaths = [];
  final List<String> realDiceImagePaths = [];
  String _handResult = 'Roll the dice to reveal the hand.';

  @override
  void initState() {
    super.initState();
    _refreshState();
  }

  void _refreshState() {
    diceEyeImagePaths
      ..clear()
      ..addAll(dices.map(
        (value) => 'assets/img/dice_eyes/dice_eyes_$value.jpg',
      ));

    realDiceImagePaths
      ..clear()
      ..addAll(dices.map(
        (value) => 'assets/img/real_dice/real_dice_$value.jpg',
      ));

    _handResult = _describeHand(dices);
  }

  void rollDice() {
    setState(() {
      for (int i = 0; i < dices.length; i++) {
        dices[i] = Random().nextInt(6) + 1;
      }
      _refreshState();
    });
  }

  String _describeHand(List<int> dice) {
    final sortedDice = [...dice]..sort(); //use copy so the UI doesn't break
    final counts = <int, int>{};

    for (final value in sortedDice) {
      counts.update(value, (prev) => prev + 1, ifAbsent: () => 1);
    }

    final occurrences = counts.values.toList()..sort((a, b) => b.compareTo(a));
    final pairCount = occurrences.where((value) => value == 2).length;

    if (occurrences.first == 5) {
      return 'Five of a kind';
    }
    if (occurrences.first == 4) {
      return 'Four of a kind';
    }
    if (occurrences.contains(3) && occurrences.contains(2)) {
      return 'Full house';
    }
    if (_isStraight(sortedDice, high: true)) {
      return 'High straight (A K Q J 10)';
    }
    if (_isStraight(sortedDice, high: false)) {
      return 'Low straight (K Q J 10 9)';
    }
    if (occurrences.first == 3) {
      return 'Three of a kind';
    }
    if (pairCount == 2) {
      return 'Two pair';
    }
    if (occurrences.first == 2) {
      return 'One pair';
    }
    return 'Bust';
  }

  bool _isStraight(List<int> sortedDice, {required bool high}) {
    final unique = sortedDice.toSet();
    if (unique.length != 5) {
      return false;
    }
    final target = high ? [2, 3, 4, 5, 6] : [1, 2, 3, 4, 5];
    return listEquals(unique.toList()..sort(), target);
  }

  String _faceName(int value) {
    const labels = {
      1: '9',
      2: '10',
      3: 'J',
      4: 'Q',
      5: 'K',
      6: 'A',
    };
    return labels[value] ?? value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamble Screen'),
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Dice poker ranks (highest to lowest): Five of a kind, Four of a kind, Full house, High straight, Low straight, Three of a kind, Two pair, One pair, Bust.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.section),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.section),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current result',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      _handResult,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            Expanded(
              child: ListView.separated(
                itemCount: dices.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.item),
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.item),
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            diceEyeImagePaths[index],
                            height: 60,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.remove_red_eye_outlined,
                                  size: 40, color: Colors.grey);
                            },
                          ),
                          const SizedBox(width: AppSpacing.item),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Die ${index + 1}',
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  'Value: ${_faceName(dices[index])}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.item),
                          Image.asset(
                            realDiceImagePaths[index],
                            height: 60,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.casino_outlined,
                                  size: 40, color: Colors.grey);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.section),
            ElevatedButton(
              onPressed: rollDice,
              child: const Text('Roll dice'),
            ),
          ],
        ),
      ),
    );
  }
}
