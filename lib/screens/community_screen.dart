import 'package:flutter/material.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String _searchQuery = '';
  String _typeFilter = 'all'; // 'all', 'user', 'vet'
  String _categoryFilter = 'all'; // 'all', 'post', 'question', 'story', etc.

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilters(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.where((doc) {
      final data = doc.data();
      final content = (data['content'] ?? '').toString().toLowerCase();
      final title = (data['title'] ?? '').toString().toLowerCase();
      final userName = (data['userName'] ?? '').toString().toLowerCase();
      final vetName = (data['vetName'] ?? '').toString().toLowerCase();
      final type = (data['type'] ?? '').toString();
      final category = (data['category'] ?? '').toString();

      final matchesSearch = content.contains(_searchQuery.toLowerCase()) ||
          title.contains(_searchQuery.toLowerCase()) ||
          userName.contains(_searchQuery.toLowerCase()) ||
          vetName.contains(_searchQuery.toLowerCase());
      final matchesType = _typeFilter == 'all' || type == _typeFilter;
      final matchesCategory =
          _categoryFilter == 'all' || category == _categoryFilter;

      return matchesSearch && matchesType && matchesCategory;
    }).toList();
  }

  void _deletePost(BuildContext context, String postId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Post'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this post?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Text(
                title.isEmpty ? 'Untitled Post' : title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
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
                await DatabaseService.deleteCommunityPost(postId);
                if (mounted) {
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Post deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error deleting post: $e'),
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

  void _viewPostDetails(
      BuildContext context, Map<String, dynamic> postData) {
    final title = postData['title'] ?? '';
    final content = postData['content'] ?? '';
    final userName = postData['userName'] ?? 'Unknown';
    final vetName = postData['vetName'] ?? '';
    final type = postData['type'] ?? 'user';
    final category = postData['category'] ?? '';
    final createdAt = postData['createdAt'];
    final userId = postData['userId'] ?? '';
    final vetId = postData['vetId'] ?? '';
    final likes = postData['likes'] ?? 0;
    final comments = postData['comments'] ?? 0;
    final imageUrl = postData['imageUrl'] ?? '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.groups, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Post Details',
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
                      if (title.isNotEmpty) ...[
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildDetailRow('Type', type == 'user' ? 'User' : 'Vet'),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Author',
                        type == 'user' ? userName : vetName,
                      ),
                      const SizedBox(height: 16),
                      if (category.isNotEmpty)
                        _buildDetailRow('Category', category),
                      if (userId.isNotEmpty)
                        _buildDetailRow('User ID', userId),
                      if (vetId.isNotEmpty) _buildDetailRow('Vet ID', vetId),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatChip(Icons.favorite, likes.toString()),
                          const SizedBox(width: 16),
                          _buildStatChip(Icons.comment, comments.toString()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (imageUrl.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.error, size: 48),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
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

  Widget _buildStatChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
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
                              'Community',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage community posts from users and vets',
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
                                      hintText: 'Search posts...',
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

                                // Category Filter
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _categoryFilter,
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                      border: InputBorder.none,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'all',
                                        child: Text('All'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'post',
                                        child: Text('Post'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'question',
                                        child: Text('Question'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'story',
                                        child: Text('Story'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'advice',
                                        child: Text('Advice'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _categoryFilter = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Posts List
                        Expanded(
                          child: Card(
                            child: StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                              stream: DatabaseService.community
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
                                      child: Text('No posts found'));
                                }
                                return ListView.builder(
                                  itemCount: filtered.length,
                                  padding: const EdgeInsets.all(16),
                                  itemBuilder: (context, index) {
                                    final doc = filtered[index];
                                    final data = doc.data();
                                    final title =
                                        (data['title'] ?? '').toString();
                                    final content =
                                        (data['content'] ?? '').toString();
                                    final userName =
                                        (data['userName'] ?? 'Unknown').toString();
                                    final vetName =
                                        (data['vetName'] ?? '').toString();
                                    final type =
                                        (data['type'] ?? 'user').toString();
                                    final category =
                                        (data['category'] ?? '').toString();
                                    final createdAt = data['createdAt'];
                                    final likes = data['likes'] ?? 0;
                                    final comments = data['comments'] ?? 0;
                                    final imageUrl =
                                        (data['imageUrl'] ?? '').toString();

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

                                    String authorName =
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
                                                      if (title.isNotEmpty)
                                                        Text(
                                                          title,
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      if (title.isEmpty)
                                                        Text(
                                                          'Untitled Post',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppTheme
                                                                .textSecondary,
                                                            fontStyle:
                                                                FontStyle.italic,
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
                                                          if (category.isNotEmpty) ...[
                                                            const SizedBox(
                                                                width: 8),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppTheme
                                                                    .borderColor
                                                                    .withOpacity(
                                                                        0.1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                              ),
                                                              child: Text(
                                                                category,
                                                                style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      AppTheme
                                                                          .textSecondary,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                          const SizedBox(
                                                              width: 8),
                                                          Text(
                                                            authorName,
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color: AppTheme
                                                                  .textSecondary,
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
                                                    _buildStatChip(
                                                        Icons.favorite, '$likes'),
                                                    const SizedBox(width: 8),
                                                    _buildStatChip(
                                                        Icons.comment,
                                                        '$comments'),
                                                  ],
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      _viewPostDetails(
                                                          context, data),
                                                  icon: const Icon(Icons.visibility),
                                                  tooltip: 'View Details',
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      _deletePost(context,
                                                          doc.id, title),
                                                  icon: const Icon(Icons.delete),
                                                  color: Colors.red,
                                                  tooltip: 'Delete',
                                                ),
                                              ],
                                            ),
                                            if (imageUrl.isNotEmpty) ...[
                                              const SizedBox(height: 12),
                                              Container(
                                                width: double.infinity,
                                                height: 200,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color:
                                                          AppTheme.borderColor),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Center(
                                                        child: Icon(Icons.error,
                                                            size: 48),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
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
                                                content.length > 200
                                                    ? '${content.substring(0, 200)}...'
                                                    : content,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
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

