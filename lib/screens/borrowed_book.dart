import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/libraries_list.dart';

import '../models/book.dart';

class BorrowedBook extends StatefulWidget {
  static const routeName = '/borrowed-book';

  @override
  _BorrowedBookState createState() => _BorrowedBookState();
}

class _BorrowedBookState extends State<BorrowedBook> {
  Book bookDetails;
  String bookId;
  String libId;
  var _isInit = true;
  var _isLoading = false;
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void didChangeDependencies() {
    if (_isInit) {
      final List arguement = ModalRoute.of(context).settings.arguments as List;
      bookId = arguement[0];
      libId = arguement[1];
      bookDetails = Provider.of<LibrariesList>(context, listen: false)
          .findByBookId(bookId, libId);

      Provider.of<LibrariesList>(context, listen: false)
          .fineCalculation(libId, bookDetails);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          bookDetails.bookName,
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Card(
                        color: Theme.of(context).primaryColor,
                        elevation: 10,
                        child: Container(
                          height: 180,
                          width: 400,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: LayoutBuilder(builder: (ctx, constraint) {
                              return Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Flexible(
                                    fit: FlexFit.tight,
                                    child: Container(
                                      width: constraint.maxWidth,
                                      height: constraint.maxHeight * 0.4,
                                      child: Text(
                                        bookDetails.bookName,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: constraint.maxHeight * 0.04),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "BORROW DATE",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                          width: constraint.maxHeight * 0.1),
                                      Text(
                                        DateFormat("yyyy-MM-dd")
                                            .format(bookDetails.borrowDate)
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: constraint.maxHeight * 0.04),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "RETURN DATE",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                          width: constraint.maxWidth * 0.075),
                                      Text(
                                        DateFormat("yyyy-MM-dd")
                                            .format(bookDetails.returnDate)
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: constraint.maxHeight * 0.04),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "FINE AMOUNT",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                          width: constraint.maxWidth * 0.075),
                                      Text(
                                        bookDetails.bookFine.toStringAsFixed(4),
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "Click on 'Book Returned' once you return your book!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          RaisedButton(
                              child: Text(
                                "Book Returned",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ),
                              padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
                              color: Theme.of(context).primaryColor,
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text("Are you sure?"),
                                    content: Text(
                                        "The stored book information shall also be deleted."),
                                    actions: [
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                      FlatButton(
                                        onPressed: () async {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          await Provider.of<LibrariesList>(
                                                  context,
                                                  listen: false)
                                              .deleteBook(libId, bookId);

                                          setState(() {
                                            _isLoading = false;
                                          });
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                          _scaffoldKey.currentState
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "One book deleted successfully!"),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Confirm",
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
