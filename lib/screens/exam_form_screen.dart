import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../database/database_helper.dart';
import '../models/exam.dart';

class ExamFormScreen extends StatefulWidget {
  final Exam? exam;

  const ExamFormScreen({super.key, this.exam});

  @override
  State<ExamFormScreen> createState() => _ExamFormScreenState();
}

class _ExamFormScreenState extends State<ExamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseController = TextEditingController();
  final _venueController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  String _selectedDate = '';
  String _selectedTime = '';
  String? _filePath;

  bool get isEditing => widget.exam != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _courseController.text = widget.exam!.courseCode;
      _venueController.text = widget.exam!.venue;
      _selectedDate = widget.exam!.date;
      _selectedTime = widget.exam!.time;
      _filePath = widget.exam!.documentPath;
    }
  }

  @override
  void dispose() {
    _courseController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(_selectedDate)
          : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime.isNotEmpty
          ? TimeOfDay(
              hour: int.parse(_selectedTime.split(':')[0]),
              minute: int.parse(_selectedTime.split(':')[1]),
            )
          : TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File selected: ${result.files.single.name}')),
      );
    }
  }

  Future<void> _saveExam() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }

    if (_selectedTime.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a time')));
      return;
    }

    final exam = Exam(
      id: widget.exam?.id,
      courseCode: _courseController.text,
      date: _selectedDate,
      time: _selectedTime,
      venue: _venueController.text,
      documentPath: _filePath,
    );

    if (isEditing) {
      await _dbHelper.updateExam(exam);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Exam updated')));
    } else {
      await _dbHelper.insertExam(exam);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Exam added')));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Exam' : 'Add New Exam'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(
                  labelText: 'Course Code',
                  hintText: 'e.g. CS101',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter course code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Exam Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedDate.isEmpty
                        ? 'Click to select date'
                        : DateFormat('dd/MM/yyyy').format(
                            DateFormat('yyyy-MM-dd').parse(_selectedDate),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: _pickTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Exam Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedTime.isEmpty
                        ? 'Click to select time'
                        : _selectedTime,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(
                  labelText: 'Venue/Room',
                  hintText: 'e.g. Room 101',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter venue';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: _pickDocument,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  _filePath == null ? 'Upload Document' : 'File Attached ✓',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: _filePath == null
                      ? Colors.grey
                      : Colors.green,
                ),
              ),
              if (_filePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.attachment, size: 16),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _filePath!.split('/').last,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => setState(() => _filePath = null),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _saveExam,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(
                    isEditing ? 'UPDATE' : 'SAVE',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
