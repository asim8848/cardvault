// lib/config/routes.dart

import 'package:cardvault/screens/contact_us_screen.dart';
import 'package:flutter/material.dart';

import '../screens/about_screen.dart';
import '../screens/bank_add_detail_screen.dart';
import '../screens/bank_details_view_screen.dart';
import '../screens/bank_edit_detail_screen.dart';
import '../screens/bank_main_screen.dart';
import '../screens/card_add_screen.dart';
import '../screens/card_edit_screen.dart';
import '../screens/card_main_screen.dart';
import '../screens/card_view_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/terms_of_service_screen.dart';
import '../screens/welcome_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String main = '/main';
  static const String cardMain = '/card_main';
  static const String cardView = '/card_view';
  static const String cardAdd = '/card_add';
  static const String cardEdit = '/card_edit';
  static const String bankMain = '/bank_main';
  static const String bankDetailsView = '/bank_details_view';
  static const String bankAddDetail = '/bank_add_detail';
  static const String bankEditDetail = '/bank_edit_detail';
  static const String forgotPassword = '/forgot_password';
  static const String profile = '/profile';
  static const String privacyPolicy = '/privacy_policy';
  static const String termsOfService = '/terms_of_service';
  static const String about = '/about';
  static const String contactUs = '/contact_us';
  static const String suggestion = '/suggestion';

  static Map<String, WidgetBuilder> get routes => {
        welcome: (context) => const WelcomeScreen(),
        signup: (context) => const SignupScreen(),
        login: (context) => const LoginScreen(),
        main: (context) => const MainScreen(),
        cardMain: (context) => const CardMainScreen(),
        cardView: (context) => const CardViewScreen(),
        cardAdd: (context) => const CardAddScreen(),
        cardEdit: (context) => const CardEditScreen(),
        bankMain: (context) => const BankMainScreen(),
        bankDetailsView: (context) => BankDetailsViewScreen(
              accountDetails: (ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>),
            ),
        bankAddDetail: (context) => const BankAddDetailScreen(),
        bankEditDetail: (context) => BankEditDetailScreen(
              accountDetails: (ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>),
            ),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        profile: (context) => ProfileScreen(),
        privacyPolicy: (context) => const PrivacyPolicyScreen(),
        termsOfService: (context) => const TermsOfServiceScreen(),
        about: (context) => const AboutScreen(),
        contactUs: (context) => const ContactUsScreen(),
      };
}
