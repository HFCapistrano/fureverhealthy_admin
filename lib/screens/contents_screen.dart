import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:furever_healthy_admin/providers/auth_provider.dart';
import 'package:provider/provider.dart';
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

                // Notification Management
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceColor,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Notification Management',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showNotificationComposer(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Compose Announcement'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showBreedTipsComposer(context),
                            icon: const Icon(Icons.tips_and_updates),
                            label: const Text('Compose Breed-Specific Tips'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showMaintenanceNoticeComposer(context),
                            icon: const Icon(Icons.build),
                            label: const Text('Create Maintenance Notice'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                          ),
                        ],
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

  void _showNotificationComposer(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String targetAudience = 'all';
    DateTime? scheduledDate;
    bool sendNow = true;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Compose Announcement',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: targetAudience,
                  decoration: const InputDecoration(
                    labelText: 'Target Audience',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Users')),
                    DropdownMenuItem(value: 'premium', child: Text('Premium Users')),
                  ],
                  onChanged: (value) => targetAudience = value!,
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setDialogState) => CheckboxListTile(
                    title: const Text('Send Now'),
                    value: sendNow,
                    onChanged: (value) => setDialogState(() => sendNow = value ?? true),
                  ),
                ),
                StatefulBuilder(
                  builder: (context, setDialogState) {
                    return sendNow
                        ? const SizedBox.shrink()
                        : Column(
                            children: [
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (date != null) {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (time != null) {
                                      setDialogState(() {
                                        scheduledDate = DateTime(
                                          date.year,
                                          date.month,
                                          date.day,
                                          time.hour,
                                          time.minute,
                                        );
                                      });
                                    }
                                  }
                                },
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  scheduledDate != null
                                      ? DateFormat('MMM d, yyyy h:mm a').format(scheduledDate!)
                                      : 'Schedule Date & Time',
                                ),
                              ),
                            ],
                          );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (titleController.text.isEmpty || contentController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all required fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          await DatabaseService.createNotification({
                            'title': titleController.text,
                            'content': contentController.text,
                            'type': 'announcement',
                            'targetAudience': targetAudience,
                            'status': sendNow ? 'sent' : 'scheduled',
                            'scheduledDate': scheduledDate != null
                                ? Timestamp.fromDate(scheduledDate!)
                                : null,
                            'createdBy': authProvider.userEmail ?? 'admin',
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Announcement created successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error creating announcement: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBreedTipsComposer(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedBreed = '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tips_and_updates, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Compose Breed-Specific Tips',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content/Tips *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Breed Key (optional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => selectedBreed = value,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (titleController.text.isEmpty || contentController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all required fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          await DatabaseService.createNotification({
                            'title': titleController.text,
                            'content': contentController.text,
                            'type': 'breed_tips',
                            'breedKey': selectedBreed,
                            'status': 'sent',
                            'createdBy': authProvider.userEmail ?? 'admin',
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Breed tips created successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error creating breed tips: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMaintenanceNoticeComposer(BuildContext context) {
    final titleController = TextEditingController(text: 'System Maintenance');
    final contentController = TextEditingController();
    DateTime? maintenanceStart;
    DateTime? maintenanceEnd;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          constraints: const BoxConstraints(maxWidth: 700),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.build, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Create Maintenance Notice',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Maintenance Details *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                maintenanceStart = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          maintenanceStart != null
                              ? 'Start: ${DateFormat('MMM d, h:mm a').format(maintenanceStart!)}'
                              : 'Start Time',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                maintenanceEnd = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          maintenanceEnd != null
                              ? 'End: ${DateFormat('MMM d, h:mm a').format(maintenanceEnd!)}'
                              : 'End Time',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (contentController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in maintenance details'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          await DatabaseService.createNotification({
                            'title': titleController.text,
                            'content': contentController.text,
                            'type': 'maintenance',
                            'maintenanceStart': maintenanceStart != null
                                ? Timestamp.fromDate(maintenanceStart!)
                                : null,
                            'maintenanceEnd': maintenanceEnd != null
                                ? Timestamp.fromDate(maintenanceEnd!)
                                : null,
                            'status': 'sent',
                            'createdBy': authProvider.userEmail ?? 'admin',
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Maintenance notice created successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error creating maintenance notice: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
