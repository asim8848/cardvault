// lib/screens/bank_main_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bank_model.dart';
import '../providers/auth_provider.dart';
import '../providers/bank_provider.dart';
import '../routes.dart';
import '../utils/size_config.dart';
import '../utils/theme.dart';

class BankMainScreen extends StatefulWidget {
  const BankMainScreen({super.key});

  @override
  _BankMainScreenState createState() => _BankMainScreenState();
}

class _BankMainScreenState extends State<BankMainScreen> {
  String searchQuery = '';
  Set<String> expandedBanks = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBanks();
    });
  }

  void _fetchBanks() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bankProvider = Provider.of<BankProvider>(context, listen: false);
    final user = authProvider.user;

    if (user != null) {
      await bankProvider.fetchBanks(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Bank Accounts',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: SizeConfig.safeBlockHorizontal * 4),
            _buildSearchBar(),
            SizedBox(height: SizeConfig.safeBlockVertical * 2),
            Expanded(child: _buildBankList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal * 5),
      child: Container(
        height: SizeConfig.safeBlockVertical * 5,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal * 3),
        ),
        child: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search banks...',
            hintStyle: const TextStyle(color: Colors.white60),
            prefixIcon: const Icon(Icons.search, color: Colors.white60),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white60),
                    onPressed: () {
                      setState(() {
                        searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: SizeConfig.safeBlockHorizontal * 4,
              vertical: SizeConfig.safeBlockVertical *
                  1.3, // Adjust vertical padding here
            ),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildBankList() {
    return Consumer<BankProvider>(
      builder: (context, bankProvider, child) {
        final banks = bankProvider.banks;
        final groupedBanks = _groupBanksByName(banks);
        final filteredBanks = groupedBanks.entries
            .where((entry) =>
                entry.key.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

        // Check if there are no banks
        if (filteredBanks.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 5),
              child: const Text(
                "No Banks found. Add a bank to get started!",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredBanks.length,
          itemBuilder: (context, index) {
            final bankName = filteredBanks[index].key;
            final bankAccounts = filteredBanks[index].value;
            final isExpanded = expandedBanks.contains(bankName);

            return Column(
              children: [
                _buildBankItem(bankName, isExpanded, bankAccounts.length),
                if (isExpanded) _buildAccountsList(bankAccounts),
                const Divider(color: Colors.white24, height: 1),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBankItem(String bankName, bool isExpanded, int accountCount) {
    return InkWell(
      onTap: () {
        setState(() {
          if (isExpanded) {
            expandedBanks.remove(bankName);
          } else {
            expandedBanks.add(bankName);
          }
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.safeBlockHorizontal * 5,
          vertical: SizeConfig.safeBlockVertical * 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$bankName ($accountCount)',
              style: TextStyle(
                color: Colors.white,
                fontSize: SizeConfig.safeBlockHorizontal * 4.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white,
              size: SizeConfig.safeBlockHorizontal * 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsList(List<BankModel> accounts) {
    return Column(
      children: accounts.map<Widget>((account) {
        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.bankDetailsView,
              arguments: {
                'id': account.id,
                'name': account.name,
                'accountType': account.accountType,
                'accountNumber': account.accountNumber,
                'ibanNumber': account.ibanNumber,
                'bank': account.bank,
                'branchName': account.branchName,
                'branchCode': account.branchCode,
              },
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.safeBlockHorizontal * 8,
              vertical: SizeConfig.safeBlockVertical * 1.5,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  radius: SizeConfig.safeBlockHorizontal * 4,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: SizeConfig.safeBlockHorizontal * 5,
                  ),
                ),
                SizedBox(width: SizeConfig.safeBlockHorizontal * 3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConfig.safeBlockHorizontal * 4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        account.accountType,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white60,
                  size: SizeConfig.safeBlockHorizontal * 4,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Map<String, List<BankModel>> _groupBanksByName(List<BankModel> banks) {
    Map<String, List<BankModel>> groupedBanks = {};
    for (var bank in banks) {
      if (!groupedBanks.containsKey(bank.bank)) {
        groupedBanks[bank.bank] = [];
      }
      groupedBanks[bank.bank]!.add(bank);
    }
    return groupedBanks;
  }
}
