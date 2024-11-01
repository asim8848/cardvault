// lib/screens/login_screen.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../routes.dart';
import '../utils/size_config.dart';
import '../utils/snackbar_util.dart';
import '../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late FocusNode _emailFocus;
  late FocusNode _passwordFocus;

  @override
  void initState() {
    super.initState();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    _loadRememberMe();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('rememberedEmail') ?? '';
      }
    });
  }

  void _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('rememberedEmail', _emailController.text);
    } else {
      await prefs.remove('rememberedEmail');
    }
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
                            'Welcome\nBack',
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
                          _buildEmailField(),
                          SizedBox(height: SizeConfig.safeBlockVertical * 3),
                          _buildPasswordField(),
                          SizedBox(height: SizeConfig.safeBlockVertical * 2),
                          _buildRememberMeAndForgotPassword(),
                          SizedBox(height: SizeConfig.safeBlockVertical * 4),
                          _buildSignInButton(),
                          SizedBox(height: SizeConfig.safeBlockVertical * 4),
                          _buildSocialButtons(),
                          const Spacer(),
                          _buildSignUpText(),
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
      textInputAction: TextInputAction.done,
      onEditingComplete: _signIn,
      enabled: !_isLoading,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              fillColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Colors.white.withOpacity(.32);
                  }
                  return Colors.white;
                },
              ),
              checkColor: AppTheme.primaryColor,
            ),
            const Text(
              'Remember Me',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.forgotPassword);
          },
          child: const Text(
            'Forgot Password?',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _signIn,
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
              'SIGN IN',
              style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 4),
            ),
    );
  }

  void _signIn() async {
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
        await authProvider.signIn(
          _emailController.text,
          _passwordController.text,
        );
        _saveRememberMe();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        SnackBarUtil.showSnackBar(context, 'Login successful!');
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } on AuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage =
                'No user found with this email. Please check your email or sign up.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is badly formatted.';
            break;
          case 'user-disabled':
            errorMessage =
                'This user account has been disabled. Please contact support.';
            break;
          case 'too-many-requests':
            errorMessage =
                'Too many unsuccessful login attempts. Please try again later.';
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

  Future<void> _signInWithGoogle() async {
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
        SnackBarUtil.showSnackBar(context, 'Google Sign In successful!');
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        SnackBarUtil.showSnackBar(
            context, 'Google Sign In was cancelled. Please try again.',
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
              'Google Sign In is not enabled for this project. Please contact support.';
          break;
        case 'user-disabled':
          errorMessage =
              'This user account has been disabled. Please contact support.';
          break;
        default:
          errorMessage =
              'An error occurred during Google Sign In. Please try again.';
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
            'An unexpected error occurred during Google Sign In. Please try again later.';
      }
      SnackBarUtil.showSnackBar(context, errorMessage,
          isError: true, duration: const Duration(seconds: 5));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSignUpText() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, AppRoutes.signup);
        },
        child: RichText(
          text: const TextSpan(
            text: 'Don\'t have an account? ',
            style: TextStyle(color: Colors.white70),
            children: [
              TextSpan(
                text: 'SIGN UP',
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
          'Sign in using',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.safeBlockHorizontal * 4,
          ),
        ),
        SizedBox(height: SizeConfig.safeBlockVertical * 2),
        Center(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _signInWithGoogle,
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
}
