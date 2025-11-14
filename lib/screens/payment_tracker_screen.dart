import 'package:flutter/material.dart';
import 'package:furever_healthy_admin/theme/app_theme.dart';
import 'package:furever_healthy_admin/widgets/sidebar.dart';
import 'package:furever_healthy_admin/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentTrackerScreen extends StatefulWidget {
  const PaymentTrackerScreen({super.key});

  @override
  State<PaymentTrackerScreen> createState() => _PaymentTrackerScreenState();
}

class _PaymentTrackerScreenState extends State<PaymentTrackerScreen> {
  String _searchQuery = '';
  String _typeFilter = 'all'; // 'all', 'user', 'vet'
  String _statusFilter = 'all'; // 'all', 'Pending', 'Approved', 'Rejected'
  String _sortBy = 'date'; // 'date', 'name', 'reference'
  
  // Cache for user/vet names
  final Map<String, String> _nameCache = {};
  
  // Scroll controllers for proper scroll bar control
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  
  // Helper method to fix Firebase Storage URLs
  String _fixImageUrl(String url) {
    if (url.isEmpty) return url;
    
    print('Original URL: $url');
    
    // Handle Firebase Storage URLs that might have malformed paths
    if (url.contains('firebasestorage.googleapis.com')) {
      try {
        // Pattern 1: URL with /alt=media&token= in the path (most common malformed format)
        // Example: https://firebasestorage.googleapis.com/v0/b/bucket/o/path/alt=media&token=xxx
        if (url.contains('/alt=media') && !url.contains('?alt=media')) {
          // Extract bucket, path, and token using regex
          final bucketMatch = RegExp(r'/v0/b/([^/]+)').firstMatch(url);
          if (bucketMatch != null) {
            final bucket = bucketMatch.group(1)!;
            
            // Try to extract path and token
            // Pattern: /o/path/alt=media&token=xxx or /o/path/alt=media&token=xxx
            final pathTokenMatch = RegExp(r'/o/(.+?)(?:/|&)alt=media[&]?token=([^&\s"]+)').firstMatch(url);
            if (pathTokenMatch != null) {
              final filePath = pathTokenMatch.group(1)!;
              final token = pathTokenMatch.group(2)!;
              
              // Encode the path properly (each segment separately)
              final pathSegments = filePath.split('/');
              final encodedPath = pathSegments.map((seg) => Uri.encodeComponent(seg)).join('/');
              
              final fixedUrl = 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media&token=$token';
              print('Fixed URL (pattern 1): $fixedUrl');
              return fixedUrl;
            }
            
            // Alternative: try splitting by /alt=media
            final altSplit = url.split('/alt=media');
            if (altSplit.length == 2) {
              final beforeAlt = altSplit[0];
              final afterAlt = altSplit[1];
              
              // Extract path from before /alt=media
              final pathMatch = RegExp(r'/o/(.+)$').firstMatch(beforeAlt);
              final tokenMatch = RegExp(r'token=([^&\s"]+)').firstMatch(afterAlt);
              
              if (pathMatch != null && tokenMatch != null) {
                final filePath = pathMatch.group(1)!;
                final token = tokenMatch.group(1)!;
                
                // Encode the path
                final pathSegments = filePath.split('/');
                final encodedPath = pathSegments.map((seg) => Uri.encodeComponent(seg)).join('/');
                
                final fixedUrl = 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedPath?alt=media&token=$token';
                print('Fixed URL (pattern 2): $fixedUrl');
                return fixedUrl;
              }
            }
          }
        }
        
        // Pattern 2: Standard format with query params - just ensure proper encoding
        if (url.contains('?alt=media') || url.contains('&alt=media')) {
          final uri = Uri.tryParse(url);
          if (uri != null) {
            // Check if path needs encoding
            final pathSegments = uri.pathSegments;
            if (pathSegments.isNotEmpty) {
              final lastSegment = pathSegments.last;
              // If the last segment looks like it might need encoding
              if (!lastSegment.contains('%') && (lastSegment.contains(' ') || lastSegment.contains('&'))) {
                // Reconstruct with proper encoding
                final encodedSegments = pathSegments.map((seg) => Uri.encodeComponent(seg)).toList();
                final newPath = '/${encodedSegments.join('/')}';
                final newUri = uri.replace(path: newPath);
                print('Fixed URL (pattern 3): ${newUri.toString()}');
                return newUri.toString();
              }
            }
            print('URL already properly formatted: ${uri.toString()}');
            return uri.toString();
          }
        }
      } catch (e) {
        print('Error fixing URL: $e');
      }
    }
    
    // If URL contains spaces, encode them
    if (url.contains(' ')) {
      url = url.replaceAll(' ', '%20');
    }
    
    // Try to parse and reformat the URL
    final uri = Uri.tryParse(url);
    if (uri != null) {
      return uri.toString();
    }
    
    print('Returning original URL (could not fix)');
    return url;
  }

