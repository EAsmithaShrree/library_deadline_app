import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/library_grid.dart';

import '../providers/libraries_list.dart';
import '../providers/auth.dart';

import './library_form.dart';

class AllLibraries extends StatefulWidget {
  static const routeName = 'all-libraries';
  @override
  _AllLibrariesState createState() => _AllLibrariesState();
}

class _AllLibrariesState extends State<AllLibraries> {
  var _isInit = true;
  var _isLoading = false;
  final globalScaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<LibrariesList>(context, listen: false)
          .fecthAndSetLibraries()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshLibraries() async {
    await Provider.of<LibrariesList>(context,listen: false).fecthAndSetLibraries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalScaffoldKey,
      appBar: AppBar(
        title: Text("My Libraries"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: ()async {
             final result=await Navigator.of(context).pushNamed(LibraryForm.routeName);
             globalScaffoldKey.currentState.removeCurrentSnackBar();
             if(result==1){
             globalScaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: Text("Library added sucessfully!"),
                ),
              );
             }
            },
          ),
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text("Are you sure?"),
                    content: Text(
                      "You shall be logged out if you click on 'Confirm'.",
                    ),
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
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacementNamed('/');
                            Provider.of<Auth>(context, listen: false).logout();
                          }),
                    ],
                  ),
                );
              }),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              child: LibraryGrid(),
              onRefresh: _refreshLibraries,
            ),
    );
  }
}
