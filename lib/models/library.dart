import 'package:flutter/foundation.dart';

import '../models/book.dart';

class Library {
  final String libId;
  final String libName;
  final String memberId;
  List<Book> borrowedBooks;
  List<Book> returnedBooks;
  final String deadlineType;
  final int deadlineNum;
  final String fineType;
  final double fineNum;
  final int fineTypeNumber;

  Library({
    @required this.libId,
    @required this.libName,
    @required this.memberId,
    this.borrowedBooks,
    this.returnedBooks,
    @required this.deadlineType,
    @required this.deadlineNum,
    @required this.fineType,
    @required this.fineNum,
    @required this.fineTypeNumber,
  });
}
