import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recipe_notes/Screens/Recipe_reader.dart';
import 'package:recipe_notes/Screens/recipe_editor.dart';


class homescreen extends StatefulWidget {
  const homescreen({Key? key}) : super(key: key);

  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
  final TextEditingController searchController = TextEditingController();
  String? selectedFilter;

  List<String> filterOptions = [
    "All",
    "veg",
    "non veg",
    "mild",
    "spicy",
    "drinks",
    "upvas",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Center(
          child: Text('Recipe Notes'),
        ),
      ),
      body:  Column(
            children: [
              SearchBar(searchController: searchController),
              FilterDropdown(
                filterOptions: filterOptions,
                selectedFilter: selectedFilter,
                onChanged: (newValue) {
                  setState(() {
                    selectedFilter = newValue;
                  });
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Recipenotes")
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    final List<QueryDocumentSnapshot> filteredRecipes =
                    snapshot.data!.docs.where((recipe) {
                      final String recipeName =
                      recipe["recipe_name"].toString().toLowerCase();
                      final String category =
                      recipe["category"].toString().toLowerCase();
                      final String searchQuery =
                      searchController.text.toLowerCase();

                      bool isCategoryMatch =
                      selectedFilter == null || selectedFilter == "All"
                          ? true
                          : category.contains(selectedFilter!);

                      return recipeName.contains(searchQuery) && isCategoryMatch;
                    }).toList();

                    return Expanded(
                      child: GridView(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2),
                          children: filteredRecipes
                              .map((note) => notes(() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        recipereader(note)));
                          }, note))
                              .toList(),
                        
                      ),
                    );
                  }
                  return Text(
                    "There are no Recipes",
                    style: GoogleFonts.nunito(
                        color: Colors.deepPurple, fontSize: 12),
                  );
                },
              ),
            ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => recipeeditor()));
        },
        label: Text("Add Recipe"),
        icon: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}



class FilterDropdown extends StatelessWidget {
  final List<String> filterOptions;
  final String? selectedFilter;
  final Function(String?) onChanged;

  FilterDropdown({
    required this.filterOptions,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: DropdownButtonFormField<String>(
          value: selectedFilter,
          onChanged: onChanged,
          items: filterOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          decoration: InputDecoration(
            labelText: 'Filter by Category',
          ),
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController searchController;

  SearchBar({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search by recipe name or category',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}




Widget notes(Function()? onTap, QueryDocumentSnapshot doc) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Text(
            doc["recipe_name"],
            style: GoogleFonts.lato(fontSize: 25),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                doc["category"],
                style: GoogleFonts.raleway(fontSize: 17),
              ),
              SizedBox(
                width: 15,
              ),
              Text(
                doc["time_required"],
                style: GoogleFonts.raleway(fontSize: 17),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            doc["ingredients"],
            style: GoogleFonts.raleway(fontSize: 17),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
            child: Text(
              doc["steps"],
              style: GoogleFonts.raleway(fontSize: 17),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}