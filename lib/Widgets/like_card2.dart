import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:intl/intl.dart';

class LikeCard2 extends StatefulWidget {
  final uid;
  const LikeCard2({required this.uid, super.key});

  @override
  State<LikeCard2> createState() => _LikeCard2State();
}

class _LikeCard2State extends State<LikeCard2> {
  var snapshot;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserByUid();
  }

  Future<void> fetchUserByUid() async {
    try {
      snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      setState(() {
        
      });   
    } catch (e) {
      print("Error fetching the data");
    }
  }

  @override
  Widget build(BuildContext context) {
    fetchUserByUid();
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 16,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(snapshot!=null?snapshot['photoUrl']:"https://images.unsplash.com/photo-1682706629749-4782481d7699?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=385&q=80"),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16,
              ),
              child: Text(snapshot!=null?snapshot['username']:"username"),
            ),
          ),
        ],
      ),
    );
  }
}
