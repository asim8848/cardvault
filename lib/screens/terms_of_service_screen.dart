import 'package:flutter/material.dart';

import '../utils/size_config.dart';
import '../utils/theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          'Terms of Service',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.safeBlockHorizontal * 6,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 6,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical * 2),
            Text(
              'Last updated: October 17, 2024',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical * 3),
            _buildSection('1. Acceptance of Terms', [
              'By using the CardVault app, you agree to these Terms of Service.',
              'If you do not agree to these terms, please do not use the app.',
            ]),
            _buildSection('2. Description of Service', [
              'CardVault is a mobile application that allows users to securely store and manage their card and bank account information.',
            ]),
            _buildSection('3. User Responsibilities', [
              'You are responsible for maintaining the confidentiality of your account and password.',
              'You agree to provide accurate and complete information when using the app.',
            ]),
            _buildSection('4. Prohibited Activities', [
              'You may not use the app for any illegal or unauthorized purpose.',
              'You may not attempt to gain unauthorized access to any part of the app.',
            ]),
            _buildSection('5. Intellectual Property', [
              'All content and functionality of the app are the exclusive property of CardVault.',
              'You may not reproduce, distribute, or create derivative works without our express permission.',
            ]),
            _buildSection('6. Limitation of Liability', [
              'CardVault is not responsible for any losses or damages resulting from your use of the app.',
              'We do not guarantee the accuracy or completeness of any information stored in the app.',
            ]),
            _buildSection('7. Termination', [
              'We reserve the right to terminate or suspend your account at our sole discretion, without notice, for any reason.',
            ]),
            _buildSection('8. Changes to Terms', [
              'We may modify these terms at any time. Your continued use of the app after changes constitutes acceptance of the new terms.',
            ]),
            _buildSection('9. Contact', [
              'If you have any questions about these Terms of Service, please contact us at: cardvault@apsify.com',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 5,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryColor,
          ),
        ),
        SizedBox(height: SizeConfig.safeBlockVertical),
        ...points.map((point) => _buildBulletPoint(point)),
        SizedBox(height: SizeConfig.safeBlockVertical * 2),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ',
              style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 4)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 4),
            ),
          ),
        ],
      ),
    );
  }
}
