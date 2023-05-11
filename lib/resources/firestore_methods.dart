import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_flutter/models/posts.dart';
import 'package:instagram_flutter/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some error occured";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage("posts", file, true);
      String postId = const Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
      );

      _firestore.collection('posts').doc(postId).set(
            post.toJson(),
          );
      res = "Success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        print("current user is present so removing it");
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        print("current user is not present  in likes");
        DocumentReference docRef = _firestore.collection('posts').doc(postId);
        docRef.get().then((doc) {
          List likesList = doc.get('likes');
          likesList.insert(0, uid);
          docRef
              .update({'likes': likesList})
              .then((value) => print("Uid added to likes list"))
              .onError((error, _) => print("Failed to add uid: $error"));
        }).catchError((error) => print("Failed to retrieve document"));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> postComment(
    String postId,
    String text,
    String uid,
    String name,
    String profilePic,
  ) async {
    try {
      print("In the postComment function");
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
      } else {
        print('Text is empty.');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> followUser(String followId, String uid) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      //Explicitly stating that snap.data() is not null and is a list
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        //removing current user from followers
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });
        // removing followId user from following of current user
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        //adding current user to followers
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });
        // adding followId user to following of current user
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

}
