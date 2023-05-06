import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/utils/global_variables.dart';
import 'package:provider/provider.dart';
import '../models/user.dart' as model;
import '../utils/colors.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page  = 0; 
  late PageController pageController;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }
  
  // for changing the color of the icon selected we have to keep a count of selected page
  void onPageChanged(int page){
    setState(() {
      _page = page;
    });
  }

  // Called by compiler with the selected page number
  void navigationTapped(int page){
    pageController.jumpToPage(page);
  }


  @override
  Widget build(BuildContext context) {
  // model.User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      body: PageView(
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: homeScreenItems,
      ),
          bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          backgroundColor: mobileBackgroundColor,
          currentIndex: _page,
          unselectedItemColor: secondaryColor,
          selectedItemColor: primaryColor,
          items:  const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_filled,
                size: 30,
                // color: (_page==0)?primaryColor:secondaryColor,
                ),
              label: '',
              // backgroundColor: primaryColor,
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search,
              size: 30,
              // color: (_page==1)?primaryColor:secondaryColor,
              ),
              label: '',
              // backgroundColor: primaryColor,
              ),  
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle,
              size: 30,
              // color: (_page==2)?primaryColor:secondaryColor,
              ),
              label: '',
              // backgroundColor: primaryColor,
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite,
              size: 30,
              // color: (_page==3)?primaryColor:secondaryColor,
              ),
              label: '',
              // backgroundColor: primaryColor,
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person,
              size: 30,
              // color: (_page==4)?primaryColor:secondaryColor,
              ),
              label: '',
              // backgroundColor: primaryColor,
              ),
          ],
          onTap: navigationTapped,
          )
    );
  }
}