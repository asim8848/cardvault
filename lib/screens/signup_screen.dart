// lib/screens/signup_screen.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../routes.dart';
import '../utils/size_config.dart';
import '../utils/snackbar_util.dart';
import '../utils/theme.dart';
import '../widgets/password_strength_indicator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late FocusNode _nameFocus;
  late FocusNode _emailFocus;
  late FocusNode _passwordFocus;
  late FocusNode _confirmPasswordFocus;

  double _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _nameFocus = FocusNode();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.safeBlockHorizontal * 6),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: SizeConfig.safeBlockVertical * 2),
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.welcome,
                              (Route<dynamic> route) => false,
                            ),
                          ),
                          SizedBox(height: SizeConfig.safeBlockVertical * 4),
                          Text(
                            'Create\nAccount',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  fontSize: SizeConfig.safeBlockHorizontal * 10,
                                  height: 1.2,
                                  color: Colors.white,
                                ),
                          ),
                          SizedBox(height: SizeConfig.safeBlockVertical * 6),
                          _buildNameField(),
                          SizedBox(height: SizeConfig.safeBlockVertical * 2),
                          _buildEmailField(),
                          SizedBox(height: SizeConfig.safeBlockVertical * 2),
                          _buildPasswordField(),
                          SizedBox(height: SizeConfig.safeBlockVertical * 1),
                          PasswordStrengthIndicator(
                              strength: _passwordStrength),
                          SizedBox(height: SizeConfig.safeBlockVertical * 2),
                          _buildConfirmPasswordField(),
                          SizedBox(height: SizeConfig.safeBlockVertical * 4),
                          _buildSignUpButton(),
                          SizedBox(height: SizeConfig.safeBlockVertical * 3),
                          _buildSocialButtons(),
                          const Spacer(),
                          _buildSignInText(),
                          SizedBox(height: SizeConfig.safeBlockVertical * 2),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        hintText: 'Name',
        hintStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocus,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        hintText: 'Email',
        hintStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        errorMaxLines: 2,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onEditingComplete: () =>
          _fieldFocusChange(context, _emailFocus, _passwordFocus),
      enabled: !_isLoading,
      autocorrect: false,
      autofillHints: const [AutofillHints.email],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        final emailRegEx = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegEx.hasMatch(value.trim())) {
          return 'Please enter a valid email address';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _emailController.text = value.trim();
          _emailController.selection = TextSelection.fromPosition(
              TextPosition(offset: _emailController.text.length));
        });
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocus,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          tooltip: _isPasswordVisible ? 'Hide password' : 'Show password',
        ),
        enabledBorder:
            const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
        focusedBorder:
            const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      textInputAction: TextInputAction.next,
      onEditingComplete: () =>
          _fieldFocusChange(context, _passwordFocus, _confirmPasswordFocus),
      enabled: !_isLoading,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters long';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _passwordStrength = _calculatePasswordStrength(value);
        });
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocus,
      obscureText: !_isConfirmPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Confirm Password',
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
          tooltip:
              _isConfirmPasswordVisible ? 'Hide password' : 'Show password',
        ),
        enabledBorder:
            const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
        focusedBorder:
            const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      textInputAction: TextInputAction.done,
      onEditingComplete: _signUp,
      enabled: !_isLoading,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _signUp,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        minimumSize: Size(double.infinity, SizeConfig.safeBlockVertical * 7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
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
              'SIGN UP',
              style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 4),
            ),
    );
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.none) {
          throw Exception('No internet connection');
        }

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.signUp(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        SnackBarUtil.showSnackBar(
            context, 'Sign up successful! Welcome to Card Vault.');
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } on AuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage =
                'An account already exists with this email. Please use a different email or try signing in.';
            break;
          case 'invalid-email':
            errorMessage =
                'The email address is badly formatted. Please enter a valid email.';
            break;
          case 'weak-password':
            errorMessage =
                'The password is too weak. Please choose a stronger password.';
            break;
          case 'operation-not-allowed':
            errorMessage =
                'Email/password accounts are not enabled. Please contact support.';
            break;
          default:
            errorMessage = e.message;
        }
        SnackBarUtil.showSnackBar(context, errorMessage,
            isError: true, duration: const Duration(seconds: 5));
      } catch (e) {
        String errorMessage;
        if (e.toString().contains('internet')) {
          errorMessage =
              'No internet connection. Please check your network settings and try again.';
        } else {
          errorMessage =
              'An unexpected error occurred. Please try again later.';
        }
        SnackBarUtil.showSnackBar(context, errorMessage,
            isError: true, duration: const Duration(seconds: 5));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No internet connection');
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userCredential = await authProvider.signInWithGoogle();
      if (userCredential != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        SnackBarUtil.showSnackBar(
            context, 'Google Sign Up successful! Welcome to Card Vault.');
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        SnackBarUtil.showSnackBar(
            context, 'Google Sign Up was cancelled. Please try again.',
            isError: true);
      }
    } on AuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage =
              'An account already exists with the same email address but different sign-in credentials. Please try signing in with a different method.';
          break;
        case 'invalid-credential':
          errorMessage =
              'The provided Google credential is invalid. Please try again.';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'Google Sign Up is not enabled for this project. Please contact support.';
          break;
        case 'user-disabled':
          errorMessage =
              'This user account has been disabled. Please contact support.';
          break;
        default:
          errorMessage =
              'An error occurred during Google Sign Up. Please try again.';
      }
      SnackBarUtil.showSnackBar(context, errorMessage,
          isError: true, duration: const Duration(seconds: 5));
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('internet')) {
        errorMessage =
            'No internet connection. Please check your network settings and try again.';
      } else {
        errorMessage =
            'An unexpected error occurred during Google Sign Up. Please try again later.';
      }
      SnackBarUtil.showSnackBar(context, errorMessage,
          isError: true, duration: const Duration(seconds: 5));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSignInText() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        },
        child: RichText(
          text: const TextSpan(
            text: 'Already have an account? ',
            style: TextStyle(color: Colors.white70),
            children: [
              TextSpan(
                text: 'SIGN IN',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        Text(
          'Sign up using',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.safeBlockHorizontal * 4,
          ),
        ),
        SizedBox(height: SizeConfig.safeBlockVertical * 2),
        Center(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _signUpWithGoogle,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.safeBlockVertical * 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'Assets/images/google_icon.png',
                    height: SizeConfig.safeBlockHorizontal * 6,
                    width: SizeConfig.safeBlockHorizontal * 6,
                  ),
                  SizedBox(width: SizeConfig.safeBlockHorizontal * 2),
                  Text(
                    'Google',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: SizeConfig.safeBlockHorizontal * 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculatePasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.2;
    if (password.contains(RegExp(r'\d'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;
    return strength > 1 ? 1 : strength;
  }
}
