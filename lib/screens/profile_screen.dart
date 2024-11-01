import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/connectivity_provider.dart';
import '../utils/size_config.dart';
import '../utils/snackbar_util.dart';
import '../utils/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  File? _image;
  bool _isLoading = false;
  bool _isOffline = false;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final user = Provider.of<AuthProvider>(context).user;
    final isOffline = !Provider.of<ConnectivityProvider>(context).isOnline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isOffline ? _buildOfflineView() : _buildProfileForm(user),
    );
  }

  Widget _buildOfflineView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'You are offline',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await _checkConnectivity();
              if (!_isOffline) {
                setState(() {}); // Rebuild the widget
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(user) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 4),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: SizeConfig.safeBlockVertical * 2),
              _buildProfileImage(user),
              SizedBox(height: SizeConfig.safeBlockVertical * 2),
              Text(
                'Tap to change profile picture',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                ),
              ),
              SizedBox(height: SizeConfig.safeBlockVertical * 4),
              _buildNameField(),
              SizedBox(height: SizeConfig.safeBlockVertical * 4),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(user) {
    return GestureDetector(
      onTap: _getImage,
      child: CircleAvatar(
        radius: SizeConfig.safeBlockHorizontal * 15,
        backgroundColor: Colors.grey[300],
        backgroundImage: _image != null
            ? FileImage(_image!)
            : (user?.photoUrl != null
                ? CachedNetworkImageProvider(user!.photoUrl!) as ImageProvider
                : null),
        child: _image == null && user?.photoUrl == null
            ? Icon(
                Icons.camera_alt,
                size: SizeConfig.safeBlockHorizontal * 15,
                color: Colors.grey[800],
              )
            : null,
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Display Name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a display name';
        }
        return null;
      },
    );
  }

  Widget _buildUpdateButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _updateProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.safeBlockHorizontal * 8,
          vertical: SizeConfig.safeBlockVertical * 2,
        ),
      ),
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Update Profile'),
    );
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;

        if (user == null) {
          SnackBarUtil.showSnackBar(context, 'User not authenticated',
              isError: true);
          return;
        }

        String? photoUrl;
        if (_image != null) {
          photoUrl = await _uploadImage(user.uid);
        }
        await authProvider.updateUserProfile(
          displayName: _nameController.text,
          photoUrl: photoUrl,
        );
        SnackBarUtil.showSnackBar(context, 'Profile updated successfully');
        Navigator.pop(context);
      } catch (e) {
        SnackBarUtil.showSnackBar(context, 'Failed to update profile: $e',
            isError: true);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _uploadImage(String userId) async {
    if (_image == null) return null;

    try {
      final ref =
          FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');
      final uploadTask = ref.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      SnackBarUtil.showSnackBar(context, 'Failed to upload image: $e',
          isError: true);
      return null;
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _isOffline = connectivityResult == ConnectivityResult.none;
    });
  }
}
