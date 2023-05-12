import 'package:flutter/material.dart';
import 'package:note_app_flutter/pages/note_detail.dart';
import 'package:note_app_flutter/utils/data_base_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:note_app_flutter/models/note.dart';

class NoteList extends StatefulWidget {
  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList =  <Note>[];
  int count = 0;

  void updateNotes() async{
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList_){
        setState(() {
          noteList = noteList_;
          count = noteList.length;
        });
      });
    });

  }

  @override
  void initState() {
    super.initState();
    updateNotes();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        centerTitle: true,
      ),
      body: count == 0 ? buildImage() : buildListView(),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Note",
        child: const Icon(Icons.add),
        onPressed: () {
          navigateToListDetail(Note(),"Add");
        },
      ),
    );
  }

  Widget buildImage(){
    return Center(
      child: Container(
        padding: EdgeInsets.all(15),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SvgPicture.asset(
              'assets/empty.svg',
              width: 230,
              height: 230,
            ),
            Text("No notes", style: TextStyle(fontSize: 20,color: Colors.black, fontWeight: FontWeight.bold),)
          ],
        ),

      ),
    );
  }

  ListView buildListView() {
    TextStyle titleStyle = TextStyle(
        color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold);
    return ListView.builder(
      physics:  BouncingScrollPhysics(),
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading:  CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.article_outlined, color: Colors.white,),
            ),
            title: Text(
              noteList[position].title,
              style: titleStyle,
            ),
            subtitle: Text(noteList[position].date,),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.grey,),
              onPressed: (){
                _delete(context, noteList[position]);
              }

//showAlertDialog(context,noteList[position]),
            ),
            onTap: () => navigateToListDetail(noteList[position],"Edit"),
          ),
        );
      },
    );
  }

  void showAlertDialog(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red,),
              SizedBox(width: 8),
              Text("Warning"),
            ],
          ),
          content: Text("Are you sure that you want to delete this note?"),
          actions: [
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void navigateToListDetail(Note note,String action) async{
    var route =
        MaterialPageRoute(builder: (context) => NoteDetail(note,action));
    await Navigator.push(context, route).then((v){
      updateNotes();
    });
  }

  void _delete(BuildContext context, Note note) async{
    debugPrint("delete function");
    int result = await databaseHelper.deleteNote(note.id);
    if(result != 0){
      _showSnackBar(context,"Note deleted successfully");
      updateNotes();
    }else{
      _showSnackBar(context,"Problem occupied in deleting the note");
      updateNotes();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }



}
