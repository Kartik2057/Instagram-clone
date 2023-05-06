import 'package:flutter/material.dart';

class ExpandedImage extends StatelessWidget {
  String url;
  ExpandedImage({
    required this.url,
    super.key}
    );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Image.network(url),
      ),
    );
  }
}