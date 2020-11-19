import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/libraries_list.dart';

import '../screens/borrowed_book.dart';

class SearchOption extends SearchDelegate<String> {
  String libId;
  SearchOption(this.libId);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    //from suggestions it will get redirected
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<List<String>> bookDetailsMap =
        Provider.of<LibrariesList>(context, listen: false)
            .listOfListsForSearch(libId);

    final List<String> bookNamesList = bookDetailsMap.map((e) {
      return e[1];
    }).toList();
    final suggestionList = query.isEmpty
        ? bookNamesList
        : bookNamesList
            .where((p) => (p.contains(query.toUpperCase())))
            .toList();

    return ListView.separated(
      padding: EdgeInsets.only(top: 10, bottom: 15),
      itemCount: suggestionList.length,
      itemBuilder: (ctx, i) => ListTile(
        onTap: () {
          query = suggestionList[i];

          Navigator.of(context).pushReplacementNamed(BorrowedBook.routeName,
              arguments: [bookDetailsMap[i][0], libId]);
        },
        title: Text(
          suggestionList[i],
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      separatorBuilder: (BuildContext context, int i) => Divider(
        height: 15,
        thickness: 5,
      ),
    );
  }
}
