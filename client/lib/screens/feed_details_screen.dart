import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> feed;

  const FeedDetailsScreen({
    super.key,
    required this.feed,
  });

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Fodder':
        return Colors.green;
      case 'Concentrate':
        return Colors.orange;
      case 'Mineral':
        return Colors.blue;
      case 'Supplement':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Fodder':
        return Icons.grass;
      case 'Concentrate':
        return Icons.grain;
      case 'Mineral':
        return Icons.science;
      case 'Supplement':
        return Icons.medication;
      default:
        return Icons.category;
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat.yMMMd().format(date) : 'Not set';
  }

  @override
  Widget build(BuildContext context) {
    final isLowStock = feed['quantity'] <= feed['stockAlert'];
    final DateTime? expiryDate =
        feed['expiryDate'] != null ? DateTime.parse(feed['expiryDate']) : null;
    final DateTime createdAt = DateTime.parse(feed['createdAt']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed Details'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: _getTypeColor(feed['type']).withOpacity(0.1),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _getTypeColor(feed['type']),
                    child: Icon(
                      _getTypeIcon(feed['type']),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feed['name'],
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          feed['type'],
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    _buildInfoRow(
                      'Current Stock',
                      '${feed['quantity']} ${feed['unit']}',
                      Icons.inventory_2,
                    ),
                    if (isLowStock)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber,
                                color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Low Stock Alert: Below threshold of ${feed['stockAlert']} ${feed['unit']}',
                                style: const TextStyle(color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildInfoRow(
                      'Cost per Unit',
                      '\$${feed['cost'].toStringAsFixed(2)}',
                      Icons.attach_money,
                    ),
                    _buildInfoRow(
                      'Total Value',
                      '\$${(feed['quantity'] * feed['cost']).toStringAsFixed(2)}',
                      Icons.calculate,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    if (feed['supplier']?.isNotEmpty ?? false)
                      _buildInfoRow(
                        'Supplier',
                        feed['supplier'],
                        Icons.supervisor_account,
                      ),
                    _buildInfoRow(
                      'Expiry Date',
                      _formatDate(expiryDate),
                      Icons.calendar_today,
                    ),
                    _buildInfoRow(
                      'Added On',
                      _formatDate(createdAt),
                      Icons.calendar_today,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
