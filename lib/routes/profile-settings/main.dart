import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mywonderbird/components/auth-text-field.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user-profile.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/routes/crop-image/main.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/profile.dart';
import 'package:provider/provider.dart';

class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final _usernameController = TextEditingController();
  final _picker = ImagePicker();

  List<int> _newAvatarImage;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<User>(context, listen: false);

    _usernameController.text = user?.profile?.username;
  }

  ImageProvider get avatar {
    if (_newAvatarImage != null) {
      return MemoryImage(_newAvatarImage);
    }

    final user = Provider.of<User>(context, listen: false);

    return user?.profile?.avatarUrl != null
        ? NetworkImage(user.profile.avatarUrl)
        : null;
  }

  Widget get avatarFallback {
    if (_newAvatarImage != null) {
      return null;
    }

    final user = Provider.of<User>(context, listen: false);
    final radius = MediaQuery.of(context).size.width / 4;

    return user?.profile?.avatarUrl == null
        ? Text(
            user.initials,
            style: TextStyle(
              color: Colors.black54,
              fontSize: radius / 2,
            ),
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Account details',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 18.0,
          ),
        ),
        actions: [
          FlatButton(
            onPressed: _onSave,
            child: Text(
              'SAVE',
              style: TextStyle(color: theme.primaryColor),
            ),
            shape: ContinuousRectangleBorder(),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _avatar(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                      ),
                      RaisedButton(
                        colorBrightness: Brightness.dark,
                        color: Colors.black54,
                        child: Text('Change avatar'),
                        onPressed: _onChangeAvatar,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                      ),
                      AuthTextField(
                        controller: _usernameController,
                        labelText: 'Username',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _avatar() {
    final user = Provider.of<User>(context, listen: false);
    final radius = MediaQuery.of(context).size.width / 4;

    return Align(
      alignment: Alignment.center,
      child: CircleAvatar(
        radius: radius,
        backgroundImage: avatar,
        child: avatarFallback,
        backgroundColor: user?.profile?.avatarUrl != null
            ? Colors.transparent
            : Colors.black12,
      ),
    );
  }

  _onChangeAvatar() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    }

    final navigationService = locator<NavigationService>();

    ui.Image croppedImage = await navigationService.push(
      MaterialPageRoute(
        builder: (context) => CropImage(
          imagePath: File(pickedFile.path),
        ),
      ),
    );

    if (croppedImage == null) {
      return;
    }

    final imageBytes =
        await croppedImage.toByteData(format: ui.ImageByteFormat.png);

    setState(() {
      _newAvatarImage = imageBytes.buffer.asUint8List();
    });
  }

  _onSave() async {
    final username = _usernameController.text;

    if (username.isEmpty) {
      return;
    }

    final profileService = locator<ProfileService>();
    UserProfile profileUpdate = UserProfile(username: username);

    final authService = locator<AuthenticationService>();
    final navigationService = locator<NavigationService>();

    final user = Provider.of<User>(context, listen: false);
    final updatedProfile = await profileService.updateUserProfile(
      profileUpdate,
      _newAvatarImage,
    );

    user.profile = updatedProfile;
    authService.addUser(user);

    navigationService.pop();
  }
}
