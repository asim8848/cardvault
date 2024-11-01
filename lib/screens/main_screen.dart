// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/card_provider.dart';
import '../routes.dart';
import '../utils/size_config.dart';
import '../widgets/animated_add_menu.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_drawer.dart';
import 'bank_main_screen.dart';
import 'card_main_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CardProvider>(context, listen: false).fetchCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              CardMainScreen(key: ValueKey(_currentIndex == 0)),
              BankMainScreen(key: ValueKey(_currentIndex == 1)),
            ],
          ),
          Positioned(
            bottom: SizeConfig.safeBlockVertical * 5,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedAddMenu(
                isOpen: _isMenuOpen,
                onOptionSelected: (String option) {
                  setState(() => _isMenuOpen = false);
                  if (option == 'card_add') {
                    Navigator.pushNamed(context, AppRoutes.cardAdd);
                  } else if (option == 'add_bank') {
                    Navigator.pushNamed(context, AppRoutes.bankAddDetail);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _isMenuOpen = !_isMenuOpen),
        backgroundColor: const Color(0xFF332D75),
        elevation: 8,
        shape: const CircleBorder(),
        child: Icon(
          _isMenuOpen ? Icons.close : Icons.add,
          color: Colors.white,
          size: SizeConfig.safeBlockHorizontal * 8,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Provider.of<CardProvider>(context, listen: false).fetchCards();
          }
        },
      ),
    );
  }
}
