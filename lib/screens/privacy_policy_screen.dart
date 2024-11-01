import 'package:flutter/material.dart';

import '../utils/size_config.dart';
import '../utils/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          'Privacy Policy',
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
              'Privacy Policy',
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
            _buildSection('1. Information We Collect', [
              'We collect personal information that you provide to us, such as your name, email address, and profile picture.',
              'We also collect and store the card and bank account information you input into the app.',
            ]),
            _buildSection('2. How We Use Your Information', [
              'We use your personal information to provide and improve our services.',
              'Your card and bank account information is stored securely and is only used to display within the app.',
            ]),
            _buildSection('3. Data Security', [
              'We implement robust security measures to protect your data.',
              'All sensitive information is encrypted and stored securely.',
            ]),
            _buildSection('4. Third-Party Services', [
              'We use Firebase for authentication and data storage.',
              'Google Sign-In is used as an optional authentication method.',
            ]),
            _buildSection('5. Your Rights', [
              'You have the right to access, correct, or delete your personal information.',
              'You can request a copy of your data or ask for its deletion at any time.',
            ]),
            _buildSection('6. Changes to This Policy', [
              'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.',
            ]),
            _buildSection('7. Contact Us', [
              'If you have any questions about this Privacy Policy, please contact us at: cardvault@apsify.com',
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
