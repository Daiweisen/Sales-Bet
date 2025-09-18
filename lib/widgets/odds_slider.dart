import 'package:flutter/material.dart';

class OddsSlider extends StatefulWidget {
  final double currentOdds;
  final double initialBetAmount;
  final Function(int) onBetAmountChanged;

  const OddsSlider({
    super.key,
    required this.currentOdds,
    required this.initialBetAmount,
    required this.onBetAmountChanged,
  });

  @override
  State<OddsSlider> createState() => _OddsSliderState();
}

class _OddsSliderState extends State<OddsSlider> {
  late double _betAmount;
  late int _intBetAmount;

  @override
  void initState() {
    super.initState();
    _betAmount = widget.initialBetAmount;
    _intBetAmount = _betAmount.toInt();
  }

  @override
  Widget build(BuildContext context) {
    double potentialWinnings = _intBetAmount * widget.currentOdds;

    return Column(
      children: [
        Text(
          'Bet Amount: \$$_intBetAmount',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Slider(
          value: _betAmount,
          min: 0,
          max: 1000,
          divisions: 100, // For 100 steps
          onChanged: (double newValue) {
            setState(() {
              _betAmount = newValue;
              _intBetAmount = newValue.toInt();
            });
            widget.onBetAmountChanged(_intBetAmount);
          },
        ),
        Text(
          'Potential Win: \$${potentialWinnings.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}