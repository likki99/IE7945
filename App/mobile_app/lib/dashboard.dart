import 'package:flutter/material.dart';
import 'accounts_setting_page.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopScope(
    canPop: false, 
    child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Welcome User'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountSettingsPage()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            crossAxisCount: 2,
            children: List.generate(4, (index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('Card $index'),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}