
class Note {
  int id = -1;
  String title = "empty";
  String description = "empty";
  String date = "empty";

  Note();

  Map<String, dynamic> toMap(Note note) {
    var map = Map<String, dynamic>();
    if(note.id != -1){
      map["id"] = note.id;
    }
    map["title"] = note.title;
    map["description"] = note.description;
    map["date"] = note.date;
    return map;
  }

  Note.fromMap(Map<String, dynamic>map){
    this.id = map["id"];
    this.title = map["title"];
    this.description = map["description"];
    this.date = map["date"];
  }
}
