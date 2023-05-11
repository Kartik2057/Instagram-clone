import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/Widgets/follow_button.dart';
import 'package:instagram_flutter/providers/image_selection_provider.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/expanded_image.dart';
import 'package:instagram_flutter/screens/login_screen.dart';
import 'package:instagram_flutter/screens/post_detail_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:provider/provider.dart';

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
  bool isSelectionMode = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  void _onDeletePressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete these posts?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Cancel');
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ImageSelectionProvider.getSelectedImages().forEach((element) {
                  FirestoreMethods().deletePost(element);
                });
                getData();
                setState(() {
                  print("set state inside delete pressed");
                  isSelectionMode = false;
                });
                Navigator.pop(context, 'Delete');
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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
          .where('uid', isEqualTo: widget.uid)
          .get();
      postLen = postSnap.docs.length;
      userData = usersnap.data()!;
      followers = userData['followers'].length;
      following = userData['following'].length;
      isFollowing = userData['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
          if(followers<0) {
            followers=0;
          }
          if(following<0) {
            following=0;
          }  
      setState(() 
      {});
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    print(isFollowing);
    return Scaffold(
      appBar: AppBar(
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    isSelectionMode = false;
                    ImageSelectionProvider.setSelectedImages();
                  });
                },
              )
            : null,
        backgroundColor: mobileBackgroundColor,
        title: !isSelectionMode
            ? Text(
                userData['username'] ?? '',
                style: const TextStyle(
                  color: primaryColor,
                ),
              )
            : null,
        centerTitle: false,
        actions: [
          if (isSelectionMode)
            TextButton(
                onPressed: _onDeletePressed,
                child: const Text(
                  "Delete Selected",
                  style: TextStyle(color: Colors.red),
                ))
        ],
      ),
      body: Column(
        children: [
          Opacity(
            opacity: !isSelectionMode ? 1 : 0.3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context){
                          return ExpandedImage(url: userData['photoUrl'].toString());
                        })),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              NetworkImage(userData['photoUrl'].toString()),
                        ),
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
                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen(),
                                          ));
                                        },
                                      )
                                    : isFollowing
                                        ? FollowButton(
                                            text: "Unfollow",
                                            textColor: Colors.black,
                                            backgroundColor: Colors.white,
                                            borderColor: Colors.grey,
                                            function: () async {
                                              await FirestoreMethods()
                                                  .followUser(
                                                    userData['uid'],
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid
                                                      );        
                                              setState(() {
                                                
                                                isFollowing = false;
                                                getData();
                                              });
                                            },
                                          )
                                        : FollowButton(
                                            text: "Follow",
                                            textColor: Colors.white,
                                            backgroundColor: Colors.blue,
                                            borderColor: Colors.grey,
                                            function: () async {
                                              await FirestoreMethods()
                                                  .followUser(
                                                    userData['uid'],
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid
                                                      );
                                              setState(() {
                                               
                                                isFollowing = true;
                                                getData();
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
                      userData['bio'] ?? '',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder(
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
                  var documents = snapshot.data!.docs;
                  //Sorting the documents on the newest first algorithm
                  documents.sort((a, b) {
                    return b
                        .data()['datePublished']
                        .compareTo(a.data()['datePublished']);
                  });
                  if (documents.isEmpty) {
                    return const Center(
                      child: Text(
                        "No Posts",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return Consumer<ImageSelectionProvider>(
                    builder: (context, model, child) {
                      return GridView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: documents.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                  childAspectRatio: 1),
                          itemBuilder: (context, index) {
                            DocumentSnapshot snap = documents[index];
                            return GestureDetector(
                              onLongPress: () {
                                if(FirebaseAuth.instance.currentUser!.uid==widget.uid){
                                if (model.selectedImages.isEmpty) {
                                  setState(() {
                                    
                                    isSelectionMode = true;
                                  });
                                }
                                model.toggleImageSelection(snap['postId']);
                                if (model.selectedImages.isEmpty) {
                                  setState(() {
                                    isSelectionMode = false;
                                  });
                                }
                                }
                              },
                              onTap: () {
                                if (isSelectionMode&&FirebaseAuth.instance.currentUser!.uid==widget.uid) {
                                  model.toggleImageSelection(snap['postId']);
                                  if (model.selectedImages.isEmpty) {
                                    setState(() {
                                     
                                      isSelectionMode = false;
                                    });
                                  }
                                } else {
                                  Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) =>
                                              PostDetailScreen(snap: snap)))
                                      .then((value) {
                                    getData();
                                    setState(() {
                                      
                                    });
                                  });
                                }
                              },
                              child: Stack(children: [
                                Opacity(
                                  opacity: model.selectedImages
                                          .contains(snap['postId'])
                                      ? 0.5
                                      : 1,
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    width:
                                        MediaQuery.of(context).size.width / 3.0,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: snap['postUrl'],
                                      placeholder: (context, url) =>
                                          const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                if (model.selectedImages
                                    .contains(snap['postId']))
                                  const Center(
                                    child: Icon(
                                      Icons.check,
                                      color: secondaryColor,
                                      size: 50,
                                    ),
                                  ),
                              ]),
                            );
                          });
                    },
                  );
                }),
          )
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
