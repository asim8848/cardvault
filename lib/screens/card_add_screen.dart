// lib/screens/card_add_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/card_model.dart';
import '../providers/auth_provider.dart';
import '../providers/card_provider.dart';
import '../routes.dart';
import '../utils/card_validity_formatter.dart';
import '../utils/size_config.dart';
import '../utils/snackbar_util.dart';
import '../widgets/custom_credit_card.dart';

class CardAddScreen extends StatefulWidget {
  const CardAddScreen({super.key});

  @override
  _CardAddScreenState createState() => _CardAddScreenState();
}

class _CardAddScreenState extends State<CardAddScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _cardValidityController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();

  bool _isLoading = false;

  String bankName = 'Bank Name';
  String cardValidity = 'MM/YY';
  String cardNumber = 'XXXX XXXX XXXX XXXX';
  String cardHolderName = 'Card Holder Name';
  String cardType = 'no_logo';

  Color startColor = Colors.purple.shade300;
  Color endColor = Colors.purple.shade100;

  final List<Color> predefinedColors = [
    Colors.purple.shade300,
    Colors.blue.shade300,
    Colors.green.shade300,
    Colors.orange.shade300,
    Colors.red.shade300,
    Colors.teal.shade300,
    Colors.pink.shade300,
    Colors.indigo.shade300,
    Colors.cyan.shade300,
    Colors.amber.shade300,
    Colors.lime.shade300,
    Colors.deepOrange.shade300,
    Colors.lightBlue.shade300,
    Colors.deepPurple.shade300,
    Colors.yellow.shade300,
    Colors.lightGreen.shade300,
  ];

  final List<String> cardTypes = [
    'visa',
    'mastercard',
    'amex',
    'discover',
    'no_logo'
  ];

  @override
  void dispose() {
    _bankNameController.dispose();
    _cardValidityController.dispose();
    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: const Color(0xFF110D44),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add Card', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomCreditCard(
                  cardId: 'new_card',
                  cardType: bankName,
                  validThru: cardValidity,
                  cardNumber: cardNumber,
                  cardHolderName: cardHolderName,
                  startColor: startColor,
                  endColor: endColor,
                  logoAssetName: cardType != 'no_logo'
                      ? 'Assets/images/${cardType}_logo.png'
                      : null,
                  showButtons: false,
                  onDropdownToggle: () {},
                  alwaysShowFullInfo: true,
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                Text(
                  'Card Color',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.safeBlockHorizontal * 4,
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 1),
                _buildColorPicker(),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                Text(
                  'Card Type',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.safeBlockHorizontal * 4,
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 1),
                _buildCardTypePicker(),
                SizedBox(height: SizeConfig.safeBlockVertical * 4),
                _buildTextField(
                  controller: _bankNameController,
                  label: 'Bank Name',
                  icon: Icons.account_balance,
                  onChanged: (value) => setState(() => bankName = value),
                  maxLength: 20,
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                _buildTextField(
                  controller: _cardValidityController,
                  label: 'Card Validity (Optional)',
                  icon: Icons.calendar_today,
                  onChanged: (value) => setState(() => cardValidity = value),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CardValidityFormatter(),
                  ],
                  keyboardType: TextInputType.number,
                  maxLength: 7,
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                _buildTextField(
                  controller: _cardNumberController,
                  label: 'Card Number',
                  icon: Icons.credit_card,
                  onChanged: (value) => setState(() => cardNumber = value),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _CardNumberFormatter(),
                  ],
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                _buildTextField(
                  controller: _cardHolderNameController,
                  label: 'Card Holder Name',
                  icon: Icons.person,
                  onChanged: (value) => setState(() => cardHolderName = value),
                  maxLength: 30,
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 4),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text('Add Card'),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: SizeConfig.safeBlockHorizontal * 4,
            vertical: SizeConfig.safeBlockVertical * 2,
          ),
          counterText: '',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildColorPicker() {
    return SizedBox(
      height: SizeConfig.safeBlockVertical * 6,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: predefinedColors.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                startColor = predefinedColors[index];
                endColor = predefinedColors[index].withOpacity(0.7);
              });
            },
            child: Container(
              width: SizeConfig.safeBlockHorizontal * 10,
              height: SizeConfig.safeBlockHorizontal * 10,
              margin:
                  EdgeInsets.only(right: SizeConfig.safeBlockHorizontal * 2),
              decoration: BoxDecoration(
                color: predefinedColors[index],
                shape: BoxShape.circle,
                border: Border.all(
                  color: startColor == predefinedColors[index]
                      ? Colors.white
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardTypePicker() {
    return SizedBox(
      height: SizeConfig.safeBlockVertical * 10,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cardTypes.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                cardType = cardTypes[index];
              });
            },
            child: Container(
              width: SizeConfig.safeBlockHorizontal * 20,
              height: SizeConfig.safeBlockHorizontal * 20,
              margin:
                  EdgeInsets.only(right: SizeConfig.safeBlockHorizontal * 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: cardType == cardTypes[index]
                      ? Colors.blue
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: cardTypes[index] != 'no_logo'
                  ? Image.asset(
                      'Assets/images/${cardTypes[index]}_logo.png',
                      fit: BoxFit.contain,
                    )
                  : const Center(child: Text('No Logo')),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addCard() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = Provider.of<AuthProvider>(context, listen: false).user;
        final cardProvider = Provider.of<CardProvider>(context, listen: false);

        if (user != null) {
          final newCard = CardModel(
            id: '', // This will be set by Firestore
            bankName: _bankNameController.text,
            cardValidity: _cardValidityController.text,
            cardNumber: _cardNumberController.text,
            cardHolderName: _cardHolderNameController.text,
            cardColor: startColor.value,
            cardType: cardType,
            createdAt: Timestamp.now(),
          );

          await cardProvider.addCard(user.uid, newCard);

          SnackBarUtil.showSnackBar(
            context,
            'Card added successfully',
            isError: false,
          );

          // Navigate to the main screen without keeping the backstack

          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.main,
            (Route<dynamic> route) => false,
          );
        } else {
          throw Exception('User not authenticated');
        }
      } catch (e) {
        SnackBarUtil.showSnackBar(
          context,
          'Error adding card: $e',
          isError: true,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
