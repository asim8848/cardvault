// lib/screens/card_edit_screen.dart

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

class CardEditScreen extends StatefulWidget {
  const CardEditScreen({super.key});

  @override
  _CardEditScreenState createState() => _CardEditScreenState();
}

class _CardEditScreenState extends State<CardEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _cardValidityController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderNameController =
      TextEditingController();

  bool _isUpdating = false;

  late CardModel _card;
  bool _isLoading = true;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCardData();
    });
  }

  void _initializeCardData() {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      String cardId = args;
      _card = cardProvider.cards.firstWhere((card) => card.id == cardId);
      _populateFields();
    } else {
      setState(() {
        _isLoading = false;
      });
      SnackBarUtil.showSnackBar(context, 'Error: Invalid card ID',
          isError: true);
    }
  }

  void _populateFields() {
    setState(() {
      _bankNameController.text = _card.bankName;
      _cardValidityController.text = _card.cardValidity;
      _cardNumberController.text = _card.cardNumber;
      _cardHolderNameController.text = _card.cardHolderName;
      _isLoading = false;
    });
  }

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
        title: const Text('Edit Card', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomCreditCard(
                        cardId: _card.id,
                        cardType: _card.bankName,
                        validThru: _card.cardValidity,
                        cardNumber: _card.cardNumber,
                        cardHolderName: _card.cardHolderName,
                        startColor: Color(_card.cardColor),
                        endColor: Color(_card.cardColor).withOpacity(0.7),
                        logoAssetName: _card.cardType != 'no_logo'
                            ? 'Assets/images/${_card.cardType}_logo.png'
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
                            fontSize: SizeConfig.safeBlockHorizontal * 4),
                      ),
                      SizedBox(height: SizeConfig.safeBlockVertical * 1),
                      _buildColorPicker(),
                      SizedBox(height: SizeConfig.safeBlockVertical * 2),
                      Text(
                        'Card Type',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeConfig.safeBlockHorizontal * 4),
                      ),
                      SizedBox(height: SizeConfig.safeBlockVertical * 1),
                      _buildCardTypePicker(),
                      SizedBox(height: SizeConfig.safeBlockVertical * 4),
                      _buildTextField(
                        controller: _bankNameController,
                        label: 'Bank Name',
                        icon: Icons.account_balance,
                        onChanged: (value) => setState(
                            () => _card = _card.copyWith(bankName: value)),
                        maxLength: 20,
                      ),
                      SizedBox(height: SizeConfig.safeBlockVertical * 2),
                      _buildTextField(
                        controller: _cardValidityController,
                        label: 'Card Validity (Optional)',
                        icon: Icons.calendar_today,
                        onChanged: (value) => setState(
                            () => _card = _card.copyWith(cardValidity: value)),
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
                        onChanged: (value) => setState(
                            () => _card = _card.copyWith(cardNumber: value)),
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
                        onChanged: (value) => setState(() =>
                            _card = _card.copyWith(cardHolderName: value)),
                        maxLength: 30,
                      ),
                      SizedBox(height: SizeConfig.safeBlockVertical * 4),
                      ElevatedButton(
                        onPressed: _isUpdating ? null : _updateCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isUpdating
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Update Card'),
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
      child: TextField(
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
                _card =
                    _card.copyWith(cardColor: predefinedColors[index].value);
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
                  color: _card.cardColor == predefinedColors[index].value
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
                _card = _card.copyWith(cardType: cardTypes[index]);
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
                  color: _card.cardType == cardTypes[index]
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

  Future<void> _updateCard() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cardProvider = Provider.of<CardProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null) {
        await cardProvider.updateCard(user.uid, _card);

        SnackBarUtil.showSnackBar(
          context,
          'Card updated successfully',
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
        'Error updating card: $e',
        isError: true,
      );
    } finally {
      setState(() {
        _isUpdating = false;
      });
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
