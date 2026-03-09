import 'package:autobrand_director/pages/campaign_page.dart';
import 'package:flutter/material.dart';

import 'home.dart';

void main() {
  runApp(const AutoBrandApp());
}

class AutoBrandApp extends StatelessWidget {
  const AutoBrandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoBrand Director',
      theme: ThemeData.light(),
      home: const CampaignPage(),
      routes: {
        '/campaign': (context) => const CampaignPage(),
        '/Home': (context) => const Home(),
      },
    );
  }
}
