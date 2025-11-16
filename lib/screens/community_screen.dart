import 'package:flutter/material.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:furever_healthy_admin/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _typeFilter = 'all'; // 'all', 'user', 'vet'
  String _categoryFilter = 'all'; // 'all', 'post', 'question', 'story', etc.
  
  // Feedback search and filter
  String _feedbackSearchQuery = '';
  String _vetFilter = 'all'; // 'all' or specific vet name

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _applyFeedbackFilters(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.where((doc) {
      final data = doc.data();
      final feedbackText = (data['Feedback'] ?? '').toString().toLowerCase();
      final userName = (data['Name'] ?? '').toString().toLowerCase();
      final vetName = (data['vetName'] ?? '').toString().toLowerCase();

      final matchesSearch = feedbackText.contains(_feedbackSearchQuery.toLowerCase()) ||
          userName.contains(_feedbackSearchQuery.toLowerCase()) ||
          vetName.contains(_feedbackSearchQuery.toLowerCase());
      
      final matchesVet = _vetFilter == 'all' || 
          vetName.toLowerCase() == _vetFilter.toLowerCase();

      return matchesSearch && matchesVet;
    }).toList();
  }

  void _deletePost(BuildContext context, String postId, String title) {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Remove Post'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to remove this post?'),
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
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Enter your admin password to confirm',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
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
            onPressed: () {
              passwordController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              if (passwordController.text.isEmpty) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your admin password'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final adminEmail = authProvider.userEmail ?? '';
              final isPasswordValid = await DatabaseService.verifyAdminPassword(adminEmail, passwordController.text);
              if (!isPasswordValid) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Invalid admin password'),
                    backgroundColor: Colors.red,
                  ),
                );
                passwordController.clear();
                return;
              }
              
              try {
                await DatabaseService.deleteCommunityPost(postId);
                if (mounted) {
                  passwordController.dispose();
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Post removed successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  passwordController.dispose();
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error removing post: $e'),
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
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _deleteFeedback(BuildContext context, String feedbackId, String vetName) {
    final passwordController = TextEditingController();
    
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
            Text('Are you sure you want to delete this feedback for $vetName?'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Enter your admin password to confirm',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
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
            onPressed: () {
              passwordController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              if (passwordController.text.isEmpty) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your admin password'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final adminEmail = authProvider.userEmail ?? '';
              final isPasswordValid = await DatabaseService.verifyAdminPassword(adminEmail, passwordController.text);
              if (!isPasswordValid) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Invalid admin password'),
                    backgroundColor: Colors.red,
                  ),
                );
                passwordController.clear();
                return;
              }
              
              try {
                await DatabaseService.deleteFeedbackToVet(feedbackId);
                if (mounted) {
                  passwordController.dispose();
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
                  passwordController.dispose();
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

  void _showMuteUserDialog(BuildContext context, String userId, String userName) {
    final reasonController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.volume_off, color: Colors.blue),
            SizedBox(width: 8),
            Text('Mute User'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mute user: $userName'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for muting *',
                hintText: 'Enter reason for muting this user',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Enter your admin password to confirm',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              reasonController.dispose();
              passwordController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (reasonController.text.isEmpty || passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final adminEmail = authProvider.userEmail ?? '';
              final isPasswordValid = await DatabaseService.verifyAdminPassword(adminEmail, passwordController.text);
              if (!isPasswordValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid admin password'),
                    backgroundColor: Colors.red,
                  ),
                );
                passwordController.clear();
                return;
              }
              
              try {
                await DatabaseService.muteUser(userId, reasonController.text);
                await DatabaseService.addStrike(
                  userId,
                  reasonController.text,
                  'mute',
                  authProvider.adminUser?.id ?? '',
                  authProvider.userEmail ?? 'admin',
                );
                
                if (mounted) {
                  reasonController.dispose();
                  passwordController.dispose();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User muted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  reasonController.dispose();
                  passwordController.dispose();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error muting user: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.volume_off),
            label: const Text('Mute'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuspendUserDialog(BuildContext context, String userId, String userName) {
    final reasonController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.block, color: Colors.red),
            SizedBox(width: 8),
            Text('Suspend User'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Suspend user: $userName'),
            const SizedBox(height: 8),
            const Text(
              'This will suspend the user account and prevent them from accessing the system.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for suspension *',
                hintText: 'Enter reason for suspending this user',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Enter your admin password to confirm',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              reasonController.dispose();
              passwordController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (reasonController.text.isEmpty || passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final adminEmail = authProvider.userEmail ?? '';
              final isPasswordValid = await DatabaseService.verifyAdminPassword(adminEmail, passwordController.text);
              if (!isPasswordValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid admin password'),
                    backgroundColor: Colors.red,
                  ),
                );
                passwordController.clear();
                return;
              }
              
              try {
                await DatabaseService.escalateToSuspension(userId, reasonController.text);
                await DatabaseService.addStrike(
                  userId,
                  reasonController.text,
                  'suspension',
                  authProvider.adminUser?.id ?? '',
                  authProvider.userEmail ?? 'admin',
                );
                
                if (mounted) {
                  reasonController.dispose();
                  passwordController.dispose();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User suspended successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  reasonController.dispose();
                  passwordController.dispose();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error suspending user: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.block),
            label: const Text('Suspend'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showWarningDialog(BuildContext context, String userId, String userName) {
    final reasonController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Issue Warning'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Issue warning to: $userName'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Warning reason *',
                hintText: 'Enter reason for this warning',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Enter your admin password to confirm',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              reasonController.dispose();
              passwordController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (reasonController.text.isEmpty || passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final adminEmail = authProvider.userEmail ?? '';
              final isPasswordValid = await DatabaseService.verifyAdminPassword(adminEmail, passwordController.text);
              if (!isPasswordValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid admin password'),
                    backgroundColor: Colors.red,
                  ),
                );
                passwordController.clear();
                return;
              }
              
              try {
                await DatabaseService.addStrike(
                  userId,
                  reasonController.text,
                  'warning',
                  authProvider.adminUser?.id ?? '',
                  authProvider.userEmail ?? 'admin',
                );
                
                if (mounted) {
                  reasonController.dispose();
                  passwordController.dispose();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Warning issued successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  reasonController.dispose();
                  passwordController.dispose();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error issuing warning: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.warning),
            label: const Text('Issue Warning'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _viewPostWithComments(
      BuildContext context, String postId, Map<String, dynamic> postData) {
    final message = postData['message'] ?? '';
    final userName = postData['userName'] ?? 'Unknown';
    final userId = postData['userId'] ?? '';
    final timestamp = postData['timestamp'];
    final reactions = postData['reactions'] ?? 0;
    final commentsCount = postData['comments'] ?? 0;
    final imageUrl = postData['imageUrl'] ?? '';
    final userAvatar = postData['userAvatar'] ?? '';

    String timestampStr = 'Unknown';
    if (timestamp != null) {
      if (timestamp is Timestamp) {
        timestampStr = timestamp.toDate().toString().substring(0, 19);
      } else {
        timestampStr = timestamp.toString();
      }
    }

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
                      Row(
                        children: [
                          if (userAvatar.isNotEmpty)
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(userAvatar),
                              onBackgroundImageError: (_, __) {},
                            )
                          else
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                              child: Text(
                                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  timestampStr,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _buildStatChip(Icons.favorite, reactions.toString()),
                              const SizedBox(width: 8),
                              _buildStatChip(Icons.comment, commentsCount.toString()),
                            ],
                          ),
                        ],
                      ),
                      if (userId.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDetailRow('User ID', userId),
                      ],
                      const SizedBox(height: 16),
                      if (imageUrl.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(
                            minHeight: 200,
                            maxHeight: 600,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  color: AppTheme.surfaceColor,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: AppTheme.surfaceColor,
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error, size: 48, color: AppTheme.errorColor),
                                        SizedBox(height: 8),
                                        Text('Failed to load image'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const Text(
                        'Message:',
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
                          message,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Comments:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: DatabaseService.getPostComments(postId),
                        builder: (context, commentsSnapshot) {
                          if (commentsSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (commentsSnapshot.hasError) {
                            return Center(
                              child: Text('Error loading comments: ${commentsSnapshot.error}'),
                            );
                          }
                          final comments = commentsSnapshot.data ?? [];
                          if (comments.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.borderColor),
                              ),
                              child: const Center(
                                child: Text('No comments yet'),
                              ),
                            );
                          }
                          return Column(
                            children: comments.map((comment) {
                              final commentText = comment['text'] ?? comment['message'] ?? '';
                              final commentUserName = comment['userName'] ?? 'Unknown';
                              final commentTimestamp = comment['createdAt'] ?? comment['timestamp'];
                              String commentTimeStr = 'Unknown';
                              if (commentTimestamp != null) {
                                if (commentTimestamp is Timestamp) {
                                  commentTimeStr = commentTimestamp.toDate().toString().substring(0, 19);
                                } else {
                                  commentTimeStr = commentTimestamp.toString();
                                }
                              }
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.borderColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          commentUserName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          commentTimeStr,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      commentText,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
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

  void _viewFeedbackDetails(BuildContext context, Map<String, dynamic> feedbackData) {
    final feedbackText = feedbackData['Feedback'] ?? '';
    final userName = feedbackData['Name'] ?? 'Unknown';
    final vetName = feedbackData['vetName'] ?? 'Unknown Vet';
    final rating = feedbackData['rating'] ?? 0;
    final date = feedbackData['date'];
    final appointmentId = feedbackData['appointmentId'] ?? '';

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
                      _buildDetailRow('Veterinarian', vetName),
                      const SizedBox(height: 16),
                      _buildDetailRow('User', userName),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'Rating: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppTheme.textSecondary,
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
                            '$rating/5',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (appointmentId.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildDetailRow('Appointment ID', appointmentId),
                      ],
                      if (feedbackText.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Feedback:',
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
                            feedbackText,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (date != null)
                        _buildDetailRow(
                          'Date',
                          date is Timestamp
                              ? date.toDate().toString()
                              : date.toString(),
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

  Widget _buildPostsTab() {
    return Column(
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
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService.getCommunityPostsStream(),
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
                if (docs.isEmpty) {
                  return const Center(
                      child: Text('No posts found'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final message =
                        (data['message'] ?? '').toString();
                    final userName =
                        (data['userName'] ?? 'Unknown').toString();
                    final userId =
                        (data['userId'] ?? '').toString();
                    final timestamp = data['timestamp'];
                    final reactions = data['reactions'] ?? 0;
                    final commentsCount = data['comments'] ?? 0;
                    final imageUrl =
                        (data['imageUrl'] ?? '').toString();
                    final userAvatar =
                        (data['userAvatar'] ?? '').toString();

                    String timestampStr = 'Unknown';
                    if (timestamp != null) {
                      if (timestamp is Timestamp) {
                        timestampStr = timestamp
                            .toDate()
                            .toString()
                            .substring(0, 16);
                      } else {
                        timestampStr = timestamp.toString();
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
                                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                  backgroundImage: userAvatar.isNotEmpty ? NetworkImage(userAvatar) : null,
                                  onBackgroundImageError: (_, __) {},
                                  child: userAvatar.isEmpty
                                      ? Text(
                                          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                                          style: const TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        timestampStr,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme
                                              .textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    _buildStatChip(
                                        Icons.favorite, '$reactions'),
                                    const SizedBox(width: 8),
                                    _buildStatChip(
                                        Icons.comment,
                                        '$commentsCount'),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _viewPostWithComments(
                                          context, doc.id, data),
                                  icon: const Icon(Icons.visibility),
                                  tooltip: 'View Details & Comments',
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (value) {
                                    if (userId.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('User ID not found'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    
                                    switch (value) {
                                      case 'delete':
                                        _deletePost(context, doc.id, message);
                                        break;
                                      case 'mute':
                                        _showMuteUserDialog(context, userId, userName);
                                        break;
                                      case 'suspend':
                                        _showSuspendUserDialog(context, userId, userName);
                                        break;
                                      case 'warning':
                                        _showWarningDialog(context, userId, userName);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red, size: 18),
                                          SizedBox(width: 8),
                                          Text('Remove Post'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'warning',
                                      child: Row(
                                        children: [
                                          Icon(Icons.warning, color: Colors.orange, size: 18),
                                          SizedBox(width: 8),
                                          Text('Issue Warning'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'mute',
                                      child: Row(
                                        children: [
                                          Icon(Icons.volume_off, color: Colors.blue, size: 18),
                                          SizedBox(width: 8),
                                          Text('Mute User'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'suspend',
                                      child: Row(
                                        children: [
                                          Icon(Icons.block, color: Colors.red, size: 18),
                                          SizedBox(width: 8),
                                          Text('Suspend User'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (imageUrl.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(
                                  minHeight: 200,
                                  maxHeight: 600,
                                ),
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
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 200,
                                        color: AppTheme.surfaceColor,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context,
                                        error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        color: AppTheme.surfaceColor,
                                        child: const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error,
                                                  size: 48,
                                                  color: AppTheme.errorColor),
                                              SizedBox(height: 8),
                                              Text('Failed to load image'),
                                            ],
                                          ),
                                        ),
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
                                message.length > 200
                                    ? '${message.substring(0, 200)}...'
                                    : message,
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
    );
  }

  Widget _buildFeedbacksTab() {
    return Column(
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
                        _feedbackSearchQuery = value;
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

                // Vet Filter (will be populated dynamically)
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: DatabaseService.vets.snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return DropdownButtonFormField<String>(
                          value: 'all',
                          decoration: const InputDecoration(
                            labelText: 'Vet',
                            border: InputBorder.none,
                          ),
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'all',
                              child: Text('All Vets'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _vetFilter = value ?? 'all';
                            });
                          },
                        );
                      }

                      final vets = snapshot.data!.docs;
                      final vetNames = <String>['all', ...vets.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return (data['name'] ?? data['displayName'] ?? 'Unknown') as String;
                      }).toSet().toList()..sort()];

                      return DropdownButtonFormField<String>(
                        value: _vetFilter,
                        decoration: const InputDecoration(
                          labelText: 'Vet',
                          border: InputBorder.none,
                        ),
                        items: vetNames.map<DropdownMenuItem<String>>((vetName) {
                          return DropdownMenuItem<String>(
                            value: vetName,
                            child: Text(vetName == 'all' ? 'All Vets' : vetName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _vetFilter = value ?? 'all';
                          });
                        },
                      );
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
              stream: DatabaseService.feedback
                  .orderBy('date', descending: true)
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
                final filtered = _applyFeedbackFilters(docs);
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
                    final feedbackText =
                        (data['Feedback'] ?? '').toString();
                    final userName =
                        (data['Name'] ?? 'Unknown').toString();
                    final vetName =
                        (data['vetName'] ?? 'Unknown Vet').toString();
                    final rating = data['rating'] ?? 0;
                    final date = data['date'];
                    final isHidden = data['isHidden'] ?? false;

                    String dateStr = 'Unknown';
                    if (date != null) {
                      if (date is Timestamp) {
                        dateStr = date
                            .toDate()
                            .toString()
                            .substring(0, 16);
                      } else {
                        dateStr = date.toString();
                      }
                    }

                    if (isHidden) {
                      return const SizedBox.shrink();
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
                                  backgroundColor: AppTheme.primaryColor
                                      .withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppTheme.primaryColor,
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
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            'Rating: ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme
                                                  .textSecondary,
                                            ),
                                          ),
                                          ...List.generate(5, (index) {
                                            return Icon(
                                              index < rating
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 16,
                                            );
                                          }),
                                          const SizedBox(width: 8),
                                          Text(
                                            'for $vetName',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme
                                                  .textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            dateStr,
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
                                      _deleteFeedback(context, doc.id, vetName),
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                            if (feedbackText.isNotEmpty) ...[
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
                                  feedbackText.length > 200
                                      ? '${feedbackText.substring(0, 200)}...'
                                      : feedbackText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
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
                              'Moderate community posts and vet feedbacks',
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

                // Tabs
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceColor,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorColor: AppTheme.primaryColor,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.article),
                        text: 'Posts',
                      ),
                      Tab(
                        icon: Icon(Icons.feedback),
                        text: 'Feedbacks & Ratings',
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPostsTab(),
                        _buildFeedbacksTab(),
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
