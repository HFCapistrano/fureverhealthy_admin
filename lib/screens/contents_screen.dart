import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ContentsScreen extends StatefulWidget {
  const ContentsScreen({super.key});

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen> {
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'draft', 'published'
  String _categoryFilter = 'all'; // 'all', 'breed_guide', 'article', 'tip', 'faq'
  String _sortBy = 'updatedAt'; // 'updatedAt', 'createdAt', 'title'

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilters(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.where((doc) {
      final data = doc.data();
      final title = (data['title'] ?? '').toString().toLowerCase();
      final content = (data['content'] ?? '').toString().toLowerCase();
      final category = (data['category'] ?? 'article').toString();
      final status = (data['status'] ?? 'draft').toString();

      final matchesSearch = title.contains(_searchQuery.toLowerCase()) ||
          content.contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'all' || status == _statusFilter;
      final matchesCategory = _categoryFilter == 'all' || category == _categoryFilter;

      return matchesSearch && matchesStatus && matchesCategory;
    }).toList();
  }

  void _deleteContent(BuildContext context, String contentId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Content'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this content?'),
            const SizedBox(height: 16),
            if (title.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Text(
                  title.length > 100 ? '${title.substring(0, 100)}...' : title,
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
                await DatabaseService.deleteContent(contentId);
                if (mounted) {
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Content deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error deleting content: $e'),
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
                              'Content Management',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage educational content, breed guides, and articles',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/contents/new'),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Content'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filters
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceColor,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
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
                            hintText: 'Search content...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Status Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _statusFilter,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Status')),
                            DropdownMenuItem(value: 'draft', child: Text('Draft')),
                            DropdownMenuItem(value: 'published', child: Text('Published')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _statusFilter = value!;
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
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Categories')),
                            DropdownMenuItem(value: 'breed_guide', child: Text('Breed Guide')),
                            DropdownMenuItem(value: 'article', child: Text('Article')),
                            DropdownMenuItem(value: 'tip', child: Text('Tip')),
                            DropdownMenuItem(value: 'faq', child: Text('FAQ')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _categoryFilter = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Sort By
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _sortBy,
                          decoration: const InputDecoration(
                            labelText: 'Sort By',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'updatedAt', child: Text('Last Updated')),
                            DropdownMenuItem(value: 'createdAt', child: Text('Created Date')),
                            DropdownMenuItem(value: 'title', child: Text('Title')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _sortBy = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Content List
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.all(24),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: DatabaseService.getContentsStream(_sortBy),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        final docs = snapshot.data?.docs ?? <DocumentSnapshot>[];
                        final typedDocs = docs
                            .whereType<QueryDocumentSnapshot<Map<String, dynamic>>>()
                            .toList();
                        final filtered = _applyFilters(typedDocs);

                        if (filtered.isEmpty) {
                          return const Center(
                              child: Text('No content found'));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final doc = filtered[index];
                            final data = doc.data();
                            final title = (data['title'] ?? 'Untitled').toString();
                            final category = (data['category'] ?? 'article').toString();
                            final status = (data['status'] ?? 'draft').toString();
                            final updatedAt = data['updatedAt'] ?? data['createdAt'];
                            final excerpt = (data['excerpt'] ?? '').toString();
                            final content = (data['content'] ?? '').toString();
                            final contentExcerpt = excerpt.isEmpty && content.isNotEmpty
                                ? content.length > 150
                                    ? '${content.substring(0, 150)}...'
                                    : content
                                : excerpt;

                            String updatedAtStr = 'Unknown';
                            if (updatedAt != null) {
                              if (updatedAt is Timestamp) {
                                updatedAtStr = DateFormat('MMM d, yyyy h:mm a').format(updatedAt.toDate());
                              } else {
                                updatedAtStr = updatedAt.toString();
                              }
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => context.go('/contents/${doc.id}/edit'),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: status == 'published'
                                                            ? Colors.green.withOpacity(0.1)
                                                            : Colors.orange.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        status.toUpperCase(),
                                                        style: TextStyle(
                                                          color: status == 'published'
                                                              ? Colors.green
                                                              : Colors.orange,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme.primaryColor.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        _getCategoryLabel(category),
                                                        style: const TextStyle(
                                                          color: AppTheme.primaryColor,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  title,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert),
                                            onSelected: (value) {
                                              switch (value) {
                                                case 'edit':
                                                  context.go('/contents/${doc.id}/edit');
                                                  break;
                                                case 'delete':
                                                  _deleteContent(context, doc.id, title);
                                                  break;
                                                case 'toggle_publish':
                                                  DatabaseService.updateContentStatus(
                                                    doc.id,
                                                    status == 'published' ? 'draft' : 'published',
                                                  );
                                                  break;
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 18),
                                                    SizedBox(width: 8),
                                                    Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'toggle_publish',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      status == 'published'
                                                          ? Icons.unpublished
                                                          : Icons.publish,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(status == 'published' ? 'Unpublish' : 'Publish'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete, color: Colors.red, size: 18),
                                                    SizedBox(width: 8),
                                                    Text('Delete'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (contentExcerpt.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          contentExcerpt,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.textSecondary,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Updated: $updatedAtStr',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
        ],
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'breed_guide':
        return 'Breed Guide';
      case 'article':
        return 'Article';
      case 'tip':
        return 'Tip';
      case 'faq':
        return 'FAQ';
      default:
        return category;
    }
  }
}
