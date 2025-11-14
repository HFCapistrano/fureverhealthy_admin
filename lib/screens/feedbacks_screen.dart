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
  String _categoryFilter = 'all';
  String _severityFilter = 'all';
  String _statusFilter = 'all';
  String? _assignedToFilter;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFilters(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.where((doc) {
      final data = doc.data();
      final content = (data['content'] ?? '').toString().toLowerCase();
      final userName = (data['userName'] ?? '').toString().toLowerCase();
      final vetName = (data['vetName'] ?? '').toString().toLowerCase();
      final type = (data['type'] ?? '').toString();
      
      // Triage fields
      final category = (data['category'] ?? '').toString();
      final severity = (data['severity'] ?? '').toString();
      final status = (data['status'] ?? 'new').toString();
      final assignedTo = (data['assignedTo'] ?? '').toString();

      final matchesSearch = content.contains(_searchQuery.toLowerCase()) ||
          userName.contains(_searchQuery.toLowerCase()) ||
          vetName.contains(_searchQuery.toLowerCase());
      final matchesType = _typeFilter == 'all' || type == _typeFilter;
      final matchesCategory = _categoryFilter == 'all' || category == _categoryFilter;
      final matchesSeverity = _severityFilter == 'all' || severity == _severityFilter;
      final matchesStatus = _statusFilter == 'all' || status == _statusFilter;
      final matchesAssignedTo = _assignedToFilter == null || assignedTo == _assignedToFilter;

      return matchesSearch && matchesType && 
             matchesCategory && matchesSeverity && matchesStatus && matchesAssignedTo;
    }).toList();
  }

  void _deleteFeedback(BuildContext context, String itemId, String content) {
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
            if (content.isNotEmpty)
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
                await DatabaseService.deleteFeedback(itemId);
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
                      if (content.isNotEmpty) ...[
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

  Widget _buildTriageChip(String label, String value) {
    Color chipColor = AppTheme.primaryColor;
    if (label == 'Severity') {
      if (value == 'critical') {
        chipColor = Colors.red;
      } else if (value == 'high') chipColor = Colors.orange;
      else if (value == 'medium') chipColor = Colors.yellow.shade700;
      else chipColor = Colors.green;
    } else if (label == 'Status') {
      if (value == 'closed') {
        chipColor = Colors.grey;
      } else if (value == 'resolved') chipColor = Colors.green;
      else if (value == 'in_progress') chipColor = AppTheme.primaryColor;
      else chipColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showTriageDialog(BuildContext context, String feedbackId, String currentCategory, String currentSeverity, String currentStatus, String currentAssignedTo) {
    String category = currentCategory;
    String severity = currentSeverity;
    String status = currentStatus;
    final assignedToController = TextEditingController(text: currentAssignedTo);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Edit Feedback Triage'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: category.isEmpty ? 'bug' : category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'bug', child: Text('Bug')),
                  DropdownMenuItem(value: 'feature', child: Text('Feature Request')),
                  DropdownMenuItem(value: 'complaint', child: Text('Complaint')),
                  DropdownMenuItem(value: 'suggestion', child: Text('Suggestion')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) => category = value ?? 'bug',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: severity.isEmpty ? 'low' : severity,
                decoration: const InputDecoration(labelText: 'Severity'),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'critical', child: Text('Critical')),
                ],
                onChanged: (value) => severity = value ?? 'low',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: status.isEmpty ? 'new' : status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'new', child: Text('New')),
                  DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                  DropdownMenuItem(value: 'closed', child: Text('Closed')),
                ],
                onChanged: (value) => status = value ?? 'new',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: assignedToController,
                decoration: const InputDecoration(labelText: 'Assigned To (Admin Email)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              assignedToController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final assignedTo = assignedToController.text.trim();
                await Future.wait([
                  if (category != currentCategory)
                    DatabaseService.updateFeedbackCategory(feedbackId, category),
                  if (severity != currentSeverity)
                    DatabaseService.updateFeedbackSeverity(feedbackId, severity),
                  if (status != currentStatus)
                    DatabaseService.changeFeedbackStatus(feedbackId, status),
                  if (assignedTo != currentAssignedTo)
                    DatabaseService.assignFeedback(feedbackId, assignedTo.isEmpty ? null : assignedTo),
                ]);
                if (mounted) {
                  assignedToController.dispose();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feedback triage updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  assignedToController.dispose();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating triage: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
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
                              'Feedbacks',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage user feedbacks to the system',
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
                        
                        // Triage Filters Row
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Category Filter
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _categoryFilter,
                                    decoration: const InputDecoration(
                                      labelText: 'Category',
                                      border: InputBorder.none,
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'all', child: Text('All')),
                                      DropdownMenuItem(value: 'bug', child: Text('Bug')),
                                      DropdownMenuItem(value: 'feature', child: Text('Feature Request')),
                                      DropdownMenuItem(value: 'complaint', child: Text('Complaint')),
                                      DropdownMenuItem(value: 'suggestion', child: Text('Suggestion')),
                                      DropdownMenuItem(value: 'other', child: Text('Other')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _categoryFilter = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Severity Filter
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _severityFilter,
                                    decoration: const InputDecoration(
                                      labelText: 'Severity',
                                      border: InputBorder.none,
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'all', child: Text('All')),
                                      DropdownMenuItem(value: 'low', child: Text('Low')),
                                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                                      DropdownMenuItem(value: 'high', child: Text('High')),
                                      DropdownMenuItem(value: 'critical', child: Text('Critical')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _severityFilter = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Status Filter
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _statusFilter,
                                    decoration: const InputDecoration(
                                      labelText: 'Status',
                                      border: InputBorder.none,
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: 'all', child: Text('All')),
                                      DropdownMenuItem(value: 'new', child: Text('New')),
                                      DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                                      DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                                      DropdownMenuItem(value: 'closed', child: Text('Closed')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _statusFilter = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Assigned To Filter
                                Expanded(
                                  child: DropdownButtonFormField<String?>(
                                    value: _assignedToFilter,
                                    decoration: const InputDecoration(
                                      labelText: 'Assigned To',
                                      border: InputBorder.none,
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: null, child: Text('All')),
                                      // In a real app, fetch admin users dynamically
                                      DropdownMenuItem(value: '', child: Text('Unassigned')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _assignedToFilter = value;
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
                              builder: (context, feedbacksSnapshot) {
                                if (feedbacksSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (feedbacksSnapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${feedbacksSnapshot.error}'));
                                }
                                
                                final feedbacksDocs = feedbacksSnapshot.data?.docs ?? [];
                                final filtered = _applyFilters(feedbacksDocs);
                                
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
                                    final content = (data['content'] ?? '').toString();
                                    final userName = (data['userName'] ?? 'Unknown').toString();
                                    final vetName = (data['vetName'] ?? '').toString();
                                    final type = (data['type'] ?? 'user').toString();
                                    final createdAt = data['createdAt'];
                                    
                                    // Triage fields
                                    final category = (data['category'] ?? '').toString();
                                    final severity = (data['severity'] ?? '').toString();
                                    final status = (data['status'] ?? 'new').toString();
                                    final assignedTo = (data['assignedTo'] ?? '').toString();
                                    final isPinned = data['isPinned'] ?? false;

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
                                                IconButton(
                                                  onPressed: () =>
                                                      _viewFeedbackDetails(
                                                          context, data),
                                                  icon: const Icon(Icons.visibility),
                                                  tooltip: 'View Details',
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      _deleteFeedback(context, doc.id, content),
                                                  icon: const Icon(Icons.delete),
                                                  color: Colors.red,
                                                  tooltip: 'Delete',
                                                ),
                                              ],
                                            ),
                                            if (content.isNotEmpty) ...[
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
                                            
                                            // Triage Fields
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                if (category.isNotEmpty)
                                                  _buildTriageChip('Category', category),
                                                if (severity.isNotEmpty)
                                                  _buildTriageChip('Severity', severity),
                                                if (status.isNotEmpty)
                                                  _buildTriageChip('Status', status),
                                                if (assignedTo.isNotEmpty)
                                                  _buildTriageChip('Assigned', assignedTo),
                                              ],
                                            ),
                                            
                                            // Action Buttons Row
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                                                    color: isPinned ? AppTheme.primaryColor : AppTheme.textSecondary,
                                                  ),
                                                  onPressed: () async {
                                                    try {
                                                      await DatabaseService.pinFeedback(doc.id, !isPinned);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(isPinned ? 'Unpinned feedback' : 'Pinned feedback'),
                                                          backgroundColor: Colors.green,
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('Error: $e'),
                                                          backgroundColor: Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  tooltip: isPinned ? 'Unpin' : 'Pin',
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.edit, size: 18),
                                                  onPressed: () => _showTriageDialog(context, doc.id, category, severity, status, assignedTo),
                                                  tooltip: 'Edit Triage',
                                                ),
                                              ],
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

