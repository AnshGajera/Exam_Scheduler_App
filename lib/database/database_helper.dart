import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exam.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const String _examsKey = 'exams';
  static const String _counterKey = 'exam_counter';

  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  Future<int> insertExam(Exam exam) async {
    final prefs = await _prefs;
    final exams = await getAllExams();

    final counter = prefs.getInt(_counterKey) ?? 0;
    final newId = counter + 1;
    exam.id = newId;

    exams.add(exam);
    await prefs.setInt(_counterKey, newId);
    await _saveExams(exams);
    return newId;
  }

  Future<List<Exam>> getAllExams() async {
    final prefs = await _prefs;
    final String? examsJson = prefs.getString(_examsKey);

    if (examsJson == null) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(examsJson);
    final exams = decoded.map((e) => Exam.fromMap(e)).toList();

    exams.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.time.compareTo(b.time);
    });

    return exams;
  }

  Future<Exam?> getExam(int id) async {
    final exams = await getAllExams();
    try {
      return exams.firstWhere((exam) => exam.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<int> updateExam(Exam exam) async {
    final exams = await getAllExams();
    final index = exams.indexWhere((e) => e.id == exam.id);

    if (index != -1) {
      exams[index] = exam;
      await _saveExams(exams);
      return 1;
    }
    return 0;
  }

  Future<int> deleteExam(int id) async {
    final exams = await getAllExams();
    final initialLength = exams.length;
    exams.removeWhere((exam) => exam.id == id);

    if (exams.length < initialLength) {
      await _saveExams(exams);
      return 1;
    }
    return 0;
  }

  Future<List<Exam>> searchExams(String query) async {
    final exams = await getAllExams();
    return exams
        .where(
          (exam) => exam.courseCode.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<Exam?> getUpcomingExam(String currentDate) async {
    final exams = await getAllExams();
    final upcoming = exams
        .where((exam) => exam.date.compareTo(currentDate) >= 0)
        .toList();

    if (upcoming.isEmpty) return null;
    return upcoming.first;
  }

  Future<void> _saveExams(List<Exam> exams) async {
    final prefs = await _prefs;
    final List<Map<String, dynamic>> examMaps = exams
        .map((exam) => exam.toMap())
        .toList();
    await prefs.setString(_examsKey, jsonEncode(examMaps));
  }
}
