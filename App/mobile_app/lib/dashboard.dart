import 'package:flutter/material.dart';
import 'accounts_setting_page.dart';

class Dashboard extends StatelessWidget {
  var userName;

  Dashboard({required this.userName, super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: welcomeText(userName),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AccountSettingsPage()),
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
              String cardName = '';
              IconData cardIcon = Icons.error;

              switch (index) {
                case 0:
                  cardName = 'DEID';
                  cardIcon = Icons.play_circle_filled;
                  break;
                case 1:
                  cardName = 'STATISTICS';
                  cardIcon = Icons.bar_chart;
                  break;
                case 2:
                  cardName = 'REVIEW';
                  cardIcon = Icons.search;
                  break;
                case 3:
                  cardName = 'SUMMARY';
                  cardIcon = Icons.description;
                  break;
              }

              return InkWell(
                onTap: () {
                  // Navigate to the corresponding page
                  switch (index) {
                    case 0:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountSettingsPage()),
                      );
                      break;
                    case 1:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountSettingsPage()),
                      );
                      break;
                    case 2:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountSettingsPage()),
                      );
                      break;
                    case 3:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountSettingsPage()),
                      );
                      break;
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(cardIcon, size: 48.0),
                        const SizedBox(height: 8.0),
                        Text(cardName),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Row welcomeText(String userName) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Welcome $userName'),
          ],
        );
  }
}