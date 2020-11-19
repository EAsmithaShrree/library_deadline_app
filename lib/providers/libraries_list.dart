import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import '../models/library.dart';
import '../models/book.dart';
import '../models/http_exception.dart';

class LibrariesList extends ChangeNotifier {
  List<Library> _libraries = [];

  List<Library> get libraries {
    return [..._libraries];
  }

  final String authToken;
  final String userId;
  LibrariesList(this.authToken, this.userId, this._libraries);

  Library findById(String id) {
    return _libraries.firstWhere((library) => library.libId == id);
  }

  List<Book> listOfBooks(String libId) {
    final library = _libraries.firstWhere((library) => library.libId == libId);
    final bookList = library.borrowedBooks;
    if (bookList == null) {
      return [];
    }
    return bookList;
  }

  Book findByBookId(String bookId, String libId) {
    final library = _libraries.firstWhere((library) => library.libId == libId);
    final bookList = library.borrowedBooks;
    return bookList.firstWhere((book) => book.bookId == bookId);
  }

  Future<void> fetchAndSetBooks(String libraryId) async {
    final library =
        _libraries.firstWhere((library) => library.libId == libraryId);
    final url =
        'https://librarydeadlineapp.firebaseio.com/all-libraries/$libraryId/borrowedBooks.json?auth=$authToken';
    final response = await http.get(url);
    final extractedBooks =
        json.decode(response.body)['d15867d9-c79d-427e-af31-f782936e0988']
            as Map<String, dynamic>;

    if (extractedBooks == null) {
      return;
    }
    final List<Book> _loadedBooks = []; //library.borrowedBooks
    extractedBooks.forEach(
      (key, value) {
        if (key != 'bookId') {
          _loadedBooks.insert(
            0,
            Book(
              bookId: value['bookId'],
              bookName: value['bookName'],
              bookFine: value['bookFine'],
              returnDate: DateTime.parse(value['returnDate']),
              borrowDate: DateTime.parse(value['borrowDate']),
            ),
          );
        }
      },
    );

    library.borrowedBooks = _loadedBooks;
    notifyListeners();
  }

