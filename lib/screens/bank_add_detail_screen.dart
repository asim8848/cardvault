// lib/screens/bank_add_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bank_model.dart';
import '../providers/auth_provider.dart';
import '../providers/bank_provider.dart';
import '../utils/size_config.dart';
import '../utils/snackbar_util.dart';
import '../utils/theme.dart';

class BankAddDetailScreen extends StatefulWidget {
  const BankAddDetailScreen({super.key});

  @override
  _BankAddDetailScreenState createState() => _BankAddDetailScreenState();
}

class _BankAddDetailScreenState extends State<BankAddDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _accountType;
  final List<String> _accountTypes = [
    'Current Account',
    'Savings Account',
    'Salary Account',
    'Fixed Deposit Account'
  ];

  final TextEditingController _accountHolderNameController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _ibanNumberController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _branchCodeController = TextEditingController();
  final TextEditingController _branchNameController = TextEditingController();

  bool _isLoading = false;
  String? _selectedBank;
  List<String> _bankNames = [];
  bool _isAddingNewBank = false;

  @override
  void initState() {
    super.initState();
    _loadBankNames();
  }

  void _loadBankNames() async {
    final bankProvider = Provider.of<BankProvider>(context, listen: false);
    final banks = await bankProvider.getAllBankNames();
    setState(() {
      _bankNames = banks;
    });
  }

  @override
  void dispose() {
    _accountHolderNameController.dispose();
    _accountNumberController.dispose();
    _ibanNumberController.dispose();
    _bankController.dispose();
    _branchCodeController.dispose();
    _branchNameController.dispose();
    super.dispose();
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
          'Add Account',
          style: TextStyle(
              color: Colors.white,
              fontSize: SizeConfig.safeBlockHorizontal * 5),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 5),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add your account details in the boxes below',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.safeBlockHorizontal * 4),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 3),
                _buildTextField(
                    _accountHolderNameController, 'Account Holder Name',
                    validator: _validateName),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                _buildTextField(_accountNumberController, 'Account Number',
                    inputType: TextInputType.number,
                    validator: _validateAccountNumber),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                _buildDropdown(),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                _buildTextField(_ibanNumberController, 'IBAN Number',
                    validator: _validateIBAN),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                _buildBankSelection(),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                _buildTextField(_branchCodeController, 'Branch Code',
                    inputType: TextInputType.number,
                    validator: _validateBranchCode),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                _buildTextField(_branchNameController, 'Branch Name',
                    validator: _validateBranchName),
                SizedBox(height: SizeConfig.safeBlockVertical * 4),
                _buildButton('Add Account', Colors.green),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _accountType,
      style: const TextStyle(color: Colors.white),
      dropdownColor: AppTheme.primaryColor,
      decoration: InputDecoration(
        labelText: 'Account Type',
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
        ),
      ),
      items: _accountTypes.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _accountType = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an account type';
        }
        return null;
      },
    );
  }

  Widget _buildBankSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedBank,
          dropdownColor: AppTheme.primaryColor,
          decoration: InputDecoration(
            labelText: 'Select Bank',
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white30),
              borderRadius:
                  BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius:
                  BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
            ),
          ),
          items: [
            ..._bankNames.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }),
            const DropdownMenuItem<String>(
              value: 'add_new',
              child: Text(
                'Add New Bank',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
          onChanged: (String? newValue) {
            setState(() {
              if (newValue == 'add_new') {
                _isAddingNewBank = true;
                _selectedBank = null;
                _bankController.clear();
              } else {
                _isAddingNewBank = false;
                _selectedBank = newValue;
                _bankController.text = newValue ?? '';
              }
            });
          },
          validator: (value) {
            if ((_selectedBank == null || _selectedBank!.isEmpty) &&
                !_isAddingNewBank) {
              return 'Please select a bank or add a new one';
            }
            return null;
          },
        ),
        if (_isAddingNewBank) ...[
          SizedBox(height: SizeConfig.safeBlockVertical * 2),
          _buildTextField(_bankController, 'New Bank Name',
              validator: _validateBank),
        ],
      ],
    );
  }

  Widget _buildButton(String text, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _addBankAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding:
              EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 2),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                text,
                style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 4),
              ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the account holder name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  String? _validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the account number';
    }
    if (value.length < 8) {
      return 'Account number must be at least 8 digits long';
    }
    return null;
  }

  String? _validateIBAN(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the IBAN number';
    }
    if (!RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]{11,30}$').hasMatch(value)) {
      return 'Please enter a valid IBAN number';
    }
    return null;
  }

  String? _validateBank(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the bank name';
    }
    return null;
  }

  String? _validateBranchCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the branch code';
    }
    if (value.length != 4) {
      return 'Branch code must be 4 digits long';
    }
    return null;
  }

  String? _validateBranchName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the branch name';
    }
    return null;
  }

  void _addBankAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final bankProvider = Provider.of<BankProvider>(context, listen: false);
        final user = authProvider.user;

        if (user != null) {
          final newBank = BankModel(
            id: '',
            name: _accountHolderNameController.text,
            accountNumber: _accountNumberController.text,
            accountType: _accountType!,
            ibanNumber: _ibanNumberController.text,
            bank: _isAddingNewBank ? _bankController.text : _selectedBank!,
            branchCode: _branchCodeController.text,
            branchName: _branchNameController.text,
          );

          await bankProvider.addBank(user.uid, newBank);

          if (_isAddingNewBank) {
            await bankProvider.addBankName(_bankController.text);
          }

          SnackBarUtil.showSnackBar(context, 'Bank account added successfully');
          Navigator.of(context).pop();
        } else {
          throw Exception('User not authenticated');
        }
      } catch (e) {
        SnackBarUtil.showSnackBar(context, 'Error adding bank account: $e',
            isError: true);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
