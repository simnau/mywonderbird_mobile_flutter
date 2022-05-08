import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mywonderbird/components/auth-text-field.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/user-profile.dart';
import 'package:mywonderbird/models/user.dart';
import 'package:mywonderbird/providers/profile.dart';
import 'package:mywonderbird/routes/crop-image/main.dart';
import 'package:mywonderbird/services/authentication.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/profile.dart';
import 'package:mywonderbird/util/sentry.dart';
import 'package:mywonderbird/util/snackbar.dart';
import 'package:provider/provider.dart';

class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final _usernameController = TextEditingController();
  final _picker = ImagePicker();

  bool _isSaving = false;
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
        title: Subtitle1('Account details'),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: _isSaving
                ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(),
                  )
                : BodyText1(
                    'SAVE',
                    color: theme.primaryColor,
                  ),
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
                      ElevatedButton(
                        child: BodyText1.light('Change avatar'),
                        onPressed: _onChangeAvatar,
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black54,
                        ),
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

    try {
      setState(() {
        _isSaving = true;
      });

      final profileProvider = locator<ProfileProvider>();
      final profileService = locator<ProfileService>();
      UserProfile profileUpdate = UserProfile(username: username);

      final authService = locator<AuthenticationService>();
      final navigationService = locator<NavigationService>();

      final user = Provider.of<User>(context, listen: false);
      final updatedProfile = await profileService.updateUserProfile(
        profileUpdate,
        _newAvatarImage,
      );

      profileProvider.reloadProfile = true;
      user.profile = updatedProfile;
      authService.addUser(user);

      navigationService.pop();
    } catch (error, stackTrace) {
      await reportError(error, stackTrace);

      final snackBar = createErrorSnackbar(
        text: 'An unexpected error has occurred. Please try again later.',
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
}
