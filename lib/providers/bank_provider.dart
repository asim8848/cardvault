// lib/providers/bank_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/bank_model.dart';

class BankProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<BankModel> _banks = [];

  List<BankModel> get banks => _banks;

  Future<void> fetchBanks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('banks')
          .get();

      _banks = snapshot.docs
          .map((doc) => BankModel.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {}
  }

  Future<void> addBank(String userId, BankModel bank) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('banks')
          .add(bank.toMap());

      final newBank = BankModel.fromMap(bank.toMap(), docRef.id);
      _banks.add(newBank);

      notifyListeners();
    } catch (e) {}
  }

  Future<void> updateBank(String userId, BankModel bank) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('banks')
          .doc(bank.id)
          .update(bank.toMap());

      final index = _banks.indexWhere((b) => b.id == bank.id);
      if (index != -1) {
        _banks[index] = bank;
        notifyListeners();
      }
    } catch (e) {}
  }

  Future<List<String>> getAllBankNames() async {
    try {
      final snapshot = await _firestore.collection('bank_names').get();
      final bankNames =
          snapshot.docs.map((doc) => doc['name'] as String).toSet().toList();
      return bankNames;
    } catch (e) {
      return [];
    }
  }

  Future<void> addBankName(String bankName) async {
    try {
      await _firestore.collection('bank_names').add({'name': bankName});
    } catch (e) {}
  }

  Future<void> deleteBank(String userId, String bankId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('banks')
          .doc(bankId)
          .delete();

      _banks.removeWhere((bank) => bank.id == bankId);
      notifyListeners();
    } catch (e) {}
  }
}
