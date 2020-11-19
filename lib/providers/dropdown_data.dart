import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class LendingScheme extends ChangeNotifier {
  List<String> _lending = [];

  List<String> get lending {
    return [..._lending];
  }

  final String authToken;
  final String userId;
  LendingScheme(this.authToken, this.userId, this._lending);

  Future<void> fetchLendingScheme() async {
    final url = 'https://librarydeadlineapp.firebaseio.com/lending-scheme.json?auth=$authToken';
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    List<String> lendingScheme = [];
    extractedData.forEach((key, element) {
      for (var i = 0; i < element.length; i++) {
        lendingScheme.add(element[i]);
      }
    });
    print(lendingScheme.length);
    _lending = lendingScheme;
    notifyListeners();
  }
}