  // Helper method to get name from cache or fetch it
  Future<String> _getName(String? userId, String? vetId) async {
    if (userId != null && userId.isNotEmpty) {
      if (_nameCache.containsKey('user_$userId')) {
        return _nameCache['user_$userId']!;
      }
      try {
        final userDoc = await DatabaseService.getUser(userId);
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>?;
          final name = (userData?['name'] ?? 'Unknown User').toString();
          _nameCache['user_$userId'] = name;
          return name;
        }
      } catch (e) {
        print('Error fetching user name: $e');
      }
      return 'Unknown User';
    } else if (vetId != null && vetId.isNotEmpty) {
      if (_nameCache.containsKey('vet_$vetId')) {
        return _nameCache['vet_$vetId']!;
      }
      try {
        final vetDoc = await DatabaseService.getVet(vetId);
        if (vetDoc.exists) {
          final vetData = vetDoc.data() as Map<String, dynamic>?;
          final name = (vetData?['name'] ?? 'Unknown Vet').toString();
          _nameCache['vet_$vetId'] = name;
          return name;
        }
      } catch (e) {
        print('Error fetching vet name: $e');
      }
      return 'Unknown Vet';
    }
    return 'Unknown';
  }

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  List<DocumentSnapshot> _applyFilters(List<DocumentSnapshot> docs) {
    var filtered = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final transactionId = (data['transactionId'] ?? '').toString();
      final notes = (data['notes'] ?? '').toString();
      final userId = data['userId']?.toString();
      final userType = userId != null && userId.isNotEmpty ? 'user' : 'vet';
      final status = (data['status'] ?? 'Pending').toString();
      
      // For search, we'll check transactionId and notes (name will be checked after async fetch)
      final matchesSearch = transactionId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          notes.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _typeFilter == 'all' || userType == _typeFilter;
      final matchesStatus = _statusFilter == 'all' || 
          status.toLowerCase() == _statusFilter.toLowerCase();
      
      return matchesSearch && matchesType && matchesStatus;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>? ?? {};
      final bData = b.data() as Map<String, dynamic>? ?? {};
      
      switch (_sortBy) {
        case 'name':
          // For name sorting, we'll use IDs as fallback (async name fetch happens in UI)
          final aId = (aData['userId'] ?? aData['vetId'] ?? '').toString();
          final bId = (bData['userId'] ?? bData['vetId'] ?? '').toString();
          return aId.compareTo(bId);
        case 'reference':
          final aRef = (aData['transactionId'] ?? '').toString();
          final bRef = (bData['transactionId'] ?? '').toString();
          return aRef.compareTo(bRef);
        case 'date':
        default:
          // Use submissionTime, fallback to createdAt
          dynamic aDate = aData['submissionTime'] ?? aData['createdAt'];
          dynamic bDate = bData['submissionTime'] ?? bData['createdAt'];
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          
          // Handle both Timestamp and String formats
          Timestamp aTimestamp;
          Timestamp bTimestamp;
          
          if (aDate is Timestamp) {
            aTimestamp = aDate;
          } else if (aDate is String) {
            // Try to parse string date
            try {
              aTimestamp = Timestamp.fromDate(DateTime.parse(aDate));
            } catch (e) {
              aTimestamp = Timestamp.now();
            }
          } else {
            aTimestamp = Timestamp.now();
          }
          
          if (bDate is Timestamp) {
            bTimestamp = bDate;
          } else if (bDate is String) {
            try {
              bTimestamp = Timestamp.fromDate(DateTime.parse(bDate));
            } catch (e) {
              bTimestamp = Timestamp.now();
            }
          } else {
            bTimestamp = Timestamp.now();
          }
          
          return bTimestamp.compareTo(aTimestamp); // Descending (newest first)
      }
    });
    
    return filtered;
  }

  Future<void> _viewPaymentDetails(BuildContext context, DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final userId = data['userId']?.toString();
    final vetId = data['vetId']?.toString();
    final name = await _getName(userId, vetId);
    final userType = userId != null && userId.isNotEmpty ? 'user' : 'vet';
    final transactionId = (data['transactionId'] ?? '').toString();
    final screenshotUrl = (data['screenshotUrl'] ?? '').toString();
    final notes = (data['notes'] ?? '').toString();
    final amount = data['amount']?.toString() ?? 'N/A';
    final status = (data['status'] ?? 'Pending').toString();
    
    // Parse submissionTime - can be Timestamp or String
    DateTime submissionDate = DateTime.now();
    final submissionTime = data['submissionTime'];
    if (submissionTime is Timestamp) {
      submissionDate = submissionTime.toDate();
    } else if (submissionTime is String) {
      try {
        submissionDate = DateTime.parse(submissionTime);
      } catch (e) {
        // If parsing fails, use current date
      }
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payment, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Payment Details',
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
                // Payment Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Name', name),
                      const SizedBox(height: 12),
                      _buildDetailRow('Type', userType == 'user' ? 'User' : 'Veterinarian'),
                      const SizedBox(height: 12),
                      _buildDetailRow('GCash Reference No.', transactionId.isEmpty ? 'N/A' : transactionId),
                      const SizedBox(height: 12),
                      _buildDetailRow('Amount', '₱$amount'),
                      const SizedBox(height: 12),
                      _buildDetailRow('Status', status),
                      const SizedBox(height: 12),
                      _buildDetailRow('Payment Date', 
                        '${submissionDate.year}-${submissionDate.month.toString().padLeft(2, '0')}-${submissionDate.day.toString().padLeft(2, '0')} ${submissionDate.hour.toString().padLeft(2, '0')}:${submissionDate.minute.toString().padLeft(2, '0')}'),
                      if (notes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow('Notes', notes),
                      ],
                      if (userId != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow('User ID', userId),
                      ],
                      if (vetId != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow('Vet ID', vetId),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Screenshot
                if (screenshotUrl.isNotEmpty) ...[
                  const Text(
                    'Payment Screenshot:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 500),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _fixImageUrl(screenshotUrl),
                        fit: BoxFit.contain,
                        headers: const {
                          'Accept': 'image/*',
                        },
                        errorBuilder: (context, error, stackTrace) {
                          final fixedUrl = _fixImageUrl(screenshotUrl);
                          print('Image load error: $error');
                          print('Original URL: $screenshotUrl');
                          print('Fixed URL: $fixedUrl');
                          print('Error type: ${error.runtimeType}');
                          if (error is Exception) {
                            print('Exception: ${error.toString()}');
                          }
                          
                          return Container(
                            height: 200,
                            color: AppTheme.surfaceColor,
                            child: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error, size: 48, color: AppTheme.errorColor),
                                    const SizedBox(height: 8),
                                    const Text('Failed to load image'),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Original: ${screenshotUrl.length > 80 ? "${screenshotUrl.substring(0, 80)}..." : screenshotUrl}',
                                            style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Fixed: ${fixedUrl.length > 80 ? "${fixedUrl.substring(0, 80)}..." : fixedUrl}',
                                            style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Error: ${error.toString().length > 100 ? "${error.toString().substring(0, 100)}..." : error.toString()}',
                                            style: const TextStyle(fontSize: 9, color: AppTheme.errorColor),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: AppTheme.surfaceColor,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, size: 48, color: AppTheme.textSecondary),
                          SizedBox(height: 8),
                          Text('No screenshot available'),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Actions
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _updatePaymentStatus(BuildContext context, String paymentId, String newStatus) {
    final passwordController = TextEditingController();
    final isApproved = newStatus.toLowerCase() == 'approved';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isApproved ? Icons.check_circle : Icons.cancel,
              color: isApproved ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text('${isApproved ? 'Approve' : 'Reject'} Payment'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to ${isApproved ? 'approve' : 'reject'} this payment?'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Enter your admin password to confirm',
                hintText: 'Type your admin password',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              autofocus: true,
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
          ElevatedButton.icon(
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
              
              final isPasswordValid = await DatabaseService.verifyAdminPassword(passwordController.text);
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
                // Use capitalized status: "Approved" or "Rejected"
                final statusToUpdate = isApproved ? 'Approved' : 'Rejected';
                await DatabaseService.updatePaymentStatus(paymentId, statusToUpdate);
                if (mounted) {
                  passwordController.dispose();
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Payment ${isApproved ? 'approved' : 'rejected'} successfully'),
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
                      content: Text('Error updating payment: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproved ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: Icon(isApproved ? Icons.check_circle : Icons.cancel),
            label: Text(isApproved ? 'Approve' : 'Reject'),
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
                              'Payment Tracker',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Track GCash premium payments from users and veterinarians',
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
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Search
                                  SizedBox(
                                    width: 250,
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _searchQuery = value;
                                        });
                                      },
                                      decoration: const InputDecoration(
                                        hintText: 'Search by name or reference...',
                                        prefixIcon: Icon(Icons.search),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Type Filter
                                  SizedBox(
                                    width: 150,
                                    child: DropdownButtonFormField<String>(
                                      value: _typeFilter,
                                      decoration: const InputDecoration(
                                        labelText: 'Type',
                                        border: InputBorder.none,
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'all', child: Text('All')),
                                        DropdownMenuItem(value: 'user', child: Text('Users')),
                                        DropdownMenuItem(value: 'vet', child: Text('Vets')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _typeFilter = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Status Filter
                                  SizedBox(
                                    width: 150,
                                    child: DropdownButtonFormField<String>(
                                      value: _statusFilter,
                                      decoration: const InputDecoration(
                                        labelText: 'Status',
                                        border: InputBorder.none,
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'all', child: Text('All')),
                                        DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                                        DropdownMenuItem(value: 'Approved', child: Text('Approved')),
                                        DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          _statusFilter = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Sort By
                                  SizedBox(
                                    width: 150,
                                    child: DropdownButtonFormField<String>(
                                      value: _sortBy,
                                      decoration: const InputDecoration(
                                        labelText: 'Sort By',
                                        border: InputBorder.none,
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'date', child: Text('Date')),
                                        DropdownMenuItem(value: 'name', child: Text('Name')),
                                        DropdownMenuItem(value: 'reference', child: Text('Reference')),
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
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Payments Table
                        Expanded(
                          child: Card(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: DatabaseService.getPaymentsStream(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(child: Text('Error: ${snapshot.error}'));
                                }
                                final docs = snapshot.data?.docs ?? [];
                                final filtered = _applyFilters(docs);
                                if (filtered.isEmpty) {
                                  return const Center(child: Text('No payments found'));
                                }
                                return SizedBox(
                                  height: 600,
                                  child: Scrollbar(
                                    controller: _verticalScrollController,
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    child: SingleChildScrollView(
                                      controller: _verticalScrollController,
                                      scrollDirection: Axis.vertical,
                                      child: Scrollbar(
                                        controller: _horizontalScrollController,
                                        thumbVisibility: true,
                                        trackVisibility: true,
                                        child: SingleChildScrollView(
                                          controller: _horizontalScrollController,
                                          scrollDirection: Axis.horizontal,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(minWidth: 1400),
                                            child: DataTable(
                                              columnSpacing: 24,
                                              columns: const [
                                                DataColumn(label: Text('View')),
                                                DataColumn(label: Text('Name')),
                                                DataColumn(label: Text('Type')),
                                                DataColumn(label: Text('GCash Reference')),
                                                DataColumn(label: Text('Screenshot')),
                                                DataColumn(label: Text('Payment Date')),
                                                DataColumn(label: Text('Status')),
                                                DataColumn(label: Text('Actions')),
                                              ],
                                              rows: filtered.map((doc) {
                                                final data = doc.data() as Map<String, dynamic>? ?? {};
                                                final userId = data['userId']?.toString();
                                                final vetId = data['vetId']?.toString();
                                                final userType = userId != null && userId.isNotEmpty ? 'user' : 'vet';
                                                final transactionId = (data['transactionId'] ?? '').toString();
                                                final screenshotUrl = (data['screenshotUrl'] ?? '').toString();
                                                final status = (data['status'] ?? 'Pending').toString();
                                                
                                                // Parse submissionTime
                                                DateTime submissionDate = DateTime.now();
                                                final submissionTime = data['submissionTime'];
                                                if (submissionTime is Timestamp) {
                                                  submissionDate = submissionTime.toDate();
                                                } else if (submissionTime is String) {
                                                  try {
                                                    submissionDate = DateTime.parse(submissionTime);
                                                  } catch (e) {
                                                    // Use current date if parsing fails
                                                  }
                                                }
                                                
                                                return DataRow(
                                                  cells: [
                                                    DataCell(
                                                      ElevatedButton(
                                                        onPressed: () => _viewPaymentDetails(context, doc),
                                                        style: ElevatedButton.styleFrom(
                                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                          minimumSize: const Size(60, 32),
                                                        ),
                                                        child: const Text('View', style: TextStyle(fontSize: 12)),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      FutureBuilder<String>(
                                                        future: _getName(userId, vetId),
                                                        builder: (context, snapshot) {
                                                          final name = snapshot.data ?? 'Loading...';
                                                          return Row(
                                                            children: [
                                                              CircleAvatar(
                                                                radius: 16,
                                                                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                                                child: Text(
                                                                  name.isNotEmpty && name != 'Loading...' ? name[0].toUpperCase() : '?',
                                                                  style: const TextStyle(
                                                                    color: AppTheme.primaryColor,
                                                                    fontWeight: FontWeight.w600,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(width: 8),
                                                              Expanded(
                                                                child: Text(
                                                                  name,
                                                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: userType == 'user'
                                                              ? Colors.blue.withOpacity(0.1)
                                                              : Colors.purple.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          userType == 'user' ? 'User' : 'Vet',
                                                          style: TextStyle(
                                                            color: userType == 'user' ? Colors.blue : Colors.purple,
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        transactionId.isEmpty ? 'N/A' : transactionId,
                                                        style: const TextStyle(
                                                          fontFamily: 'monospace',
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      screenshotUrl.isNotEmpty
                                                          ? IconButton(
                                                              onPressed: () => _viewPaymentDetails(context, doc),
                                                              icon: const Icon(Icons.image, size: 20),
                                                              tooltip: 'View screenshot',
                                                            )
                                                          : const Icon(Icons.image_not_supported, size: 20, color: AppTheme.textSecondary),
                                                    ),
                                                    DataCell(
                                                      Text(
                                                        '${submissionDate.year}-${submissionDate.month.toString().padLeft(2, '0')}-${submissionDate.day.toString().padLeft(2, '0')}',
                                                        style: const TextStyle(fontSize: 12),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        decoration: BoxDecoration(
                                                          color: status.toLowerCase() == 'approved'
                                                              ? AppTheme.successColor.withOpacity(0.1)
                                                              : status.toLowerCase() == 'rejected'
                                                                  ? AppTheme.errorColor.withOpacity(0.1)
                                                                  : Colors.orange.withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          status,
                                                          style: TextStyle(
                                                            color: status.toLowerCase() == 'approved'
                                                                ? AppTheme.successColor
                                                                : status.toLowerCase() == 'rejected'
                                                                    ? AppTheme.errorColor
                                                                    : Colors.orange,
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          if (status.toLowerCase() == 'pending') ...[
                                                            IconButton(
                                                              onPressed: () => _updatePaymentStatus(context, doc.id, 'Approved'),
                                                              icon: const Icon(Icons.check_circle, size: 16),
                                                              tooltip: 'Approve',
                                                              color: Colors.green,
                                                              constraints: const BoxConstraints(
                                                                minWidth: 24,
                                                                minHeight: 24,
                                                              ),
                                                              padding: EdgeInsets.zero,
                                                            ),
                                                            IconButton(
                                                              onPressed: () => _updatePaymentStatus(context, doc.id, 'Rejected'),
                                                              icon: const Icon(Icons.cancel, size: 16),
                                                              tooltip: 'Reject',
                                                              color: Colors.red,
                                                              constraints: const BoxConstraints(
                                                                minWidth: 24,
                                                                minHeight: 24,
                                                              ),
                                                              padding: EdgeInsets.zero,
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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


