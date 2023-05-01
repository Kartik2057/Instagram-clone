import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/Widgets/follow_button.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/login_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  var postData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    try {
      var usersnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      //get no of posts
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      postLen = postSnap.docs.length;
      userData = usersnap.data()!;
      followers = userData['followers'].length;
      following = userData['following'].length;
      isFollowing = userData['following']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
      // print(userData);
      // print(userData['username']);
    } catch (e) {
      print(e.toString());
      // showSnackbar(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(
          userData['username'] ?? '',
          style: const TextStyle(
            color: primaryColor,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(userData['photoUrl'].toString()),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              buildStatColumn(postLen, "posts"),
                              buildStatColumn(followers, "followers"),
                              buildStatColumn(following, "following"),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FirebaseAuth.instance.currentUser!.uid ==
                                      widget.uid
                                  ? FollowButton(
                                      text: 'Sign Out',
                                      textColor: primaryColor,
                                      backgroundColor: mobileBackgroundColor,
                                      borderColor: Colors.grey,
                                      function: () async {
                                        await AuthMethods().signOut();
                                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                                          builder: (context) => const LoginScreen(), 
                                          )
                                          );
                                      },
                                      )
                                  : isFollowing
                                      ?  FollowButton(
                                          text: "Unfollow",
                                          textColor: Colors.black,
                                          backgroundColor: Colors.white,
                                          borderColor: Colors.grey,
                                          function: () async{
                                            await FirestoreMethods().followUser(
                                              FirebaseAuth.instance.currentUser!.uid, 
                                              userData['uid']
                                              );
                                              setState(() {
                                                isFollowing=false;
                                                followers--;
                                              });
                                          },
                                          )
                                      :  FollowButton(
                                          text: "Follow",
                                          textColor: Colors.white,
                                          backgroundColor: Colors.blue,
                                          borderColor: Colors.grey,
                                          function: () async{
                                            await FirestoreMethods().followUser(
                                              FirebaseAuth.instance.currentUser!.uid, 
                                              userData['uid']
                                              );
                                              setState(() {
                                                isFollowing=true;
                                                followers++;
                                              });
                                          },
                                        ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    top: 15,
                  ),
                  child: Text(
                    userData['username'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                    top: 15,
                  ),
                  child: Text(
                    userData['bio']??'',
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('posts')
                  .where('uid', isEqualTo: widget.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 1.5,
                        childAspectRatio: 1
                        ),
                    itemBuilder: (context, index) {
                      DocumentSnapshot snap = snapshot.data!.docs[index];
                      return Container(
                        child: Image(image: NetworkImage(snap['postUrl']),
                        fit: BoxFit.cover,),
                      );
                    });
              })
        ],
      ),
    );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w400, color: Colors.grey),
          ),
        )
      ],
    );
  }
}
