// lib/models/card_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CardModel {
  final String id;
  final String bankName;
  final String cardValidity;
  final String cardNumber;
  final String cardHolderName;
  final int cardColor;
  final String cardType;
  final Timestamp createdAt;

  CardModel({
    required this.id,
    required this.bankName,
    required this.cardValidity,
    required this.cardNumber,
    required this.cardHolderName,
    required this.cardColor,
    required this.cardType,
    required this.createdAt,
  });

  factory CardModel.fromMap(Map<String, dynamic> data, String id) {
    return CardModel(
      id: id,
      bankName: data['bankName'] ?? '',
      cardValidity: data['cardValidity'] ?? '',
      cardNumber: data['cardNumber'] ?? '',
      cardHolderName: data['cardHolderName'] ?? '',
      cardColor: data['cardColor'] ?? 0,
      cardType: data['cardType'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bankName': bankName,
      'cardValidity': cardValidity,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'cardColor': cardColor,
      'cardType': cardType,
      'createdAt': createdAt,
    };
  }

  CardModel copyWith({
    String? bankName,
    String? cardValidity,
    String? cardNumber,
    String? cardHolderName,
    int? cardColor,
    String? cardType,
  }) {
    return CardModel(
      id: id,
      bankName: bankName ?? this.bankName,
      cardValidity: cardValidity ?? this.cardValidity,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardColor: cardColor ?? this.cardColor,
      cardType: cardType ?? this.cardType,
      createdAt: createdAt,
    );
  }
}
