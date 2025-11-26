class Exam {
  int? id;
  String courseCode;
  String date;
  String time;
  String venue;
  String? documentPath;

  Exam({
    this.id,
    required this.courseCode,
    required this.date,
    required this.time,
    required this.venue,
    this.documentPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseCode': courseCode,
      'date': date,
      'time': time,
      'venue': venue,
      'documentPath': documentPath,
    };
  }

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'],
      courseCode: map['courseCode'],
      date: map['date'],
      time: map['time'],
      venue: map['venue'],
      documentPath: map['documentPath'],
    );
  }
}
