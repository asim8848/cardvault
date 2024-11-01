// lib/screens/bank_edit_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bank_model.dart';
import '../providers/auth_provider.dart';
import '../providers/bank_provider.dart';
import '../utils/size_config.dart';
import '../utils/snackbar_util.dart';
import '../utils/theme.dart';

class BankEditDetailScreen extends StatefulWidget {
  final Map<String, dynamic> accountDetails;

  const BankEditDetailScreen({super.key, required this.accountDetails});

  @override
  _BankEditDetailScreenState createState() => _BankEditDetailScreenState();
}

class _BankEditDetailScreenState extends State<BankEditDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<String>> _bankNamesFuture;

  String? _accountType;
  final List<String> _accountTypes = [
    'Current Account',
    'Savings Account',
    'Salary Account',
    'Fixed Deposit Account'
  ];

  late TextEditingController _accountHolderNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ibanNumberController;
  late TextEditingController _bankController;
  late TextEditingController _branchCodeController;
  late TextEditingController _branchNameController;
  bool _isLoading = false;
  String? _selectedBank;
  final List<String> _bankNames = [];
  bool _isAddingNewBank = false;

  @override
  void initState() {
    super.initState();
    _accountHolderNameController =
        TextEditingController(text: widget.accountDetails['name']);
    _accountNumberController =
        TextEditingController(text: widget.accountDetails['accountNumber']);
    _ibanNumberController =
        TextEditingController(text: widget.accountDetails['ibanNumber']);
    _bankController =
        TextEditingController(text: widget.accountDetails['bank']);
    _branchCodeController =
        TextEditingController(text: widget.accountDetails['branchCode']);
    _branchNameController =
        TextEditingController(text: widget.accountDetails['branchName']);
    _accountType = widget.accountDetails['accountType'];
    _selectedBank = widget.accountDetails['bank'];
    _bankNamesFuture = _loadBankNames();
  }

  Future<List<String>> _loadBankNames() async {
    final bankProvider = Provider.of<BankProvider>(context, listen: false);
    final banks = await bankProvider.getAllBankNames();
    if (_selectedBank != null && !banks.contains(_selectedBank)) {
      banks.add(_selectedBank!);
    }
    return banks;
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
          'Edit Account',
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
                  'Edit your account details in the boxes below',
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
                FutureBuilder<List<String>>(
                  future: _bankNamesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No banks available');
                    } else {
                      return _buildBankSelection(snapshot.data!);
                    }
                  },
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                _buildTextField(_branchCodeController, 'Branch Code',
                    inputType: TextInputType.number,
                    validator: _validateBranchCode),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                _buildTextField(_branchNameController, 'Branch Name',
                    validator: _validateBranchName),
                SizedBox(height: SizeConfig.safeBlockVertical * 4),
                _buildButton('Update Account', Colors.green),
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

  Widget _buildBankSelection(List<String> bankNames) {
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
            ...bankNames.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(color: Colors.white)),
              );
            }),
            const DropdownMenuItem<String>(
              value: 'add_new',
              child:
                  Text('Add New Bank', style: TextStyle(color: Colors.white)),
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
        onPressed: _isLoading ? null : _updateBankAccount,
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

  void _updateBankAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final bankProvider = Provider.of<BankProvider>(context, listen: false);
        final user = authProvider.user;

        if (user != null) {
          final updatedBank = BankModel(
            id: widget.accountDetails['id'],
            name: _accountHolderNameController.text,
            accountNumber: _accountNumberController.text,
            accountType: _accountType!,
            ibanNumber: _ibanNumberController.text,
            bank: _isAddingNewBank ? _bankController.text : _selectedBank!,
            branchCode: _branchCodeController.text,
            branchName: _branchNameController.text,
          );

          await bankProvider.updateBank(user.uid, updatedBank);

          if (_isAddingNewBank) {
            await bankProvider.addBankName(_bankController.text);
          }

          SnackBarUtil.showSnackBar(
              context, 'Bank account updated successfully');
          Navigator.of(context).pop(updatedBank.toMap());
        } else {
          throw Exception('User not authenticated');
        }
      } catch (e) {
        SnackBarUtil.showSnackBar(context, 'Error updating bank account: $e',
            isError: true);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
