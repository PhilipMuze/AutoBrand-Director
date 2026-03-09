import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Authentification/login.dart';
import 'pages/campaign_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const CampaignPage();
        } else if (snapshot.hasError) {
          return const Center(child: Text('An error occurred'));
        } else {
          return const Login();
        }
      },
    );
  }
}
