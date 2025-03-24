
import 'package:dual_force/viewmodels/book_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:dual_force/viewmodels/auth_viewmodel.dart';
import 'package:dual_force/viewmodels/chat_viewmodel.dart';
import 'package:dual_force/viewmodels/create_bot_viewmodel.dart';
import 'package:dual_force/views/screens/auth/sign_up/sign_up_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  await dotenv.load(fileName: ".env");
  runApp( MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewmodel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => CreateBotViewmodel(),
        ),
        ChangeNotifierProvider(
          create: (_) => BookViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        home: SignUpScreen(),
      ),
    );
  }
}
