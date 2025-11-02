import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:furever_healthy_admin/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContentEditorScreen extends StatefulWidget {
  final String? contentId;
  
  const ContentEditorScreen({super.key, this.contentId});

  @override
  State<ContentEditorScreen> createState() => _ContentEditorScreenState();
}

class _ContentEditorScreenState extends State<ContentEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _excerptController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  
  String _category = 'article';
  String _status = 'draft';
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    if (widget.contentId != null) {
      _loadContent();
    } else {
      _isLoadingData = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _excerptController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    try {
      final doc = await DatabaseService.getContent(widget.contentId!);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _titleController.text = data['title'] ?? '';
          _excerptController.text = data['excerpt'] ?? '';
          _contentController.text = data['content'] ?? '';
          _tagsController.text = (data['tags'] as List?)?.join(', ') ?? '';
          _category = data['category'] ?? 'article';
          _status = data['status'] ?? 'draft';
          _isLoadingData = false;
        });
      } else {
        setState(() => _isLoadingData = false);
      }
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading content: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveContent({bool publish = false}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tagsList = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final contentData = {
        'title': _titleController.text.trim(),
        'excerpt': _excerptController.text.trim(),
        'content': _contentController.text.trim(),
        'category': _category,
        'status': publish ? 'published' : _status,
        'tags': tagsList,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': authProvider.userEmail ?? 'admin',
      };

      if (widget.contentId == null) {
        // Create new content
        contentData['createdAt'] = FieldValue.serverTimestamp();
        contentData['createdBy'] = authProvider.userEmail ?? 'admin';
        await DatabaseService.createContent(contentData);
      } else {
        // Update existing content
        await DatabaseService.updateContent(widget.contentId!, contentData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              publish
                  ? 'Content published successfully'
                  : widget.contentId == null
                      ? 'Content created successfully'
                      : 'Content saved successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/contents');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving content: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: _isLoadingData
                ? const Center(child: CircularProgressIndicator())
                : Column(
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
                                    widget.contentId == null
                                        ? 'Create New Content'
                                        : 'Edit Content',
                                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Create and manage educational content',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => context.go('/contents'),
                              icon: const Icon(Icons.close),
                              label: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : () => _saveContent(publish: false),
                              icon: const Icon(Icons.save),
                              label: const Text('Save Draft'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () => _saveContent(publish: true),
                              icon: const Icon(Icons.publish),
                              label: const Text('Publish'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content Form
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                TextFormField(
                                  controller: _titleController,
                                  decoration: const InputDecoration(
                                    labelText: 'Title *',
                                    hintText: 'Enter content title',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.title),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a title';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Category and Status Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _category,
                                        decoration: const InputDecoration(
                                          labelText: 'Category *',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.category),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'breed_guide',
                                            child: Text('Breed Guide'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'article',
                                            child: Text('Article'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'tip',
                                            child: Text('Tip'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'faq',
                                            child: Text('FAQ'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _category = value!;
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _status,
                                        decoration: const InputDecoration(
                                          labelText: 'Status',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.flag),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'draft',
                                            child: Text('Draft'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'published',
                                            child: Text('Published'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _status = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Excerpt
                                TextFormField(
                                  controller: _excerptController,
                                  decoration: const InputDecoration(
                                    labelText: 'Excerpt',
                                    hintText: 'Short summary or preview text',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.short_text),
                                  ),
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 24),

                                // Tags
                                TextFormField(
                                  controller: _tagsController,
                                  decoration: const InputDecoration(
                                    labelText: 'Tags',
                                    hintText: 'Separate tags with commas (e.g., health, care, training)',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.label),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Content
                                TextFormField(
                                  controller: _contentController,
                                  decoration: const InputDecoration(
                                    labelText: 'Content *',
                                    hintText: 'Enter the main content body',
                                    border: OutlineInputBorder(),
                                    alignLabelWithHint: true,
                                  ),
                                  maxLines: 20,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter content';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Preview Section
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.preview, color: AppTheme.primaryColor),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Preview',
                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        if (_titleController.text.isNotEmpty) ...[
                                          Text(
                                            _titleController.text,
                                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                        ],
                                        if (_excerptController.text.isNotEmpty) ...[
                                          Text(
                                            _excerptController.text,
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                  color: AppTheme.textSecondary,
                                                ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                        if (_contentController.text.isNotEmpty)
                                          Text(
                                            _contentController.text,
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
