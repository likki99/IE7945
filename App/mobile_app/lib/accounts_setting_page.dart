// account_settings_page.dart
import 'package:flutter/material.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Account Settings'),
          ],
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Profile Info'),
            onTap: () {
              // Navigate to the profile info page
              // Replace this with your actual implementation
            },
            leading: const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(Icons.person), // Add an icon for example
            ),
          ),
          ListTile(
            title: const Text('Sign Out'),
            onTap: () {
              // Sign out the user
              // Replace this with your actual implementation

              // Reset the app to the login page and remove all previous pages
              Navigator.popUntil(context, (Route<dynamic> route) => route.settings.name == 'LoginPage');

            },
            leading: const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Icon(Icons.exit_to_app), // Add an icon for example
            ),
          ),
        ],
      ),
    );
  }
}