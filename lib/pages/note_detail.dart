import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../utils/data_base_helper.dart';

class NoteDetail extends StatefulWidget {
  final String action;
  final Note note;

  const NoteDetail(this.note, this.action);

  @override
  State<NoteDetail> createState() => _NoteDetailState(note, action);
}

class _NoteDetailState extends State<NoteDetail> {
  final String action;
  final Note note;

  _NoteDetailState(this.note, this.action);

  DatabaseHelper databaseHelper = DatabaseHelper();

  final TextStyle _textStyle =
      const TextStyle(color: Colors.black, fontSize: 16);
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if(note.id != -1){
      titleController.text = note.title;
      descriptionController.text = note.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(action),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: TextField(
                controller: titleController,
                style: _textStyle,
                decoration: InputDecoration(
                    labelText: "Title",
                    labelStyle: _textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )),
                onChanged: (value) {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: TextField(
                controller: descriptionController,
                style: _textStyle,
                decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: _textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )),
                onChanged: (value) {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        child: Text(
                          action,
                        ),
                        onPressed: () {
                          setState(() {
                            getValues();
                          });
                        },
                      )),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        child: const Text(
                          "Delete",
                        ),
                        onPressed: () {
                          setState(() {
                            delete();
                          });
                        },
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void getValues() {
    String title = titleController.text;
    if (title.isEmpty) {
      showAlertDialog(
          Icon(
            Icons.error,
            color: Colors.red,
          ),
          "Error",
          "Title of the note can't me empty");
    } else {
      note.title = title;
      note.description = descriptionController.text;
      save();
    }
  }

  void delete()async{
    if(note.id != -1){
      await databaseHelper.deleteNote(note.id);
      Navigator.pop(context);
    }
  }

  void save() async {
    note.date = currentDate();
    int result = note.id != -1
        ? await databaseHelper.updateNote(note)
        : await databaseHelper.insertNote(note);
    result == 0
        ? showAlertDialog(
            Icon(
              Icons.error,
              color: Colors.red,
            ),
            "Status",
            "Problem in saving note")
        : showAlertDialog(
            Icon(
              Icons.done,
              color: Colors.green,
            ),
            "Status",
            "The note saved successfully");
  }

  String currentDate(){
    DateTime currentDate = DateTime.now();
    return DateFormat('dd MMMM yyyy').format(currentDate);
  }

  void showAlertDialog(Icon icon, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              icon,
              SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
