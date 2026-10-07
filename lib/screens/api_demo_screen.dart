import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

class ApiDemoScreen extends StatefulWidget {
  const ApiDemoScreen({super.key});

  @override
  State<ApiDemoScreen> createState() => _ApiDemoScreenState();
}

class _ApiDemoScreenState extends State<ApiDemoScreen> {
  late ApiService _apiService;
  late Future<List<UserModel>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _usersFuture = _apiService.fetchUsers();
    });
  }

  void _testStatusCode(String endpoint, String label) {
    setState(() {
      _usersFuture = _apiService.fetchUsers(endpoint: endpoint);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Integration Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload API',
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner explaining API Endpoint source
          Container(
            padding: const EdgeInsets.all(12.0),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.http_outlined, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Live Endpoint: jsonplaceholder.typicode.com/users',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.check, size: 14, color: Colors.green),
                        label: const Text('Test 200 (Success)'),
                        onPressed: _fetchData,
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: const Icon(Icons.error_outline, size: 14, color: Colors.red),
                        label: const Text('Test 404 (Not Found)'),
                        onPressed: () => _testStatusCode(
                          'https://jsonplaceholder.typicode.com/invalid_users_404',
                          '404',
                        ),
                      ),
                      const SizedBox(width: 8),
                      ActionChip(
                        avatar: const Icon(Icons.wifi_off, size: 14, color: Colors.orange),
                        label: const Text('Test Invalid Host'),
                        onPressed: () => _testStatusCode(
                          'https://invalid.domain.that.does.not.exist.test/users',
                          'No Internet',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main API FutureBuilder Content
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(
                    message: 'Connecting to REST API endpoint...',
                  );
                }

                if (snapshot.hasError) {
                  final error = snapshot.error;
                  String message = error.toString();
                  if (error is ApiServiceException) {
                    message = error.message;
                  }
                  return CustomErrorWidget(
                    errorMessage: message,
                    onRetry: _fetchData,
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return CustomErrorWidget(
                    errorMessage: 'No user data received from API.',
                    onRetry: _fetchData,
                  );
                }

                final users = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                              child: Text(
                                user.name.isNotEmpty ? user.name[0] : 'U',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user.name,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.secondaryColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '@${user.username}',
                                          style: const TextStyle(
                                            color: AppTheme.secondaryColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.email_outlined,
                                          size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          user.email,
                                          style: theme.textTheme.bodySmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (user.phone != null) ...[
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone_outlined,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(user.phone!,
                                            style: theme.textTheme.bodySmall),
                                      ],
                                    ),
                                  ],
                                  if (user.companyName != null || user.cityName != null) ...[
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      children: [
                                        if (user.companyName != null)
                                          Chip(
                                            visualDensity: VisualDensity.compact,
                                            avatar: const Icon(Icons.business, size: 12),
                                            label: Text(user.companyName!,
                                                style: const TextStyle(fontSize: 10)),
                                          ),
                                        if (user.cityName != null)
                                          Chip(
                                            visualDensity: VisualDensity.compact,
                                            avatar: const Icon(Icons.location_city, size: 12),
                                            label: Text(user.cityName!,
                                                style: const TextStyle(fontSize: 10)),
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
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
        ],
      ),
    );
  }
}
