// lib/screens/card_main_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cardvault/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/card_model.dart';
import '../providers/auth_provider.dart';
import '../providers/card_provider.dart';
import '../utils/size_config.dart';
import '../utils/theme.dart';
import '../widgets/custom_credit_card.dart';

class CardMainScreen extends StatelessWidget {
  const CardMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final cardProvider = Provider.of<CardProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFF110D44),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text(
          'Your Cards',
          style: TextStyle(
            color: Colors.white,
            fontSize: SizeConfig.safeBlockHorizontal * 6,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: SizeConfig.safeBlockHorizontal * 4),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.profile);
              },
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.1),
                child: user?.photoUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user!.photoUrl!,
                          width: SizeConfig.safeBlockHorizontal * 12,
                          height: SizeConfig.safeBlockHorizontal * 12,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: SizeConfig.safeBlockHorizontal * 7,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: SizeConfig.safeBlockHorizontal * 7,
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => cardProvider.fetchCards(),
          child: _buildCardList(cardProvider),
        ),
      ),
    );
  }

  Widget _buildCardList(CardProvider cardProvider) {
    if (cardProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (cardProvider.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              cardProvider.errorMessage ?? 'An error occurred',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: cardProvider.fetchCards,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (cardProvider.cards.isEmpty) {
      return const Center(
        child: Text(
          'No cards found. Add a card to get started!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return ListView.builder(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.safeBlockHorizontal * 4),
        itemCount: cardProvider.cards.length,
        itemBuilder: (context, index) {
          final CardModel card = cardProvider.cards[index];
          return Column(
            children: [
              CustomCreditCard(
                cardId: card.id,
                cardType: card.bankName,
                validThru: card.cardValidity,
                cardNumber: card.cardNumber,
                cardHolderName: card.cardHolderName,
                startColor: Color(card.cardColor),
                endColor: Color(card.cardColor).withOpacity(0.7),
                logoAssetName: 'Assets/images/${card.cardType}_logo.png',
                onDropdownToggle: () {
                  (context as Element).markNeedsBuild();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
