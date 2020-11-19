import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/library_books.dart';
import '../screens/library_form.dart';

import '../providers/libraries_list.dart';

class SingleLibrary extends StatelessWidget {
  final String libName;
  final String memberId;

  final String libId;
  SingleLibrary(this.libName, this.memberId, this.libId);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    final navigator = Navigator.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GridTile(
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          splashColor: Theme.of(context).primaryColor,
          onTap: () {
            Navigator.of(context)
                .pushNamed(LibraryBooks.routeName, arguments: libId);
          },
          child: Container(
            padding: EdgeInsets.fromLTRB(50, 10, 50, 30),
            height: 30,
            width: 30,
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Text(
                libName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
        footer: GridTileBar(
          title: Text(
            memberId,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.of(context)
                  .pushNamed(LibraryForm.routeName, arguments: libId);
              scaffold.hideCurrentSnackBar();
              if (result == 2) {
                scaffold.showSnackBar(
                  SnackBar(
                    content: Text("Library updated sucessfully!"),
                  ),
                );
              }
            },
          ),
          trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
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
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      FlatButton(
                        onPressed: () async {
                          try {
                            await Provider.of<LibrariesList>(context,
                                    listen: false)
                                .deleteLibrary(libId);
                            navigator.pop();
                            scaffold.hideCurrentSnackBar();
                            scaffold.showSnackBar(
                              SnackBar(
                                content: Text("Library deleted successfully!"),
                              ),
                            );
                          } catch (error) {
                            navigator.pop();
                            scaffold.showSnackBar(
                              SnackBar(
                                content: Text("Deleting failed!"),
                              ),
                            );
                          }
                        },
                        child: Text(
                          "Confirm",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}
