import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_flutter/screens/post_detail_screen.dart';
import 'package:instagram_flutter/screens/profile_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with WidgetsBindingObserver {
  final TextEditingController searchController = TextEditingController();
  bool _isShowUsers = false;
  late FocusNode _focusNode;
  bool _keyboardOpen = false;

  @override
  void initState() {
    super.initState();
    _focusNode=FocusNode();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    searchController.dispose();
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void closeKeyboardAndUnfocus() {
    // Close the keyboard and unfocus the text field
    _focusNode.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    setState(() {
      _isShowUsers=false;
    });
  }
  
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // Check if the keyboard is closed
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    if (!keyboardOpen && _keyboardOpen) {

      // The keyboard was closed
      closeKeyboardAndUnfocus();
    }
    _keyboardOpen = keyboardOpen;
  }
  

  @override
  Widget build(BuildContext context) {
    didChangeMetrics();
    return GestureDetector(
      onTap: closeKeyboardAndUnfocus,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: TextFormField(
            controller: searchController,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              labelText: 'Search for a user',
            ),
            // onFieldSubmitted: (String _) {
            //   setState(() {
            //     _isShowUsers = true;
            //   });
            // },
            onChanged: (_){
              setState(() {
                _isShowUsers = true;
              });
            },
            onTap: (){
              setState(() {
                _isShowUsers = true;
              });
            },
            onEditingComplete: (){
              if(searchController.text.isEmpty){
                setState(() {
                _isShowUsers=false;
                });
              }
            },
          ),
        ),
        body: _isShowUsers
            ? FutureBuilder<List<QueryDocumentSnapshot>>(
                future: search(searchController.text),
                builder: (context, snapshot) {
                  // if (kDebugMode) {
                  //   print("This is user data : ${snapshot.data}");
                  // }
                  if (snapshot.connectionState==ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  else if(snapshot.hasError){
                    return const Text('Some error occured');
                  } 
                  else {
                    //Search completed successfully
                    List<QueryDocumentSnapshot> searchResults = snapshot.data!;
                    if(searchResults.isEmpty) {
                      return const Center(
                      child: Text("No match"),
                    );
                    }
                    return ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final document=searchResults[index];
                          return InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                    uid: (document.data() as dynamic)['uid']
                                    ),
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    (document.data() as dynamic)['photoUrl']
                                    ),
                              ),
                              title: Text((document.data() as dynamic)['username']),
                            ),
                          );
                        }
                        );
                  }
                },
              )
            : FutureBuilder(
                future: FirebaseFirestore.instance.collection('posts').get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return StaggeredGridView.countBuilder(
                    crossAxisCount: 3,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Handle tap on image here
                          Navigator.of(context).push(MaterialPageRoute(builder: 
                          (context){
                            return PostDetailScreen(snap: snapshot.data!.docs[index]);
                          }));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: snapshot.data!.docs[index]['postUrl'],
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      );
                    },
                    staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    padding: const EdgeInsets.all(4),
                  );
                }
                ),
      ),
    );
  }
}


Future<List<QueryDocumentSnapshot>> search(String searchText) async {
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('users');

  String lowercaseSearchText = searchText.toLowerCase();
  String uppercaseSearchText = searchText.toUpperCase();

  // Create the query to search for documents with usernames that match the lowercase or uppercase search text
  QuerySnapshot querySnapshot = await collectionReference
      .where('username',
          isGreaterThanOrEqualTo: lowercaseSearchText,
          isLessThanOrEqualTo: "$lowercaseSearchText\uf8ff")
      .get();

  List<QueryDocumentSnapshot> searchResults = querySnapshot.docs;

  if (lowercaseSearchText != uppercaseSearchText) {
    QuerySnapshot uppercaseQuerySnapshot = await collectionReference
        .where('username',
            isGreaterThanOrEqualTo: uppercaseSearchText,
            isLessThanOrEqualTo: "$uppercaseSearchText\uf8ff")
        .get();

    searchResults.addAll(uppercaseQuerySnapshot.docs);
  }
  return searchResults;
}

