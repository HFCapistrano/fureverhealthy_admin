import 'package:flutter/material.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  String _searchQuery = '';
  String _typeFilter = 'all'; // 'all', 'user', 'vet'
  String _ratingFilter = 'all'; // 'all', '1', '2', '3', '4', '5'

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilters(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.where((doc) {
      final data = doc.data();
      final userName = (data['userName'] ?? '').toString().toLowerCase();
      final vetName = (data['vetName'] ?? '').toString().toLowerCase();
      final type = (data['type'] ?? '').toString();
      final rating = data['rating'] ?? 0;

      final matchesSearch = userName.contains(_searchQuery.toLowerCase()) ||
          vetName.contains(_searchQuery.toLowerCase());
      final matchesType = _typeFilter == 'all' || type == _typeFilter;
      final matchesRating = _ratingFilter == 'all' ||
          rating.toString() == _ratingFilter;

      return matchesSearch && matchesType && matchesRating;
    }).toList();
  }

  void _deleteRating(BuildContext context, String ratingId, String reviewerName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Rating'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete the rating from $reviewerName?'),
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
                await DatabaseService.deleteRating(ratingId);
                if (mounted) {
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Rating deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error deleting rating: $e'),
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

  void _viewRatingDetails(
      BuildContext context, Map<String, dynamic> ratingData) {
    final userName = ratingData['userName'] ?? 'Unknown';
    final vetName = ratingData['vetName'] ?? '';
    final type = ratingData['type'] ?? 'user';
    final rating = ratingData['rating'] ?? 0;
    final comment = ratingData['comment'] ?? '';
    final createdAt = ratingData['createdAt'];
    final userId = ratingData['userId'] ?? '';
    final vetId = ratingData['vetId'] ?? '';
    final ratedUserId = ratingData['ratedUserId'] ?? '';
    final ratedVetId = ratingData['ratedVetId'] ?? '';

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
                  const Icon(Icons.star, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Rating Details',
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
                        _buildDetailRow('Rated Vet', vetName),
                      if (type == 'vet' && userName.isNotEmpty)
                        _buildDetailRow('Rated User', userName),
                      if (type == 'user' && vetId.isNotEmpty)
                        _buildDetailRow('Vet ID', vetId),
                      if (type == 'vet' && userId.isNotEmpty)
                        _buildDetailRow('User ID', userId),
                      if (ratedVetId.isNotEmpty)
                        _buildDetailRow('Rated Vet ID', ratedVetId),
                      if (ratedUserId.isNotEmpty)
                        _buildDetailRow('Rated User ID', ratedUserId),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'Rating: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          ...List.generate(5, (index) {
                            return Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 24,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '$rating / 5',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (comment.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Comment:',
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
                            comment,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
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
                              'Ratings',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage ratings from users and vets',
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
                                      hintText: 'Search ratings...',
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
                                const SizedBox(width: 16),

                                // Rating Filter
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _ratingFilter,
                                    decoration: const InputDecoration(
                                      labelText: 'Rating',
                                      border: InputBorder.none,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'all',
                                        child: Text('All'),
                                      ),
                                      DropdownMenuItem(
                                        value: '5',
                                        child: Text('5 Stars'),
                                      ),
                                      DropdownMenuItem(
                                        value: '4',
                                        child: Text('4 Stars'),
                                      ),
                                      DropdownMenuItem(
                                        value: '3',
                                        child: Text('3 Stars'),
                                      ),
                                      DropdownMenuItem(
                                        value: '2',
                                        child: Text('2 Stars'),
                                      ),
                                      DropdownMenuItem(
                                        value: '1',
                                        child: Text('1 Star'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _ratingFilter = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Ratings List
                        Expanded(
                          child: Card(
                            child: StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                              stream: DatabaseService.ratings
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
                                      child: Text('No ratings found'));
                                }
                                return ListView.builder(
                                  itemCount: filtered.length,
                                  padding: const EdgeInsets.all(16),
                                  itemBuilder: (context, index) {
                                    final doc = filtered[index];
                                    final data = doc.data();
                                    final userName =
                                        (data['userName'] ?? 'Unknown').toString();
                                    final vetName =
                                        (data['vetName'] ?? '').toString();
                                    final type =
                                        (data['type'] ?? 'user').toString();
                                    final rating = data['rating'] ?? 0;
                                    final comment =
                                        (data['comment'] ?? '').toString();
                                    final createdAt = data['createdAt'];

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

                                    String reviewerName =
                                        type == 'user' ? userName : vetName;

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
                                                        reviewerName,
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
                                                Row(
                                                  children: [
                                                    ...List.generate(5, (index) {
                                                      return Icon(
                                                        index < rating
                                                            ? Icons.star
                                                            : Icons
                                                                .star_border,
                                                        color: Colors.amber,
                                                        size: 20,
                                                      );
                                                    }),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '$rating / 5',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      _viewRatingDetails(
                                                          context, data),
                                                  icon: const Icon(Icons.visibility),
                                                  tooltip: 'View Details',
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      _deleteRating(context,
                                                          doc.id, reviewerName),
                                                  icon: const Icon(Icons.delete),
                                                  color: Colors.red,
                                                  tooltip: 'Delete',
                                                ),
                                              ],
                                            ),
                                            if (comment.isNotEmpty) ...[
                                              const SizedBox(height: 12),
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.backgroundColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color:
                                                          AppTheme.borderColor),
                                                ),
                                                child: Text(
                                                  comment,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
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

