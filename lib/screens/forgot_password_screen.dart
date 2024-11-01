import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../routes.dart';
import '../services/auth_service.dart';
import '../utils/size_config.dart';
import '../utils/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
              horizontal: SizeConfig.safeBlockHorizontal * 6,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(height: SizeConfig.safeBlockVertical * 4),
                  Text(
                    'Forgot Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.safeBlockHorizontal * 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  Text(
                    'Enter your email address and we\'ll send you a link to reset your password.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: SizeConfig.safeBlockHorizontal * 4,
                    ),
                  ),
                  SizedBox(height: SizeConfig.safeBlockVertical * 6),
                  _buildTextField(
                      'Email', Icons.email_outlined, _emailController),
                  SizedBox(height: SizeConfig.safeBlockVertical * 4),
                  _buildResetPasswordButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hint, IconData icon, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal * 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal * 3),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildResetPasswordButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _resetPassword,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        minimumSize: Size(double.infinity, SizeConfig.safeBlockVertical * 7),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal * 3),
        ),
        elevation: 5,
      ),
      child: _isLoading
          ? SizedBox(
              width: SizeConfig.safeBlockHorizontal * 6,
              height: SizeConfig.safeBlockHorizontal * 6,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            )
          : Text(
              'RESET PASSWORD',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 4,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _authService.resetPassword(_emailController.text);
        _showSuccessDialog();
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'The email address is badly formatted.';
            break;
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }
        _showErrorDialog(errorMessage);
      } catch (e) {
        _showErrorDialog('An unexpected error occurred. Please try again.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal * 4),
        ),
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          'Password Reset',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.safeBlockHorizontal * 5,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'A password reset link has been sent to your email.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: SizeConfig.safeBlockHorizontal * 4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: SizeConfig.safeBlockHorizontal * 4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal * 4),
        ),
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          'Error',
          style: TextStyle(
            color: Colors.red,
            fontSize: SizeConfig.safeBlockHorizontal * 5,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white70,
            fontSize: SizeConfig.safeBlockHorizontal * 4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: SizeConfig.safeBlockHorizontal * 4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
