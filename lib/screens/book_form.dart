import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../providers/libraries_list.dart';

import '../models/book.dart';

class BookForm extends StatefulWidget {
  static const routeName = '/book-form';
  @override
  _BookFormState createState() => _BookFormState();
}

class _BookFormState extends State<BookForm> {
  var uuid = Uuid();
  List<Book> bookTable = [];
  Book _selectedBook;
  int _selectedBookIndex;
  var _selectedDate;
  var _isUpdating = false;
  TextEditingController _bookNameController = TextEditingController();
  TextEditingController _borrowDateController = TextEditingController();
  var _editedBook = Book(
    bookId: null,
    bookName: '',
    bookFine: 0,
    returnDate: DateTime.now(),
    borrowDate: DateTime.now(),
  );

  void _clearValues() {
    _bookNameController.text = '';
    _borrowDateController.text = '';
  }

  void _showValues(Book book) {
    _bookNameController.text = book.bookName;
    _borrowDateController.text =
        DateFormat("yyyy-MM-dd").format(book.borrowDate).toString();
  }

  void _addBook(String libId) {
    
    if (_bookNameController.text.isEmpty || _selectedDate == null) {
      return;
    }
    DateTime returnDate = Provider.of<LibrariesList>(context, listen: false)
        .calculateReturnDate(libId, _selectedDate);

    var v4 = uuid.v4();
    _editedBook = Book(
      bookId: v4, 
      bookName: _bookNameController.text.toUpperCase(),
      bookFine: 0.0,
      returnDate: returnDate,
      borrowDate:
          DateTime.parse(DateFormat("yyyy-MM-dd").format(_selectedDate)),
    );
    setState(() {
      bookTable.add(_editedBook);
    });
    
    _clearValues();
  }

  void _updateBook(Book selectedBook, int selectedBookIndex, String libId) {
    setState(() {
      _isUpdating = true;
    });
    if (_bookNameController.text.isEmpty || _selectedDate == null) {
      return;
    }
    DateTime returnDate = Provider.of<LibrariesList>(context, listen: false)
        .calculateReturnDate(libId, selectedBook.borrowDate);
    
    _editedBook = Book(
        bookId: selectedBook.bookId,
        bookName: _bookNameController.text.toUpperCase(),
        bookFine: 0.0,
        returnDate: returnDate,
        borrowDate:
            DateTime.parse(DateFormat("yyyy-MM-dd").format(selectedBook.borrowDate)));
    setState(() {
      bookTable[selectedBookIndex - 1] = _editedBook;
    });
    bookTable.map((e) => print(e.bookName)).toList();
    setState(() {
      _isUpdating = false;
    });
    _clearValues();
  }

  void _deleteBook() {
    setState(() {
      bookTable.remove(_editedBook);
    });
  }

  void _presentDatePicker() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    await Future.delayed(Duration(milliseconds: 300));
    await showDatePicker(
      context: context,
      initialDate:DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedValue) {
      if (pickedValue == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedValue;
        _borrowDateController.text =
            DateFormat("yyyy-MM-dd").format(pickedValue).toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String libId = ModalRoute.of(context).settings.arguments as String;
    final _horizontalScrollController = ScrollController();
    final _verticalScrollController = ScrollController();
    return Scaffold(
      appBar: AppBar(
        title: Text("BOOKS"),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Card(
                elevation: 5,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: _bookNameController,
                        decoration: InputDecoration(
                          labelText: "Book Name",
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: TextField(
                              readOnly: true,
                              controller: _borrowDateController,
                              decoration: InputDecoration(
                                  labelText: "Choose Borrow Date"),
                            ),
                          ),
                          RaisedButton(
                            //color: Colors.red,
                            onPressed:
                           _presentDatePicker,
                            child: Text(
                              "Choose Date",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 15),
              _isUpdating
                  ? Row(
                      children: <Widget>[
                        SizedBox(width: 10),
                        OutlineButton(
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.black,
                          ),
                          child: Text(
                            'Update',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () {
                            _updateBook(
                                _selectedBook, _selectedBookIndex, libId);
                          },
                        ),
                        SizedBox(width: 10),
                        OutlineButton(
                          borderSide: BorderSide(
                            width: 2,
                            color: Colors.black,
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _isUpdating = false;
                            });
                            _clearValues();
                          },
                        ),
                      ],
                    )
                  : OutlineButton(
                      borderSide: BorderSide(
                        width: 2,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        _addBook(libId);
                      },
                      child: Text(
                        "ADD BOOK",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  height: 300,
                  child: Scrollbar(
                    controller: _verticalScrollController,
                    isAlwaysShown: true,
                    child: SingleChildScrollView(
                      controller: _verticalScrollController,
                      scrollDirection: Axis.vertical,
                      child: Scrollbar(
                        isAlwaysShown: true,
                        controller: _horizontalScrollController,
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: IntrinsicWidth(
                            child: Stack(
                              children: [
                                Container(
                                  height: 60,
                                  color: Theme.of(context).primaryColor,
                                ),
                                DataTable(
                                  headingRowHeight: 60,
                                  dividerThickness: 2,
                                  columns: [
                                    DataColumn(
                                      label: Text(
                                        "No.",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "Book Name",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "Borrow Date",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "Delete",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: bookTable
                                      .map(
                                        (book) => DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                (bookTable.indexOf(book) + 1)
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              onTap: () {
                                                _showValues(book);
                                                _selectedBook = book;
                                                _selectedBookIndex =
                                                    bookTable.indexOf(book) + 1;
                                                setState(() {
                                                  _isUpdating = true;
                                                });
                                              },
                                            ),
                                            DataCell(
                                              Text(
                                                book.bookName,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              onTap: () {
                                                _showValues(book);
                                                _selectedBook = book;
                                                _selectedBookIndex =
                                                    bookTable.indexOf(book) + 1;
                                                setState(() {
                                                  _isUpdating = true;
                                                });
                                              },
                                            ),
                                            DataCell(
                                              Text(
                                                DateFormat("yyyy-MM-dd")
                                                    .format(book.borrowDate)
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              onTap: () {
                                                _showValues(book);
                                                _selectedBook = book;
                                                _selectedBookIndex =
                                                    bookTable.indexOf(book) + 1;
                                                setState(() {
                                                  _isUpdating = true;
                                                });
                                              },
                                            ),
                                            DataCell(
                                              IconButton(
                                                icon: Icon(Icons.delete),
                                                onPressed: _deleteBook,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              FlatButton(
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  try {
                    await Provider.of<LibrariesList>(context, listen: false)
                        .appendBookLists(libId, bookTable);
                  } catch (error) {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("An error occured!"),
                        content: Text("Oops.Something went wrong..."),
                        actions: [
                          FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "OK",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  Navigator.pop(context, 1);
                },
                child: Text(
                  "SUBMIT",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
