import 'package:flutter/material.dart';

import '../utils/size_config.dart';
import '../utils/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('About', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Vault',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 7,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical * 2),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 4,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical * 3),
            Text(
              'Card Vault is a secure and convenient way to store and manage your financial information. With Card Vault, you can:',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 4,
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical * 2),
            _buildFeatureItem('Store bank account details securely'),
            _buildFeatureItem('Manage multiple credit and debit cards'),
            _buildFeatureItem('Access your information offline'),
            SizedBox(height: SizeConfig.safeBlockVertical * 3),
            Text(
              'Developed by Apsify',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical * 1),
            Text(
              '© 2024 Apsify. All rights reserved.',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle,
              color: AppTheme.accentColor,
              size: SizeConfig.safeBlockHorizontal * 5),
          SizedBox(width: SizeConfig.safeBlockHorizontal * 2),
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
