import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import './screens/all_libraries.dart';
import './screens/library_books.dart';
import './screens/borrowed_book.dart';
import './screens/library_form.dart';
import './screens/book_form.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './providers/libraries_list.dart';
import './providers/dropdown_data.dart';
import './providers/auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, LibrariesList>(
          create: null,
          update: (ctx, auth, previousState) => LibrariesList(
            auth.token,
            auth.userId,
            previousState == null ? [] : previousState.libraries,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, LendingScheme>(
          create: null,
          update: (ctx, auth, previousState) => LendingScheme(
            auth.token,
            auth.userId,
            previousState == null ? [] : previousState.lending,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => GestureDetector(
          onTap: () {
            WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Library App',
            theme: ThemeData(
              primaryColor: Colors.redAccent,
              accentColor: Colors.redAccent,
            ),
            home: auth.isAuth
                ? AllLibraries()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (context, authResultSnapShot) =>
                        authResultSnapShot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              // AllLibraries.routeName: (ctx)=> AllLibraries(),
              LibraryBooks.routeName: (ctx) => LibraryBooks(),
              BorrowedBook.routeName: (ctx) => BorrowedBook(),
              LibraryForm.routeName: (ctx) => LibraryForm(),
              BookForm.routeName: (ctx) => BookForm(),
            },
          ),
        ),
      ),
    );
  }
}
