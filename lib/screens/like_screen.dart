import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_flutter/Widgets/like_card1.dart';
import 'package:provider/provider.dart';

import '../Widgets/post_card.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';
import '../utils/global_variables.dart';

class LikeScreen extends StatefulWidget {
  const LikeScreen({super.key});

  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {

    Future<void> _refresh() async {
    // This method is called when the user pulls down on the screen to refresh
    // Add your refresh logic here, such as reloading data from a server or resetting the state of the widget
    // For this example, we'll just wait for 1 second to simulate a refresh
    await Future.delayed(Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
  final User user = Provider.of<UserProvider>(context).getUser;

  final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: width > webScreenSize ?
      null:
      AppBar(
        backgroundColor: width > webScreenSize?webBackgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: SvgPicture.asset(
          'assets/ic_instagram.svg',
        color: primaryColor,
        height: 32,
        ),
        actions: [
          IconButton(
            onPressed: () {}, 
            icon: const Icon(
              Icons.messenger_outline,
            )
            )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('posts').snapshots(),
          builder: (
            BuildContext context, AsyncSnapshot<
            QuerySnapshot<Map<String,dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) =>
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: width>webScreenSize?width*0.3:0,
                    vertical: width>webScreenSize?
                    15:0,
                  ),
                  child: snapshot.data!.docs[index].data()['likes'].contains(user.uid)
                  // ?PostCard(
                  //   snap:snapshot.data!.docs[index].data(),
                  // ):null,
                  ?LikeCard(
                    snap: snapshot.data!.docs[index].data(),
                  ):null
                ),
              );
              },
        ),
      ),
    );;
  }
}