  Future<void> fecthAndSetLibraries() async {
    try {
      final url =
          'https://librarydeadlineapp.firebaseio.com/all-libraries.json?auth=$authToken&orderBy="creatorId"&equalTo="$userId"';
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<Library> loadedLibraries = [];
      extractedData.forEach((libraryid, libData) {
        loadedLibraries.insert(
          0,
          Library(
            libId: libraryid,
            libName: libData['libName'],
            memberId: libData['memberId'],
            deadlineType: libData['deadlineType'],
            deadlineNum: libData['deadlineNum'],
            fineType: libData['fineType'],
            fineNum: libData['fineNum'],
            fineTypeNumber: libData['fineTypeNumber'],
          ),
        );
      });
      _libraries = loadedLibraries;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addLibrary(Library library) async {
    final url =
        'https://librarydeadlineapp.firebaseio.com/all-libraries.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'libName': library.libName,
          'memberId': library.memberId,
          'deadlineType': library.deadlineType,
          'deadlineNum': library.deadlineNum,
          'fineType': library.fineType,
          'fineNum': library.fineNum,
          'fineTypeNumber': library.fineTypeNumber,
          'borrowedBooks': {
            'd15867d9-c79d-427e-af31-f782936e0988': {
              'bookId': "DFG456",
            },
          },
          'creatorId': userId,
        }),
      );
      final newLibrary = Library(
        libId: json.decode(response.body)['name'],
        libName: library.libName,
        memberId: library.memberId,
        deadlineType: library.deadlineType,
        deadlineNum: library.deadlineNum,
        fineType: library.fineType,
        fineNum: library.fineNum,
        fineTypeNumber: library.fineTypeNumber,
        borrowedBooks: [],
        returnedBooks: [],
      );
      _libraries.insert(0, newLibrary);
      notifyListeners();
    } catch (error) {
      //print(error);
      throw error;
    }
  }

  Future<void> updateLibrary(String libId, Library newLibrary) async {
    try {
      final libIndex = _libraries.indexWhere((lib) => lib.libId == libId);
      final url =
          'https://librarydeadlineapp.firebaseio.com/all-libraries/$libId.json?auth=$authToken';
      await http.patch(
        url,
        body: json.encode({
          'libName': newLibrary.libName,
          'memberId': newLibrary.memberId,
          'deadlineType': newLibrary.deadlineType,
          'deadlineNum': newLibrary.deadlineNum,
          'fineType': newLibrary.fineType,
          'fineNum': newLibrary.fineNum,
          'fineTypeNumber': newLibrary.fineTypeNumber,
        }),
      );
      _libraries[libIndex] = newLibrary;
      notifyListeners();
    } catch (error) {
      //print(error);
      throw error;
    }
  }

  Future<void> deleteLibrary(String libId) async {
    final url =
        'https://librarydeadlineapp.firebaseio.com/all-libraries/$libId.json?auth=$authToken';
    final existingLibIndex =
        _libraries.indexWhere((element) => element.libId == libId);
    var existingLibrary = _libraries[existingLibIndex];
    _libraries.removeAt(existingLibIndex);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _libraries.insert(existingLibIndex, existingLibrary);
      notifyListeners();
      throw HttpException('Could not delete the library.');
    }
    existingLibrary = null;
  }

  Future<void> deleteBook(String libraryId, String bookId) async {
    var url =
        'https://librarydeadlineapp.firebaseio.com/all-libraries/$libraryId/borrowedBooks.json?auth=$authToken';
    String reqBookKey;
    final response = await http.get(url);
    final extractedBooks =
        json.decode(response.body)['d15867d9-c79d-427e-af31-f782936e0988']
            as Map<String, dynamic>;
    print(extractedBooks);

    extractedBooks.forEach((key, value) {
      if (key != 'bookId') {
        if (value['bookId'] == bookId) {
          reqBookKey = key;
        }
      }
    });
    url =
        'https://librarydeadlineapp.firebaseio.com/all-libraries/$libraryId/borrowedBooks/d15867d9-c79d-427e-af31-f782936e0988/$reqBookKey.json?auth=$authToken';
    await http.delete(url);
    final library =
        _libraries.firstWhere((library) => library.libId == libraryId);
    final List<Book> libraryBorrowedBooks = library.borrowedBooks;
    final bookToBeDeleted =
        libraryBorrowedBooks.firstWhere((book) => book.bookId == bookId);
    libraryBorrowedBooks.removeWhere((element) => element == bookToBeDeleted);
    notifyListeners();
  }

  Future<void> appendBookLists(String libraryId, List<Book> newBooks) async {
    try {
      final library =
          _libraries.firstWhere((library) => library.libId == libraryId);
      if (library.borrowedBooks == null) {
        library.borrowedBooks = [];
      }
      final url =
          'https://librarydeadlineapp.firebaseio.com/all-libraries/$libraryId/borrowedBooks/d15867d9-c79d-427e-af31-f782936e0988.json?auth=$authToken';

      newBooks.forEach((book) async {
        await http.post(
          url,
          body: json.encode({
            'bookId': book.bookId,
            'bookName': book.bookName,
            'bookFine': book.bookFine,
            'borrowDate': book.borrowDate.toIso8601String(),
            'returnDate': book.returnDate.toIso8601String(),
          }),
        );
      });

      library.borrowedBooks.insertAll(
        0,
        newBooks.map((e) {
          return e;
        }),
      );

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  DateTime calculateReturnDate(String libraryId, DateTime borrowDate) {
    final library =
        _libraries.firstWhere((library) => library.libId == libraryId);
    final libReturnType = library.deadlineType;
    final libReturnTypeDuration = library.deadlineNum;
    int days = calculateDuration(libReturnType, libReturnTypeDuration);
    DateTime returnDate = borrowDate.add(Duration(days: days));
    return returnDate;
  }

  int calculateDuration(String libReturnType, int librReturnTypeDur) {
    int days = 0;
    if (libReturnType == "DAY(S)") {
      days = librReturnTypeDur;
    } else if (libReturnType == "WEEK(S)") {
      days = librReturnTypeDur * 7;
    }
    return days;
  }

  void fineCalculation(String libraryId, Book book) {
    final library =
        _libraries.firstWhere((library) => library.libId == libraryId);
    final libFineType = library.fineType;
    final libFineAmount = library.fineNum;
    final libFineDuration = library.fineTypeNumber;
    double bookFineAmount;
    int days = calculateDuration(libFineType, libFineDuration);
    int daysElapsed = DateTime.now().difference(book.returnDate).inDays;

    bookFineAmount = (daysElapsed / days) * libFineAmount;
    if (bookFineAmount < 0) {
      bookFineAmount = 0.0;
    }
    book.bookFine = bookFineAmount;
  }

  List<List<String>> listOfListsForSearch(String libId) {
    List<List<String>> borrowedBookNamesList = [];
    final booksList = listOfBooks(libId);

    for (var i = 0; i < booksList.length; i++) {
      borrowedBookNamesList.add([booksList[i].bookId, booksList[i].bookName]);
    }
    return borrowedBookNamesList;
  }
}
