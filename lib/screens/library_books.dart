import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/libraries_list.dart';

import '../widgets/book_tile.dart';
import '../widgets/search_option.dart';

import '../screens/book_form.dart';

class LibraryBooks extends StatelessWidget {
  static const routeName = '/library-books';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final libId = ModalRoute.of(context).settings.arguments as String;
    final library =
        Provider.of<LibrariesList>(context, listen: false).findById(libId);

    Future<void> _refreshBooks(BuildContext context) async {
      await Provider.of<LibrariesList>(context, listen: false)
          .fetchAndSetBooks(libId);
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(library.libName),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.library_books),
            onPressed: () async {
              final result = await Navigator.of(context)
                  .pushNamed(BookForm.routeName, arguments: library.libId);
              //_scaffoldKey.currentState.hideCurrentSnackBar();
              if (result == 1) {
                _scaffoldKey.currentState.showSnackBar(
                  SnackBar(
                    content: Text("Book(s) added successfully!"),
                  ),
                );
              }
            },
          ),
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: SearchOption(libId));
              }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshBooks(context),
        child: BookTile(libId),
      ), 
    );
  }
}
