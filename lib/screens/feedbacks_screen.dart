import 'package:flutter/material.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbacksScreen extends StatefulWidget {
  const FeedbacksScreen({super.key});

  @override
  State<FeedbacksScreen> createState() => _FeedbacksScreenState();
}

class _FeedbacksScreenState extends State<FeedbacksScreen> {
  String _searchQuery = '';
  String _typeFilter = 'all'; // 'all', 'user', 'vet'

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilters(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.where((doc) {
      final data = doc.data();
      final content = (data['content'] ?? '').toString().toLowerCase();
      final userName = (data['userName'] ?? '').toString().toLowerCase();
      final vetName = (data['vetName'] ?? '').toString().toLowerCase();
      final type = (data['type'] ?? '').toString();

      final matchesSearch = content.contains(_searchQuery.toLowerCase()) ||
          userName.contains(_searchQuery.toLowerCase()) ||
          vetName.contains(_searchQuery.toLowerCase());
      final matchesType = _typeFilter == 'all' || type == _typeFilter;

      return matchesSearch && matchesType;
    }).toList();
  }

  void _deleteFeedback(BuildContext context, String feedbackId, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Feedback'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this feedback?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Text(
                content.length > 100 ? '${content.substring(0, 100)}...' : content,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                await DatabaseService.deleteFeedback(feedbackId);
                if (mounted) {
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Feedback deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error deleting feedback: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _viewFeedbackDetails(
      BuildContext context, Map<String, dynamic> feedbackData) {
    final content = feedbackData['content'] ?? '';
    final userName = feedbackData['userName'] ?? 'Unknown';
    final vetName = feedbackData['vetName'] ?? '';
    final type = feedbackData['type'] ?? 'user';
    final createdAt = feedbackData['createdAt'];
    final userId = feedbackData['userId'] ?? '';
    final vetId = feedbackData['vetId'] ?? '';
    final rating = feedbackData['rating'] ?? 0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.feedback, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Feedback Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Type', type == 'user' ? 'User' : 'Vet'),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'From',
                        type == 'user' ? userName : vetName,
                      ),
                      const SizedBox(height: 16),
                      if (type == 'user' && vetName.isNotEmpty)
                        _buildDetailRow('To (Vet)', vetName),
                      if (type == 'vet' && userName.isNotEmpty)
                        _buildDetailRow('To (User)', userName),
                      if (type == 'user' && vetId.isNotEmpty)
                        _buildDetailRow('Vet ID', vetId),
                      if (type == 'vet' && userId.isNotEmpty)
                        _buildDetailRow('User ID', userId),
                      const SizedBox(height: 16),
                      if (rating > 0)
                        Row(
                          children: [
                            const Text(
                              'Rating: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            ...List.generate(5, (index) {
                              return Icon(
                                index < rating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            }),
                          ],
                        ),
                      const SizedBox(height: 16),
                      const Text(
                        'Content:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: Text(
                          content,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (createdAt != null)
                        _buildDetailRow(
                          'Created At',
                          createdAt is Timestamp
                              ? createdAt.toDate().toString()
                              : createdAt.toString(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceColor,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Feedbacks',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage feedback from users and vets',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filters and Search
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Search
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Search feedbacks...',
                                      prefixIcon: Icon(Icons.search),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Type Filter
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _typeFilter,
                                    decoration: const InputDecoration(
                                      labelText: 'Type',
                                      border: InputBorder.none,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'all',
                                        child: Text('All'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'user',
                                        child: Text('From Users'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'vet',
                                        child: Text('From Vets'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _typeFilter = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Feedbacks List
                        Expanded(
                          child: Card(
                            child: StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                              stream: DatabaseService.feedbacks
                                  .orderBy('createdAt', descending: true)
                                  .withConverter<Map<String, dynamic>>(
                                    fromFirestore: (snap, _) =>
                                        snap.data() ?? <String, dynamic>{},
                                    toFirestore: (value, _) => value,
                                  )
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }
                                final docs = snapshot.data?.docs ?? [];
                                final filtered = _applyFilters(docs);
                                if (filtered.isEmpty) {
                                  return const Center(
                                      child: Text('No feedbacks found'));
                                }
                                return ListView.builder(
                                  itemCount: filtered.length,
                                  padding: const EdgeInsets.all(16),
                                  itemBuilder: (context, index) {
                                    final doc = filtered[index];
                                    final data = doc.data();
                                    final content =
                                        (data['content'] ?? '').toString();
                                    final userName =
                                        (data['userName'] ?? 'Unknown').toString();
                                    final vetName =
                                        (data['vetName'] ?? '').toString();
                                    final type =
                                        (data['type'] ?? 'user').toString();
                                    final createdAt = data['createdAt'];
                                    final rating = data['rating'] ?? 0;

                                    String createdAtStr = 'Unknown';
                                    if (createdAt != null) {
                                      if (createdAt is Timestamp) {
                                        createdAtStr = createdAt
                                            .toDate()
                                            .toString()
                                            .substring(0, 16);
                                      } else {
                                        createdAtStr = createdAt.toString();
                                      }
                                    }

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor: type == 'user'
                                                      ? AppTheme.primaryColor
                                                          .withOpacity(0.1)
                                                      : AppTheme.successColor
                                                          .withOpacity(0.1),
                                                  child: Icon(
                                                    type == 'user'
                                                        ? Icons.person
                                                        : Icons
                                                            .medical_services,
                                                    color: type == 'user'
                                                        ? AppTheme.primaryColor
                                                        : AppTheme.successColor,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        type == 'user'
                                                            ? userName
                                                            : vetName,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical: 4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: type ==
                                                                      'user'
                                                                  ? AppTheme
                                                                      .primaryColor
                                                                      .withOpacity(
                                                                          0.1)
                                                                  : AppTheme
                                                                      .successColor
                                                                      .withOpacity(
                                                                          0.1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                            child: Text(
                                                              type == 'user'
                                                                  ? 'User'
                                                                  : 'Vet',
                                                              style: TextStyle(
                                                                color: type ==
                                                                        'user'
                                                                    ? AppTheme
                                                                        .primaryColor
                                                                    : AppTheme
                                                                        .successColor,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Text(
                                                            createdAtStr,
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color: AppTheme
                                                                  .textSecondary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (rating > 0)
                                                  Row(
                                                    children: [
                                                      ...List.generate(5,
                                                          (index) {
                                                        return Icon(
                                                          index < rating
                                                              ? Icons.star
                                                              : Icons
                                                                  .star_border,
                                                          color: Colors.amber,
                                                          size: 16,
                                                        );
                                                      }),
                                                    ],
                                                  ),
                                                IconButton(
                                                  onPressed: () =>
                                                      _viewFeedbackDetails(
                                                          context, data),
                                                  icon: const Icon(Icons.visibility),
                                                  tooltip: 'View Details',
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      _deleteFeedback(context,
                                                          doc.id, content),
                                                  icon: const Icon(Icons.delete),
                                                  color: Colors.red,
                                                  tooltip: 'Delete',
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: AppTheme.backgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: AppTheme.borderColor),
                                              ),
                                              child: Text(
                                                content,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

