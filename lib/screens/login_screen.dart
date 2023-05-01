import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_flutter/Widgets/text_field_input.dart';
import 'package:instagram_flutter/resources/auth_methods.dart';
import 'package:instagram_flutter/screens/signup_screen.dart';
import 'package:instagram_flutter/utils/global_variables.dart';
import 'package:instagram_flutter/utils/utils.dart';
import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_screen_layout.dart';
import '../utils/colors.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passEditingController = TextEditingController();
  bool _isLoading= false;

  void logInUser() async {
    setState(() {
    _isLoading=true;
    });
    String res= await AuthMethods().logInUser(
      email: _emailEditingController.text, 
      password: _passEditingController.text);
      setState(() {
    _isLoading=false;
      });
    if(res!="Success") {
      // ignore: use_build_context_synchronously
      showSnackbar(res.substring(res.indexOf(']')+1), context);
    } else{
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) =>const ResponsiveLayout(
                webScreenLayout: WebScreenLayout(), 
                mobileScreenLayout: MobileScreenLayout()
                )
    )
    );
    }
  }

  void navigateToSignup(){
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) =>const SignupScreen()
    )
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: MediaQuery.of(context).size.width > webScreenSize ?
          EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width /3,
            )
          :const EdgeInsets.symmetric(
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
              // text field
              TextFieldInput(
                controller: _emailEditingController, 
                isPass: false, 
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
                textInputType: TextInputType.text,
                ),
                const SizedBox(
                height: 24,
                ),
              // button login
              InkWell(
                onTap: logInUser,
                child: _isLoading?
                Center(child: CircularProgressIndicator(
                ),
                ):Container(
                  child: const Text("Log In"),
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
                ),
              ),
              const SizedBox(
                height: 12,
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
                    child: const Text("Don't have an account?"),
                  ),
                  GestureDetector(
                    onTap: navigateToSignup,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: const Text("Sign up.",
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
    );
  }
}