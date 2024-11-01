// lib/models/bank_model.dart

class BankModel {
  final String id;
  final String name; // Changed from accountHolderName to name
  final String accountNumber;
  final String accountType;
  final String ibanNumber;
  final String bank;
  final String branchCode;
  final String branchName;

  BankModel({
    required this.id,
    required this.name, // Changed from accountHolderName to name
    required this.accountNumber,
    required this.accountType,
    required this.ibanNumber,
    required this.bank,
    required this.branchCode,
    required this.branchName,
  });

  factory BankModel.fromMap(Map<String, dynamic> data, String id) {
    return BankModel(
      id: id,
      name: data['name'] ?? '', // Changed from accountHolderName to name
      accountNumber: data['accountNumber'] ?? '',
      accountType: data['accountType'] ?? '',
      ibanNumber: data['ibanNumber'] ?? '',
      bank: data['bank'] ?? '',
      branchCode: data['branchCode'] ?? '',
      branchName: data['branchName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name, // Changed from accountHolderName to name
      'accountNumber': accountNumber,
      'accountType': accountType,
      'ibanNumber': ibanNumber,
      'bank': bank,
      'branchCode': branchCode,
      'branchName': branchName,
    };
  }
}
