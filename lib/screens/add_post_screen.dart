import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:instagram_flutter/screens/expanded_image.dart';
import 'package:instagram_flutter/screens/image_preview_screen.dart';
import 'package:instagram_flutter/utils/colors.dart';
import 'package:instagram_flutter/utils/utils.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading=false;

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context, 
      builder: (context) {
        return SimpleDialog(
          title: const Text("Create a post"),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Take a photo"),
              onPressed: () async{
                Navigator.of(context).pop();
                Uint8List file = await pickImage(
                  ImageSource.camera,
                );
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Choose from gallery"),
              onPressed: () async{
                Navigator.of(context).pop();
                Uint8List file = await pickImage(
                  ImageSource.gallery,
                );
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () async{
                
              },
            ),
          ],
        );
      },
      );
  }


  void _postImage(
    String uid,
    String username,
    String profImage
    ) async {
      setState(() {
        FocusScope.of(context).unfocus();
        _isLoading=true;
      });
      try {
        String res = await FirestoreMethods().uploadPost(
          _descriptionController.text, 
          _file!, 
          uid, 
          username, 
          profImage
          );
        setState(() {
          _isLoading=false;
        });
        if(res == "Success") {
          // ignore: use_build_context_synchronously
          _descriptionController.clear();
          clearImage();
          showSnackbar("Posted!", context);
        }
        else{
          // ignore: use_build_context_synchronously
          showSnackbar(res, context);
        }
      } catch (e) {
        showSnackbar(e.toString(), context);
      }
    }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _descriptionController.dispose();
  }


  void clearImage() {
    setState(() {
      _file=null;
    });
  }

  @override
  Widget build(BuildContext context) {

    final User user = Provider.of<UserProvider>(context).getUser;


    return _file == null
    ?Center(
      child: CircleAvatar(
        child: IconButton(
          onPressed: () {
             _selectImage(context);
          }, 
          icon: const Icon(
            Icons.upload,
            size: 35,)
          ),
      ),
    )
    :Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          onPressed: () {
            clearImage();
          },
          icon : const Icon(Icons.arrow_back
          )
          ),
        title: const Text("Post to"),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => _postImage(
              user.uid,
              user.username,
              user.photoUrl,
            ), 
            child: const Text("Post",
            style: TextStyle(
               color: Colors.blueAccent,
               fontWeight: FontWeight.bold,
               fontSize: 16,
            ),
            ),
            ),
        ],  
      ),
      body: Column(
        children: [
          _isLoading
          ?const LinearProgressIndicator()
          :const Padding(padding: EdgeInsets.only(
            top: 8,
          )
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               GestureDetector(
                 onTap: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                   ExpandedImage(url: user.photoUrl)
                 )
                 ),
                 child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    user.photoUrl
                  ),
                ),
               ),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.4,
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: "Write a caption ...",
                    border: InputBorder.none,
                    ),
                  maxLines: 8,
                ),
              ),
              GestureDetector(
                onTap: ()=>Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ImagePreviewScreen(file: _file)
                  )
                  ),
                child: SizedBox(
                  height: 45,
                  width: 45,
                  child: AspectRatio(
                    aspectRatio: 487/451,
                    child: Container(
                     decoration: BoxDecoration(
                      image: DecorationImage(
                        image: MemoryImage(
                          _file!
                        ),
                        fit: BoxFit.fill,
                        alignment: FractionalOffset.topCenter, 
                        )
                     ),
                    ),
                    ),
                ),
              ),
              const Divider(),
            ],
          )
        ],
      ),
    );
  }
}