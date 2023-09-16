import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class recipereader extends StatefulWidget {
  recipereader(this.doc, {Key? key}) : super(key: key);
  final QueryDocumentSnapshot doc;

  @override
  State<recipereader> createState() => _recipereaderState();
}

class _recipereaderState extends State<recipereader> {
  Future<void> deleteRecipe() async {
    try {
      // Delete the recipe from Firestore
      await FirebaseFirestore.instance
          .collection('Recipenotes')
          .doc(widget.doc.id)
          .delete();

      // After successful deletion, navigate back to the previous screen or perform any desired action.
      Navigator.of(context).pop();
    } catch (error) {
      // Handle any errors that may occur during deletion
      print('Error deleting recipe: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0.0,
        title: Text(
          widget.doc["recipe_name"],
        ),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditRecipeScreen(widget.doc),
                    ),
                  );
                },
                icon: Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Delete this?"),
                        content: Text("Recipe will be deleted"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              deleteRecipe();
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.delete),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                widget.doc["recipe_name"],
                style: GoogleFonts.lato(fontSize: 30),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.doc["category"],
                    style: GoogleFonts.raleway(fontSize: 17),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    widget.doc["time_required"],
                    style: GoogleFonts.raleway(fontSize: 17),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                widget.doc["ingredients"],
                style: GoogleFonts.raleway(fontSize: 17),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 5,
              ), Text(
                  widget.doc["steps"],
                  style: GoogleFonts.raleway(fontSize: 17),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
    ],
      )
    );
  }
}

class EditRecipeScreen extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  EditRecipeScreen(this.doc);

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  String date = DateTime.now().toString();
  TextEditingController recipeNameController = TextEditingController();
  TextEditingController timeRequiredController = TextEditingController();
  TextEditingController ingredientsController = TextEditingController();
  TextEditingController stepsController = TextEditingController();
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with existing values
    recipeNameController.text = widget.doc["recipe_name"];
    timeRequiredController.text = widget.doc["time_required"];
    ingredientsController.text = widget.doc["ingredients"];
    stepsController.text = widget.doc["steps"];
    selectedCategory = widget.doc["category"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Edit Recipe"),
        actions: [
          IconButton(
            onPressed: () {
              // Save the edited recipe details to Firestore
              saveEditedRecipe();
              Navigator.of(context).pop(); // Close the edit screen
            },
            icon: Icon(Icons.save),
          )
        ],
      ),
      
      body:   Padding(
            padding: const EdgeInsets.all(8),
              child: Column(
                  children: [
                    SingleChildScrollView(),
                    TextField(
                      style: GoogleFonts.roboto(),
                      controller: recipeNameController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Recipe Name',
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Text(date, style: GoogleFonts.raleway(),),
                    SizedBox(height: 28,),
                    TextField(
                      style: GoogleFonts.raleway(),
                      controller: timeRequiredController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Time required',
                      ),
                    ),
                    SizedBox(height: 10.0,),
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
                    SizedBox(height: 10.0,),
                    TextField(
                      style: GoogleFonts.raleway(),
                      controller: ingredientsController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Ingredients',
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Expanded(
                        child: TextField(
                          style: GoogleFonts.raleway(),
                          controller: stepsController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Steps of recipe',
                          ),
                        ),
                      ),
                  ],
                ),
            ),

    );
  }

  // Function to save the edited recipe details
  void saveEditedRecipe() {
    // Update the recipe details in Firestore
    FirebaseFirestore.instance
        .collection('Recipenotes')
        .doc(widget.doc.id)
        .update({
      "recipe_name": recipeNameController.text,
      "category": selectedCategory,
      "time_required": timeRequiredController.text,
      "ingredients": ingredientsController.text,
      "steps": stepsController.text,
    }).then((_) {
      print("Recipe updated successfully");
    }).catchError((error) {
      print("Error updating recipe: $error");
    });
  }
}
