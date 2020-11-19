import 'package:flutter/material.dart';
import 'package:library_deadline_app/providers/dropdown_data.dart';
import 'package:provider/provider.dart';

import '../models/library.dart';

import '../providers/libraries_list.dart';

class LibraryForm extends StatefulWidget {
  static const routeName = '/library-form';

  @override
  _LibraryFormState createState() => _LibraryFormState();
}

class _LibraryFormState extends State<LibraryForm> {
  final _memberIdFocusNode = FocusNode();
  final _submitNode = FocusNode();
  final _fineTypeNumberFocusNode = FocusNode();
  final _deadlineTypeFocusNode = FocusNode();
  final _fineAmountFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var _isInit = true;
  var _isLoading = false;

  String _currentReturnType = '--SELECT--';
  String _currentFineType = '--SELECT--';
  var _editedLibrary = Library(
    libId: null,
    libName: '',
    memberId: '',
    deadlineType: '',
    deadlineNum: 0,
    fineType: '',
    fineNum: 0, //fine amount
    fineTypeNumber: 0, //fine scheme
    borrowedBooks: [],
    returnedBooks: [],
  );
  var _initValues = {
    'libName': '',
    'memberId': '',
    'deadlineType': '',
    'deadlineNum': '',
    'fineType': '',
    'fineNum': '', //fine amount
    'fineTypeNumber': '', //fine scheme
  };
  @override
  void dispose() {
    _memberIdFocusNode.dispose();
    _submitNode.dispose();
    _fineTypeNumberFocusNode.dispose();
    _deadlineTypeFocusNode.dispose();
    _fineAmountFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<LendingScheme>(context).fetchLendingScheme().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      final libraryId = ModalRoute.of(context).settings.arguments as String;
      if (libraryId != null) {
        _editedLibrary = Provider.of<LibrariesList>(context, listen: false)
            .findById(libraryId);
        _currentReturnType = _editedLibrary.deadlineType;
        _currentFineType = _editedLibrary.fineType;
        _initValues = {
          'libName': _editedLibrary.libName,
          'memberId': _editedLibrary.memberId,
          'deadlineType': _editedLibrary.deadlineType,
          'deadlineNum': _editedLibrary.deadlineNum.toString(),
          'fineType': _editedLibrary.fineType,
          'fineNum': _editedLibrary.fineNum.toString(), //fine amount
          'fineTypeNumber':
              _editedLibrary.fineTypeNumber.toString(), //fine scheme
        };
      }
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    _editedLibrary = Library(
      libId: _editedLibrary.libId,
      libName: _editedLibrary.libName,
      memberId: _editedLibrary.memberId,
      deadlineType: _currentReturnType,
      deadlineNum: _editedLibrary.deadlineNum,
      fineType: _currentFineType,
      fineNum: _editedLibrary.fineNum,
      fineTypeNumber: _editedLibrary.fineTypeNumber,
      borrowedBooks: _editedLibrary.borrowedBooks,
      returnedBooks: _editedLibrary.returnedBooks,
    );
    final _isValid = _formKey.currentState.validate();
    if (!_isValid) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedLibrary.libId != null) {
      try {
        await Provider.of<LibrariesList>(context, listen: false)
            .updateLibrary(_editedLibrary.libId, _editedLibrary);
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context, 2);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
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
    } else {
      try {
        await Provider.of<LibrariesList>(context, listen: false)
            .addLibrary(_editedLibrary);
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context, 1);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> lendingSchemeList =
        Provider.of<LendingScheme>(context).lending;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("LIBRARY DETAILS"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(10),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      TextFormField(
                        initialValue: _initValues['libName'],
                        decoration: InputDecoration(
                          labelText: "NAME OF THE LIBRARY",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_memberIdFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter the name of the library.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedLibrary = Library(
                            libId: _editedLibrary.libId,
                            libName: value.toUpperCase(),
                            memberId: _editedLibrary.memberId,
                            deadlineType: _editedLibrary.deadlineType,
                            deadlineNum: _editedLibrary.deadlineNum,
                            fineType: _editedLibrary.fineType,
                            fineNum: _editedLibrary.fineNum,
                            fineTypeNumber: _editedLibrary.fineTypeNumber,
                            borrowedBooks: _editedLibrary.borrowedBooks,
                            returnedBooks: _editedLibrary.returnedBooks,
                          );
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "LIBRARY MEMBER ID",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        initialValue: _initValues['memberId'],
                        textInputAction: TextInputAction.next,
                        focusNode: _memberIdFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_deadlineTypeFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter the library member ID.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedLibrary = Library(
                            libId: _editedLibrary.libId,
                            libName: _editedLibrary.libName,
                            memberId: value,
                            deadlineType: _editedLibrary.deadlineType,
                            deadlineNum: _editedLibrary.deadlineNum,
                            fineType: _editedLibrary.fineType,
                            fineNum: _editedLibrary.fineNum,
                            fineTypeNumber: _editedLibrary.fineTypeNumber,
                            borrowedBooks: _editedLibrary.borrowedBooks,
                            returnedBooks: _editedLibrary.returnedBooks,
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            "LENDING SCHEME:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      LayoutBuilder(builder: (context, constraint) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              width: constraint.maxWidth * 0.25,
                              child: Text(
                                "NUMBER OF",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            SizedBox(width: constraint.maxWidth * 0.01),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                items: lendingSchemeList.map(
                                  (type) {
                                    return DropdownMenuItem<String>(
                                      child: Text(type),
                                      value: type,
                                    );
                                  },
                                ).toList(),
                                onChanged: (String newValue) {
                                  setState(() {
                                    this._currentReturnType = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == "--SELECT--") {
                                    return "Not a valid value.";
                                  }
                                  return null;
                                },
                                value: _currentReturnType,
                              ),
                            ),
                            SizedBox(width: constraint.maxWidth * 0.01),
                            Container(
                              width: constraint.maxWidth * 0.25,
                              child: TextFormField(
                                initialValue: _initValues['deadlineNum'],
                                onSaved: (value) {
                                  _editedLibrary = Library(
                                    libId: _editedLibrary.libId,
                                    libName: _editedLibrary.libName,
                                    memberId: _editedLibrary.memberId,
                                    deadlineType: _editedLibrary.deadlineType,
                                    deadlineNum: int.parse(value),
                                    fineType: _editedLibrary.fineType,
                                    fineNum: _editedLibrary.fineNum,
                                    fineTypeNumber:
                                        _editedLibrary.fineTypeNumber,
                                    borrowedBooks: _editedLibrary.borrowedBooks,
                                    returnedBooks: _editedLibrary.returnedBooks,
                                  );
                                },
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Enter a number.";
                                  }
                                  if (int.tryParse(value) == null) {
                                    return "Enter a valid number.";
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_fineTypeNumberFocusNode);
                                },
                                focusNode: _deadlineTypeFocusNode,
                                decoration: InputDecoration(
                                  labelText: "NUMBER",
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: double.infinity,
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            "FINE SCHEME:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      LayoutBuilder(builder: (context, constraint) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              width: constraint.maxWidth * 0.25,
                              child: Text(
                                "NUMBER OF",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            SizedBox(width: constraint.maxWidth * 0.01),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                items: lendingSchemeList.map(
                                  (type) {
                                    return DropdownMenuItem<String>(
                                      child: Text(type),
                                      value: type,
                                    );
                                  },
                                ).toList(),
                                onChanged: (String newValue) {
                                  setState(() {
                                    this._currentFineType = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == "--SELECT--") {
                                    return "Not a valid value.";
                                  }
                                  return null;
                                },
                                value: _currentFineType,
                              ),
                            ),
                            SizedBox(width: constraint.maxWidth * 0.01),
                            Container(
                              width: constraint.maxWidth * 0.25,
                              child: TextFormField(
                                initialValue: _initValues['fineTypeNumber'],
                                onSaved: (value) {
                                  _editedLibrary = Library(
                                    libId: _editedLibrary.libId,
                                    libName: _editedLibrary.libName,
                                    memberId: _editedLibrary.memberId,
                                    deadlineType: _editedLibrary.deadlineType,
                                    deadlineNum: _editedLibrary.deadlineNum,
                                    fineType: _editedLibrary.fineType,
                                    fineNum: _editedLibrary.fineNum,
                                    fineTypeNumber: int.parse(value),
                                    borrowedBooks: _editedLibrary.borrowedBooks,
                                    returnedBooks: _editedLibrary.returnedBooks,
                                  );
                                },
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Enter a number.";
                                  }
                                  if (int.tryParse(value) == null) {
                                    return "Enter a valid number.";
                                  }
                                  return null;
                                },
                                focusNode: _fineTypeNumberFocusNode,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context)
                                      .requestFocus(_fineAmountFocusNode);
                                },
                                decoration: InputDecoration(
                                  labelText: "NUMBER",
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      SizedBox(height: 20),
                      TextFormField(
                        initialValue: _initValues['fineNum'],
                        decoration: InputDecoration(
                          labelText: "FINE AMOUNT",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 2,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_submitNode);
                        },
                        focusNode: _fineAmountFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Enter a number.";
                          }
                          if (double.tryParse(value) == null) {
                            return "Enter a valid number.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedLibrary = Library(
                            libId: _editedLibrary.libId,
                            libName: _editedLibrary.libName,
                            memberId: _editedLibrary.memberId,
                            deadlineType: _editedLibrary.deadlineType,
                            deadlineNum: _editedLibrary.deadlineNum,
                            fineType: _editedLibrary.fineType,
                            fineNum: double.parse(value),
                            fineTypeNumber: _editedLibrary.fineTypeNumber,
                            borrowedBooks: _editedLibrary.borrowedBooks,
                            returnedBooks: _editedLibrary.returnedBooks,
                          );
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RaisedButton(
                            elevation: 15,
                            padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            focusNode: _submitNode,
                            child: Text(
                              "CANCEL",
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          RaisedButton(
                            elevation: 15,
                            padding: EdgeInsets.fromLTRB(25, 15, 25, 15),
                            color: Theme.of(context).primaryColor,
                            onPressed: _saveForm,
                            focusNode: _submitNode,
                            child: Text(
                              "SUBMIT",
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ),
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
