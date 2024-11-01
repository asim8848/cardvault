// lib/screens/card_view_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/card_model.dart';
import '../providers/auth_provider.dart';
import '../providers/card_provider.dart';
import '../routes.dart';
import '../utils/size_config.dart';
import '../utils/snackbar_util.dart';
import '../widgets/custom_credit_card.dart';

class CardViewScreen extends StatefulWidget {
  const CardViewScreen({super.key});

  @override
  _CardViewScreenState createState() => _CardViewScreenState();
}

class _CardViewScreenState extends State<CardViewScreen> {
  late String cardId;
  late CardModel card;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCardData();
    });
  }

  void _initializeCardData() {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is String) {
      cardId = args;
      _fetchCardData();
    } else {
      SnackBarUtil.showSnackBar(context, 'Error: Invalid card ID',
          isError: true);
      Navigator.of(context).pop();
    }
  }

  Future<void> _fetchCardData() async {
    final cardProvider = Provider.of<CardProvider>(context, listen: false);
    try {
      card = cardProvider.cards.firstWhere((card) => card.id == cardId);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      SnackBarUtil.showSnackBar(context, 'Error fetching card data: $e',
          isError: true);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF110D44),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: Colors.white, size: SizeConfig.safeBlockHorizontal * 6),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'View Card',
            style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.safeBlockHorizontal * 5),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF110D44),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.white, size: SizeConfig.safeBlockHorizontal * 6),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'View Card',
          style: TextStyle(
              color: Colors.white,
              fontSize: SizeConfig.safeBlockHorizontal * 5),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: SizeConfig.safeBlockVertical * 2),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockHorizontal * 5),
            child: CustomCreditCard(
              cardId: card.id,
              cardType: card.bankName,
              validThru: card.cardValidity,
              cardNumber: card.cardNumber,
              cardHolderName: card.cardHolderName,
              startColor: Color(card.cardColor),
              endColor: Color(card.cardColor).withOpacity(0.7),
              logoAssetName: 'Assets/images/${card.cardType}_logo.png',
              showButtons: false,
              onDropdownToggle: () {},
              alwaysShowFullInfo: true,
            ),
          ),
          const Spacer(),
          _buildButton(
              context, 'Remove Card', Colors.white.withOpacity(0.2), card.id),
          SizedBox(height: SizeConfig.safeBlockVertical * 2),
          _buildButton(
              context, 'Edit Card', Colors.white.withOpacity(0.2), card.id),
          SizedBox(height: SizeConfig.safeBlockVertical * 2),
          _buildButton(context, 'Cancel', Colors.transparent, card.id,
              textColor: Colors.red),
          SizedBox(height: SizeConfig.safeBlockVertical * 2),
        ],
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, Color color, String cardId,
      {Color textColor = Colors.white}) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal * 5),
      child: ElevatedButton(
        onPressed: () {
          if (text == 'Cancel') {
            Navigator.of(context).pop();
          } else if (text == 'Edit Card') {
            Navigator.pushNamed(context, AppRoutes.cardEdit, arguments: cardId);
          } else if (text == 'Remove Card') {
            _deleteCard(context, cardId);
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
      ),
    );
  }

  void _deleteCard(BuildContext context, String cardId) {
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
            'Delete Card',
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConfig.safeBlockHorizontal * 5,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this card? This action cannot be undone.',
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
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  final cardProvider =
                      Provider.of<CardProvider>(context, listen: false);
                  final user = authProvider.user;
                  if (user != null) {
                    await cardProvider.deleteCard(user.uid, cardId);

                    if (mounted) {
                      SnackBarUtil.showSnackBar(
                          context, 'Card deleted successfully');
                      Navigator.of(context)
                          .pop(); // Return to the previous screen
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    SnackBarUtil.showSnackBar(
                        context, 'Error deleting card: $e',
                        isError: true);
                  }
                }
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
}
