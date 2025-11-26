import 'package:flutter/material.dart';
import '../models/exam.dart';

class ExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isUpcoming;

  const ExamCard({
    super.key,
    required this.exam,
    required this.onEdit,
    required this.onDelete,
    this.isUpcoming = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      elevation: 2,
      color: isUpcoming ? Colors.lightBlue.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUpcoming ? Colors.blue : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    exam.courseCode.length >= 2
                        ? exam.courseCode.substring(0, 2).toUpperCase()
                        : exam.courseCode.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.courseCode,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isUpcoming
                              ? Colors.blue.shade900
                              : Colors.black,
                        ),
                      ),
                      Text(
                        '${exam.date} at ${exam.time}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        'Venue: ${exam.venue}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            if (exam.documentPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Row(
                  children: [
                    const Icon(Icons.attachment, size: 14, color: Colors.green),
                    const SizedBox(width: 5),
                    const Text(
                      'Document attached',
                      style: TextStyle(color: Colors.green, fontSize: 11),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
