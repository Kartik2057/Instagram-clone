import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';
import '../resources/firestore_methods.dart';

class LikeCard extends StatefulWidget {
  final snap;
  const LikeCard({
    required this.snap,
    super.key});

  @override
  State<LikeCard> createState() => _LikeCardState();
}

class _LikeCardState extends State<LikeCard> {
  
  @override
  Widget build(BuildContext context) {
  final User user = Provider.of<UserProvider>(context).getUser;
    return Dismissible(
        key: UniqueKey(),
  direction: DismissDirection.startToEnd,
  onDismissed: (direction) {
    FirestoreMethods().likePost(
                      widget.snap['postId'],
                      user.uid,
                      widget.snap['likes'],
                    );
    showSnackbar("Removed from liked posts", context);               
  },
  background: Container(
    color: Colors.red,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: const [
        SizedBox(width: 16),
        Icon(
          Icons.remove_circle,
          color: Colors.white,
        ),
        SizedBox(width: 16),
        Text(
          'Remove',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(width: 16),
      ],
    ),
  ),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
        ),
        child: Column(
          children: [
             ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              widget.snap['profImage']
            ),
          ),
          title: Text(
            widget.snap['username'],
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            widget.snap['description'],
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
            ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          // child: Image.network(
          //   snap['postUrl'],
          //   fit: BoxFit.cover,
          //   width: double.infinity,
          //   height: MediaQuery.of(context).size.height*0.5,
          // ),
          child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: widget.snap['postUrl'],
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height*0.5,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error
                      ),
                  ),
        ),
        
          ],
        ),
      ),
    );
  }
}