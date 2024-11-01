// lib/screens/bank_details_view_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/bank_provider.dart';
import '../routes.dart';
import '../utils/size_config.dart';
import '../utils/snackbar_util.dart';
import '../utils/theme.dart';

class BankDetailsViewScreen extends StatefulWidget {
  final Map<String, dynamic> accountDetails;

  const BankDetailsViewScreen({super.key, required this.accountDetails});

  @override
  _BankDetailsViewScreenState createState() => _BankDetailsViewScreenState();
}

class _BankDetailsViewScreenState extends State<BankDetailsViewScreen> {
  late Map<String, dynamic> _accountDetails;

  @override
  void initState() {
    super.initState();
    _accountDetails = Map.from(widget.accountDetails);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.white, size: SizeConfig.safeBlockHorizontal * 6),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Account Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.safeBlockHorizontal * 5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccountHolder(),
                    SizedBox(height: SizeConfig.safeBlockVertical * 4),
                    _buildAccountDetails(context),
                  ],
                ),
              ),
            ),
          ),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildAccountHolder() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          radius: SizeConfig.safeBlockHorizontal * 8,
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: SizeConfig.safeBlockHorizontal * 8,
          ),
        ),
        SizedBox(width: SizeConfig.safeBlockHorizontal * 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _accountDetails['name'] ?? 'N/A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.safeBlockHorizontal * 5,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _accountDetails['accountType'] ?? 'N/A',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDetails(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Account Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.safeBlockHorizontal * 4.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _copyAllToClipboard(context),
              child: Text(
                'Copy All',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: SizeConfig.safeBlockVertical * 2),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius:
                BorderRadius.circular(SizeConfig.safeBlockHorizontal * 4),
          ),
          padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 4),
          child: Column(
            children: [
              _buildDetailRow(context, 'Account Number',
                  _accountDetails['accountNumber']?.toString() ?? ''),
              _buildDetailRow(context, 'IBAN Number',
                  _accountDetails['ibanNumber']?.toString() ?? '',
                  isIBAN: true),
              _buildDetailRow(context, 'Branch Name',
                  _accountDetails['branchName']?.toString() ?? ''),
              _buildDetailRow(context, 'Branch Code',
                  _accountDetails['branchCode']?.toString() ?? ''),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value,
      {bool isIBAN = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
            ),
          ),
          SizedBox(width: SizeConfig.safeBlockHorizontal * 2),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: isIBAN
                      ? SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        )
                      : Text(
                          value,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                ),
                SizedBox(width: SizeConfig.safeBlockHorizontal * 2),
                GestureDetector(
                  onTap: () => _copyToClipboard(context, value),
                  child: Icon(
                    Icons.copy,
                    color: Colors.white.withOpacity(0.7),
                    size: SizeConfig.safeBlockHorizontal * 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 5),
      child: Column(
        children: [
          _buildButton(
              context, 'Remove Account', Colors.white.withOpacity(0.2)),
          SizedBox(height: SizeConfig.safeBlockVertical * 2),
          _buildButton(context, 'Edit Account', Colors.white.withOpacity(0.2)),
          SizedBox(height: SizeConfig.safeBlockVertical * 2),
          _buildButton(context, 'Cancel', Colors.transparent,
              textColor: Colors.red),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, Color color,
      {Color textColor = Colors.white}) {
    return ElevatedButton(
      onPressed: () async {
        if (text == 'Cancel') {
          Navigator.of(context).pop();
        } else if (text == 'Edit Account') {
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.bankEditDetail,
            arguments: _accountDetails,
          );
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              _accountDetails = result;
            });
          }
        } else if (text == 'Remove Account') {
          _showDeleteConfirmationDialog(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        minimumSize: Size(double.infinity, SizeConfig.safeBlockVertical * 6),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2.5),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 4),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar(context, 'Copied to clipboard');
  }

  void _copyAllToClipboard(BuildContext context) {
    final allDetails = _accountDetails.entries
        .where((e) => e.key != 'id') // Exclude the 'id' field
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
    Clipboard.setData(ClipboardData(text: allDetails));
    _showSnackBar(context, 'All details copied to clipboard');
  }

  void _showSnackBar(BuildContext context, String message) {
    SnackBarUtil.showSnackBar(context, message);
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(SizeConfig.safeBlockHorizontal * 4),
          ),
          backgroundColor: const Color(0xFF110D44),
          title: Text(
            'Delete Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConfig.safeBlockHorizontal * 5,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this bank account? This action cannot be undone.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteAccount(context);
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bankProvider = Provider.of<BankProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null) {
        await bankProvider.deleteBank(user.uid, _accountDetails['id']);
        SnackBarUtil.showSnackBar(context, 'Bank account deleted successfully');
        Navigator.of(context).pop(); // Return to the previous screen
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      SnackBarUtil.showSnackBar(context, 'Error deleting bank account: $e',
          isError: true);
    }
  }
}
