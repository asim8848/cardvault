import 'package:flutter/material.dart';

import '../routes.dart';

class AnimatedAddMenu extends StatelessWidget {
  final bool isOpen;
  final Function(String) onOptionSelected;

  const AnimatedAddMenu({
    super.key,
    required this.isOpen,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isOpen,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      child: AnimatedOpacity(
        opacity: isOpen ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: IgnorePointer(
          ignoring: !isOpen,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuOption(
                    Icons.credit_card, 'Add Card', 'card_add', context),
                const SizedBox(width: 20),
                _buildMenuOption(Icons.account_balance, 'Add Bank',
                    'bank_add_detail', context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(
      IconData icon, String label, String value, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (value == 'bank_add_detail') {
          Navigator.pushNamed(context, AppRoutes.bankAddDetail);
        } else {
          onOptionSelected(value);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF110D44),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF110D44),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
