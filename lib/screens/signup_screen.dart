import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_flutter/Widgets/text_field_input.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';
import 'package:instagram_flutter/screens/login_screen.dart';
import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_screen_layout.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passEditingController = TextEditingController();
  final TextEditingController _usernameEditingController = TextEditingController();
  final TextEditingController _bioEditingController = TextEditingController();
  Uint8List? _image;
  bool _isLoading=false;

void selectImage() async {
 Uint8List im= await pickImage(ImageSource.gallery);
 setState(() {
   _image = im;
 });
}

void navigateToLogin(){
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) =>const LoginScreen()
    )
    );
  } 


void signUpUser() async {
  setState(() {
    _isLoading=true;
  });  
 
 String res = await AuthMethods().signUpUser(
                  email: _emailEditingController.text, 
                  password: _passEditingController.text, 
                  username: _usernameEditingController.text, 
                  bio: _bioEditingController.text, 
                  file: _image!
                  );
  setState(() {
    _isLoading=false;
  });                
  if(res != "Success") {
      showSnackbar(res, context);
  }
  else{
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>const ResponsiveLayout(
                webScreenLayout: WebScreenLayout(), 
                mobileScreenLayout: MobileScreenLayout()
                )
    )
    );
  }                
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        reverse: true,
        child: SafeArea(          
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              ),
            width: double.infinity, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    child: Container(),
                    ),
                  // svg image
                  SvgPicture.asset(
                    'assets/ic_instagram.svg',
                    theme: const SvgTheme(
                      currentColor: primaryColor
                      ), 
                     height: 64
                     ),
                  const SizedBox(
                    height: 64,
                    ),
                  //Circular Widget for accepting image
                  Stack(
                    children: <Widget>[
                      _image!=null?
                      CircleAvatar(
                        radius: 64,
                        backgroundImage: MemoryImage(_image!),
                      )
                      :const CircleAvatar(
                        radius: 64,
                        backgroundImage: NetworkImage(
                          'https://tse4.mm.bing.net/th?id=OIP.ruat7whad9-kcI8_1KH_tQHaGI&pid=15.1',
                          scale: 1,
                        ),
                      ),
                      Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          icon: const Icon(Icons.add_a_photo), 
                          onPressed: selectImage,
                          ),
                          )
                    ],
                  ),
                  const SizedBox(
                    height: 24,),  
                  //text field input for username
                  TextFieldInput(
                    controller: _usernameEditingController, 
                    hintText: "Enter your username", 
                    textInputType: TextInputType.text,
                    ),
                   const SizedBox(
                    height: 24,
                    ),
                  // text field
                  TextFieldInput(
                    controller: _emailEditingController, 
                    hintText: "Enter your email", 
                    textInputType: TextInputType.emailAddress,
                    ),
                   const SizedBox(
                    height: 24,
                    ), 
                  // text Filld
                  TextFieldInput(
                    controller: _passEditingController,
                    isPass: true, 
                    hintText: "Enter your password", 
                    textInputType: TextInputType.text
                    ),
                    const SizedBox(
                    height: 24,
                    ),
                    TextFieldInput(
                    controller: _bioEditingController, 
                    hintText: "Enter your bio", 
                    textInputType: TextInputType.multiline,
                    ),
                   const SizedBox(
                    height: 24,
                    ),
                  // button login
                  InkWell(
                    onTap: signUpUser,
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(4),
                          ),
                        ),
                        color: blueColor,
                        ),
                      child: !_isLoading ?const Text("Sign up")
                      :const CircularProgressIndicator(
                        color: primaryColor,
                      ),
                       
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                    ),
                  Flexible(
                    flex: 2,
                    child: Container(),
                    ),
                  // transitioning to signing in
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: const Text("Do have an account?"),
                      ),
                      GestureDetector(
                        onTap: navigateToLogin,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          child: const Text("Sign in.",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),  
          )
          ),
      ),
    );
  }
}