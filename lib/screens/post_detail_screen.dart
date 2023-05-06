import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/Widgets/like_card2.dart';
import 'package:instagram_flutter/utils/colors.dart';
import '../Widgets/comment_card.dart';
import '../models/tab_bar_delegate.dart' as tbd;
import '../models/tab_bar_delegate.dart';
import '../resources/firestore_methods.dart';
import 'expanded_image.dart';

class PostDetailScreen extends StatefulWidget {
  final snap;
  const PostDetailScreen({required this.snap, super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController = TabController(length: 0, vsync: this);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                widget.snap['profImage'],
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Text(widget.snap['username']),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => Dialog(
                          child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shrinkWrap: true,
                        children: ['Delete']
                            .map(
                              (e) => InkWell(
                                onTap: () async {
                                  FirestoreMethods()
                                      .deletePost(widget.snap['postId']);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: Text(e),
                                ),
                              ),
                            )
                            .toList(),
                      )));
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: MediaQuery.of(context).size.height * 0.4,
              flexibleSpace: FlexibleSpaceBar(
                background: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ExpandedImage(
                            url: widget.snap['postUrl'],
                          ),
                          ),
                          ),
                  child: Stack(
                    children: [
                      Image.network(
                        widget.snap['postUrl'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () {
                            _tabController.animateTo(0);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            // color: Colors.black,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                Text(
                                  'Swipe up',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: TabBarDelegate(
                tabBar: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(
                        icon: Icon(
                      Icons.favorite,
                      color: Colors.red,
                    )),
                    Tab(
                      icon: Icon(Icons.comment_bank_rounded),
                    ),
                  ],
                ),
              ),
              floating: true,
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.snap['postId'])
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasData &&
                        snapshot.data!['likes'].length != 0) {
                      return ListView.builder(
                          itemCount: snapshot.data!['likes'].length,
                          itemBuilder: (context, index) =>
                              LikeCard2(uid: snapshot.data!['likes'][index]));
                    }
                    return const Center(
                      child: Text("No Likes"),
                    );
                  }
                }),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.snap['postId'])
                  .collection('comments')
                  .orderBy('datePublished', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (snapshot.hasData && snapshot.data!.docs.length != 0) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) => CommentCard(
                        snap: snapshot.data!.docs[index].data(),
                      ),
                    );
                  }
                  return const Center(
                    child: Text(
                      "No comments",
                      style: TextStyle(color: primaryColor),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
