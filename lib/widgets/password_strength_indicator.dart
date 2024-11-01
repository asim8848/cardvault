import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final double strength;

  const PasswordStrengthIndicator({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password Strength:',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: strength,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(_getColor(strength)),
        ),
        const SizedBox(height: 5),
        Text(
          _getStrengthText(strength),
          style: TextStyle(color: _getColor(strength)),
        ),
      ],
    );
  }

  Color _getColor(double strength) {
    if (strength < 0.3) return Colors.red;
    if (strength < 0.7) return Colors.orange;
    return Colors.green;
  }

  String _getStrengthText(double strength) {
    if (strength < 0.3) return 'Weak';
    if (strength < 0.7) return 'Moderate';
    return 'Strong';
  }
}
