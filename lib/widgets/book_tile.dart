import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/libraries_list.dart';

import '../screens/borrowed_book.dart';

class BookTile extends StatefulWidget {
  final String libId;
  BookTile(this.libId);

  @override
  _BookTileState createState() => _BookTileState();
}

class _BookTileState extends State<BookTile> {
  var _isLoading = false;
  var _isInit = true;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<LibrariesList>(context, listen: false)
          .fetchAndSetBooks(widget.libId)
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final libBooks =
        Provider.of<LibrariesList>(context).listOfBooks(widget.libId);
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : libBooks.length == 0
            ? Container(
                child: Center(
                  child: Text("No Books have been borrowed"),
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.only(top: 10, bottom: 15),
                itemCount: libBooks.length,
                itemBuilder: (ctx, i) => ListTile(
                  onTap: () {
                    print(libBooks[i].bookId);
                    Navigator.of(context).pushNamed(BorrowedBook.routeName,
                        arguments: [libBooks[i].bookId, widget.libId]);
                  },
                  title: Text(
                    libBooks[i].bookName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                separatorBuilder: (BuildContext ctx, int i) => Divider(
                  thickness: 5,
                  height: 15,
                ),
              );
  }
}
