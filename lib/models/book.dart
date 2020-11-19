import 'package:flutter/foundation.dart';

class Book {
  final String bookId;
  final String bookName;
  double bookFine;
  final DateTime returnDate;
  final DateTime borrowDate;

  Book({
    @required this.bookId,
    @required this.bookName,
    @required this.bookFine,
    @required this.returnDate,
    @required this.borrowDate,
  });
}
