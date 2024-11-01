import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../routes.dart';
import '../utils/size_config.dart';
import '../utils/theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _showButtons = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Delay to show splash screen effect
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    } else {
      setState(() {
        _showButtons = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockHorizontal * 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: SizeConfig.safeBlockVertical * 5),
                _buildWelcomeImage(),
                SizedBox(height: SizeConfig.safeBlockVertical * 1),
                _buildAppTitle(),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                _buildAppDescription(),
                SizedBox(height: SizeConfig.safeBlockVertical * 8),
                if (_showButtons) ...[
                  _buildSignUpButton(context),
                  SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  _buildLoginButton(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeImage() {
    return Image.asset(
      'Assets/images/welcome_card_img.png',
      width: SizeConfig.safeBlockHorizontal * 80,
      height: SizeConfig.safeBlockVertical * 40,
      fit: BoxFit.contain,
    ).animate().fadeIn(duration: 800.ms).scale(delay: 400.ms);
  }

  Widget _buildAppTitle() {
    return Text(
      'Card Wallet',
      style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: SizeConfig.safeBlockHorizontal * 7,
          ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildAppDescription() {
    return Text(
      'Start your journey to easier wallet management - log in or sign up today!',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: SizeConfig.safeBlockHorizontal * 4,
          ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSignUpButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, AppRoutes.signup);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        padding:
            EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 2),
        minimumSize: Size(double.infinity, SizeConfig.safeBlockVertical * 7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        'SIGN UP',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: SizeConfig.safeBlockHorizontal * 4,
            ),
      ),
    ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding:
            EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 2),
        minimumSize: Size(double.infinity, SizeConfig.safeBlockVertical * 7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        'LOG IN',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: SizeConfig.safeBlockHorizontal * 4,
              color: AppTheme.primaryColor,
            ),
      ),
    ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2, end: 0);
  }
}
