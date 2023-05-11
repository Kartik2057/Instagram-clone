import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_flutter/providers/image_selection_provider.dart';
import 'package:instagram_flutter/providers/user_provider.dart';
import 'package:instagram_flutter/responsive/mobile_screen_layout.dart';
import 'package:instagram_flutter/responsive/responsive_layout_screen.dart';
import 'package:instagram_flutter/responsive/web_screen_layout.dart';
import 'package:instagram_flutter/screens/login_screen.dart';
import 'package:provider/provider.dart';
import './utils/colors.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
  await Firebase.initializeApp(
    //Sensitive information like apikey and others have been removed for safety
    //You can add these information following the steps given in the readme file 
    
    options:  const FirebaseOptions(
      apiKey: "AIzaSyAES1IDPCgyyjuRhb65gkg83oHlfHjX2ps", 
      appId: "1:1015517077041:web:156b93244e38cabc20bf10", 
      messagingSenderId: "1015517077041", 
      projectId: "instagram-clone-8939b",
      storageBucket: "instagram-clone-8939b.appspot.com",
      )
  );
  }
  else{
  await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
          ),
        ChangeNotifierProvider(
          create: (_)=>ImageSelectionProvider()
          ),  
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Instagram clone',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
      //   home: const ResponsiveLayout(webScreenLayout: WebScreenLayout(), mobileScreenLayout: MobileScreenLayout())
      // );
    
      home: StreamBuilder(
        builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.active){
              if(snapshot.hasData){
                return const ResponsiveLayout(
                  webScreenLayout: WebScreenLayout(), 
                  mobileScreenLayout: MobileScreenLayout()
                  );
              }
              else if (snapshot.hasError){
                  return Center(
                    child: Text("${snapshot.error}"),
                  );
              }
            }
            else if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(
                  color:primaryColor,
                ),
              );
            }
            return const LoginScreen();
        }, 
        stream:FirebaseAuth.instance.authStateChanges(),
        )
      ),
    );
  }
}

