import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HealthRecordDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> record;

  const HealthRecordDetailsScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Record Details'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: 'General Information',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                      'Cattle', 'Tag #${record['cattleId']['tag_number']}'),
                  _buildInfoRow('Type', record['type']),
                  _buildInfoRow(
                      'Date',
                      DateFormat('MMM d, yyyy')
                          .format(DateTime.parse(record['date']))),
                  _buildInfoRow('Veterinarian',
                      record['veterinarian'] ?? 'Not specified'),
                  _buildInfoRow(
                      'Cost',
                      record['cost'] != null
                          ? '\$${record['cost'].toStringAsFixed(2)}'
                          : 'Not specified'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Description',
              content: Text(record['description']),
            ),
            if (record['medicines'] != null &&
                (record['medicines'] as List).isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Medicines',
                content: Column(
                  children: [
                    for (var medicine in record['medicines'])
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicine['name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (medicine['dosage'] != null)
                              Text('Dosage: ${medicine['dosage']}'),
                            if (medicine['duration'] != null)
                              Text('Duration: ${medicine['duration']}'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (record['nextCheckupDate'] != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Next Checkup',
                content: Text(
                  DateFormat('MMM d, yyyy')
                      .format(DateTime.parse(record['nextCheckupDate'])),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget content}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
