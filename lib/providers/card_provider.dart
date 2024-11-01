// lib/providers/card_provider.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/card_model.dart';
import '../models/user_model.dart';

class CardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CardModel> _cards = [];
  final Map<String, bool> _revealedCards = {};
  final Map<String, Timer> _revealTimers = {};
  String? _activeDropdownCardId;
  Timer? _dropdownTimer;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  UserModel? _user;

  List<CardModel> get cards => _cards;
  bool isCardRevealed(String cardId) => _revealedCards[cardId] ?? false;
  bool isDropdownOpen(String cardId) => _activeDropdownCardId == cardId;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  void updateUser(UserModel? user) {
    _user = user;
    if (user != null) {
      fetchCards();
    } else {
      _cards = [];
      notifyListeners();
    }
  }

  Future<void> fetchCards() async {
    if (_user == null) return;

    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('cards')
          .get();

      _cards = snapshot.docs
          .map((doc) => CardModel.fromMap(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Failed to load cards. Please try again.';
      notifyListeners();
    }
  }

  Future<void> addCard(String userId, CardModel card) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cards')
          .add(card.toMap());

      final newCard = CardModel.fromMap(card.toMap(), docRef.id);
      _cards.add(newCard);

      notifyListeners();
    } catch (e) {}
  }

  Future<void> updateCard(String userId, CardModel card) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cards')
          .doc(card.id)
          .update(card.toMap());

      final index = _cards.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        _cards[index] = card;
        notifyListeners();
      }
    } catch (e) {}
  }

  Future<void> deleteCard(String userId, String cardId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cards')
          .doc(cardId)
          .delete();

      _cards.removeWhere((card) => card.id == cardId);
      notifyListeners();
    } catch (e) {}
  }

  void toggleReveal(String cardId) {
    bool newRevealState = !(_revealedCards[cardId] ?? false);
    _revealedCards[cardId] = newRevealState;

    if (newRevealState) {
      _startRevealTimer(cardId);
    } else {
      _cancelRevealTimer(cardId);
    }

    notifyListeners();
  }

  void _startRevealTimer(String cardId) {
    _cancelRevealTimer(cardId);
    _revealTimers[cardId] = Timer(const Duration(seconds: 30), () {
      _revealedCards[cardId] = false;
      notifyListeners();
    });
  }

  void _cancelRevealTimer(String cardId) {
    _revealTimers[cardId]?.cancel();
    _revealTimers.remove(cardId);
  }

  void toggleDropdown(String cardId) {
    if (_activeDropdownCardId == cardId) {
      closeDropdown();
    } else {
      closeDropdown(); // Close any previously open dropdown
      _activeDropdownCardId = cardId;
      _startDropdownTimer();
    }
    notifyListeners();
  }

  void closeDropdown() {
    _activeDropdownCardId = null;
    _cancelDropdownTimer();
    notifyListeners();
  }

  void _startDropdownTimer() {
    _cancelDropdownTimer();
    _dropdownTimer = Timer(const Duration(seconds: 7), closeDropdown);
  }

  void _cancelDropdownTimer() {
    _dropdownTimer?.cancel();
    _dropdownTimer = null;
  }

  void resetDropdownTimer() {
    if (_activeDropdownCardId != null) {
      _startDropdownTimer();
    }
  }

  void resetRevealTimer(String cardId) {
    if (_revealedCards[cardId] == true) {
      _startRevealTimer(cardId);
    }
  }

  @override
  void dispose() {
    _cancelDropdownTimer();
    _revealTimers.forEach((_, timer) => timer.cancel());
    _revealTimers.clear();
    super.dispose();
  }

  void resetLoadingState() {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }
}
