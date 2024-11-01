import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import '../utils/size_config.dart';
import '../utils/snackbar_util.dart';
import '../utils/theme.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  static const platform = MethodChannel('com.apsify.cardvault/email');

  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _isOffline = connectivityResult == ConnectivityResult.none;
    });
  }

  Future<void> _launchContactUsEmail() async {
    const String email = 'cardvault@apsify.com';
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      if (await canLaunch(emailLaunchUri.toString())) {
        await launch(emailLaunchUri.toString());
      } else {
        throw 'Could not launch $emailLaunchUri';
      }
    } catch (e) {
      SnackBarUtil.showSnackBar(
        context,
        'Could not open email app. Please contact us at $email',
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.9),
              AppTheme.secondaryColor.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(user),
              Divider(color: Colors.white.withOpacity(0.5), thickness: 1),
              SizedBox(height: SizeConfig.safeBlockVertical * 2),
              _buildDrawerItem(
                  context, Icons.home_outlined, 'Home', AppRoutes.main),
              _buildDrawerItem(
                context,
                Icons.person_outline,
                'Edit Profile',
                _isOffline ? null : AppRoutes.profile,
              ),
              _buildDrawerItem(
                  context, Icons.info_outline, 'About', AppRoutes.about),
              _buildDrawerItem(context, Icons.privacy_tip_outlined,
                  'Privacy Policy', AppRoutes.privacyPolicy),
              _buildDrawerItem(context, Icons.description_outlined,
                  'Terms of Service', AppRoutes.termsOfService),
              _buildDrawerItem(
                context,
                Icons.contact_mail_outlined,
                'Contact Us',
                AppRoutes.contactUs,
              ),
              const Spacer(),
              _buildSignOutButton(context),
              SizedBox(height: SizeConfig.safeBlockVertical * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserModel? user) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 4),
      child: Column(
        children: [
          CircleAvatar(
            radius: SizeConfig.safeBlockHorizontal * 12,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: user == null
                ? const CircularProgressIndicator(color: Colors.white)
                : (user.photoUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.photoUrl!,
                          fit: BoxFit.cover,
                          width: SizeConfig.safeBlockHorizontal * 24,
                          height: SizeConfig.safeBlockHorizontal * 24,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(color: Colors.white),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person_outline,
                            size: SizeConfig.safeBlockHorizontal * 14,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person_outline,
                        size: SizeConfig.safeBlockHorizontal * 14,
                        color: Colors.white,
                      )),
          ),
          SizedBox(height: SizeConfig.safeBlockVertical * 2),
          user == null
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  user.displayName ?? 'User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.safeBlockHorizontal * 5,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
          SizedBox(height: SizeConfig.safeBlockVertical * 1),
          user == null
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                  ),
                  textAlign: TextAlign.center,
                ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, String? route,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: SizeConfig.safeBlockHorizontal * 6,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: SizeConfig.safeBlockHorizontal * 4,
        ),
      ),
      onTap: onTap ??
          () {
            Navigator.pop(context); // Close the drawer
            if (route != null && route != AppRoutes.main) {
              if (_isOffline && route == AppRoutes.profile) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You are offline. Profile is not available.'),
                  ),
                );
              } else {
                Navigator.pushNamed(context, route);
              }
            } else if (title == 'Contact Us') {
              Navigator.pushNamed(context, AppRoutes.contactUs);
            }
          },
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal * 4),
      child: ElevatedButton(
        onPressed: () async {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          await authProvider.signOut();
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.welcome, (route) => false);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(SizeConfig.safeBlockHorizontal * 2),
          ),
          padding:
              EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign out',
              style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 4),
            ),
            SizedBox(width: SizeConfig.safeBlockHorizontal * 2),
            Icon(Icons.logout, size: SizeConfig.safeBlockHorizontal * 5),
          ],
        ),
      ),
    );
  }
}
