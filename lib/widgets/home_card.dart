// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../main.dart';

class HomeCard extends StatelessWidget {
  final String title, subtitle;
  final Widget icon;

  HomeCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: mq.width * .45,
        child: Column(
          children: [
            icon,
            SizedBox(
              height: 6,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              subtitle,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
            )
          ],
        ));
  }
}
