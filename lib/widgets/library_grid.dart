import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/singleLibrary.dart';
import '../models/library.dart';

import '../providers/libraries_list.dart';

class LibraryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Library> loadedLibraries =
        Provider.of<LibrariesList>(context).libraries;

    return loadedLibraries.length == 0
        ? Center(
            child: Text(
              "You haven't added any libraries yet!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          )
        : GridView.builder(
            padding: EdgeInsets.all(15),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 2.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 20,
            ),
            itemBuilder: (ctx, i) => SingleLibrary(
              loadedLibraries[i].libName,
              loadedLibraries[i].memberId,
              loadedLibraries[i].libId,
            ),
            itemCount: loadedLibraries.length,
          );
  }
}
