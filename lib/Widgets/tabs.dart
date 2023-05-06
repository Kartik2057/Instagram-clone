import 'package:flutter/material.dart';

class Tabs extends StatelessWidget {
  const Tabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Column(
        children: const [
          TabBar(
                tabs: <Widget>[
                  Tab(
                    icon: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.comment_bank_rounded
                      ),
                  ),
                ],
              ),
              TabBarView(
          children: <Widget>[
            Center(
              child: Text("It's cloudy here"),
            ),
            Center(
              child: Text("It's rainy here"),
            ),
          ],
    ),
        ],
      )
    );
  }
}