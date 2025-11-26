import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/exam.dart';
import '../widgets/exam_card.dart';
import 'exam_form_screen.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Exam> _exams = [];
  List<Exam> _filteredExams = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  Exam? _nextExam;
  int _days = 0;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExams() async {
    setState(() => _isLoading = true);
    final exams = await _dbHelper.getAllExams();
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final upcoming = await _dbHelper.getUpcomingExam(currentDate);

    if (upcoming != null) {
      final examDate = DateFormat('yyyy-MM-dd').parse(upcoming.date);
      final today = DateTime.now();
      _days = examDate.difference(today).inDays;
    }

    setState(() {
      _exams = exams;
      _filteredExams = exams;
      _nextExam = upcoming;
      _isLoading = false;
    });
  }

  void _searchExams(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredExams = _exams;
      });
    } else {
      setState(() {
        _filteredExams = _exams
            .where(
              (exam) =>
                  exam.courseCode.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      });
    }
  }

  Future<void> _deleteExam(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam'),
        content: const Text('Are you sure you want to delete this exam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbHelper.deleteExam(id);
      _loadExams();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Exam deleted')));
    }
  }

  void _navigateToForm({Exam? exam}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExamFormScreen(exam: exam)),
    );
    _loadExams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Timetable'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (_nextExam != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade100,
              child: Column(
                children: [
                  Text(
                    _days == 0
                        ? '⚠️ Exam Today!'
                        : '⏰ Next Exam in $_days ${_days == 1 ? 'day' : 'days'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_nextExam!.courseCode} - ${_nextExam!.venue}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchExams,
              decoration: InputDecoration(
                hintText: 'Search course code...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchExams('');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total: ${_filteredExams.length} ${_filteredExams.length == 1 ? 'exam' : 'exams'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExams.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No exams yet'
                              : 'No results',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredExams.length,
                    itemBuilder: (context, index) {
                      final exam = _filteredExams[index];
                      final isUpcoming = _nextExam?.id == exam.id;
                      return ExamCard(
                        exam: exam,
                        isUpcoming: isUpcoming,
                        onEdit: () => _navigateToForm(exam: exam),
                        onDelete: () => _deleteExam(exam.id!),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
