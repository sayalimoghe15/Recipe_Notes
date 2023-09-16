import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class recipeeditor extends StatefulWidget {
  const recipeeditor({Key? key}) : super(key: key);

  @override
  State<recipeeditor> createState() => _recipeeditorState();
}

class _recipeeditorState extends State<recipeeditor> {
  String date = DateTime.now().toString();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _stepsController = TextEditingController();
  TextEditingController _ingredientsController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Add a Recipe"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            children: [
              TextField(
                style: GoogleFonts.roboto(),
                controller: _titleController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Recipe Name',
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                date,
                style: GoogleFonts.raleway(),
              ),
              SizedBox(height: 28),
              TextField(
                style: GoogleFonts.raleway(),
                controller: _timeController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Time required',
                ),
              ),
              SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                items: ["veg","non veg", "mild", "spicy" ,"drinks", "upvas"].map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Category',
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                style: GoogleFonts.raleway(),
                controller: _ingredientsController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Ingredients',
                ),
              ),
              SizedBox(height: 10.0),
                 Expanded(
                  child: SingleChildScrollView(
                    child: TextField(
                      style: GoogleFonts.raleway(),
                      controller: _stepsController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Steps of recipe',
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 10.0),
            ],
          ),
        ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          FirebaseFirestore.instance.collection("Recipenotes").add({
            "recipe_name": _titleController.text,
            "time_required": _timeController.text,
            "category": selectedCategory ?? '', // Use selectedCategory
            "ingredients": _ingredientsController.text,
            "steps": _stepsController.text,
          }).then((value) {
            print(value.id);
            Navigator.pop(context);
          }).catchError(
                  (error) => print("Failed to add new recipe due to error"));
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
