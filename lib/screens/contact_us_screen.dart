import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/size_config.dart';
import '../utils/snackbar_util.dart';
import '../utils/theme.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          'Contact Us',
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
              'Contact Us',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 6,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical * 2),
            Text(
              'If you have any questions or need assistance, please contact us at:',
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 4,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: SizeConfig.safeBlockVertical * 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'cardvault@apsify.com',
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 4,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  onPressed: () {
                    Clipboard.setData(
                        const ClipboardData(text: 'cardvault@apsify.com'));
                    SnackBarUtil.showSnackBar(
                      context,
                      'Email address copied to clipboard',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
