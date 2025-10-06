import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../provider/all_user_provider.dart';

class AllUserProfileScreen extends ConsumerStatefulWidget {
  const AllUserProfileScreen({super.key});

  @override
  ConsumerState<AllUserProfileScreen> createState() =>
      _AllUserProfileScreenState();
}

class _AllUserProfileScreenState extends ConsumerState<AllUserProfileScreen> {
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final users = userState.users;

    // Get the current user
    final currentUser = ref.watch(currentUserProvider);
    final currentUserId = currentUser?.id;

    // Filter out the current user and admin roles
    final filteredUsers = users.where((user) {
      return user.id != currentUserId && user.role != 'admin';
    }).toList();

    // Pagination logic
    final totalPages = (filteredUsers.length / _itemsPerPage).ceil();
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(
      0,
      filteredUsers.length,
    );
    final paginatedUsers = filteredUsers.sublist(startIndex, endIndex);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 23),
            decoration: BoxDecoration(
              color: Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textAppBlack,
                  ),
                ),

                Container(
                  width: 259,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLaurel,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total User',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.bgColor,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              color: AppColors.successGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Gap.w4,
                          Text(
                            '${filteredUsers.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.bgColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ElevatedButton.icon(
                //   onPressed: () => context.go('${RouteEndpoint.users}/add'),
                //   icon: const Icon(Icons.add, color: Colors.white),
                //   label: Text('Add User', style: TextStyle(color: Colors.white)),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: AppColors.primaryLaurel,
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 20,
                //       vertical: 12,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Users Table
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.borderColor),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Name',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textAppBlack,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Email',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textAppBlack,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Phone',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textAppBlack,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Role',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textAppBlack,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Created At',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textAppBlack,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text(
                            'Action',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textAppBlack,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Table Body
                  if (userState.isLoading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryLaurel,
                        ),
                      ),
                    )
                  else if (users.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 64,
                              color: AppColors.textSecondaryHintColor,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondaryHintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: paginatedUsers.length,
                        itemBuilder: (context, index) {
                          final user = paginatedUsers[index];
                          final isLast = index == paginatedUsers.length - 1;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isLast
                                      ? Colors.transparent
                                      : AppColors.borderColor,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Name with Image
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      // Container(
                                      //   width: 60,
                                      //   height: 60,
                                      //   decoration: BoxDecoration(
                                      //     borderRadius: BorderRadius.circular(8),
                                      //     color: AppColors.bgColor,
                                      //   ),
                                      //   child: ClipRRect(
                                      //     borderRadius: BorderRadius.circular(8),
                                      //     child: user.photoURL != null && user.isValidPhotoURL()
                                      //         ? Image.network(
                                      //             user.photoURL!,
                                      //             fit: BoxFit.cover,
                                      //             errorBuilder: (context, error, stackTrace) {
                                      //               return Center(
                                      //                 child: Text(
                                      //                   user.initials,
                                      //                   style: TextStyle(color: Colors.white, fontSize: 20),
                                      //                 ),
                                      //               );
                                      //             },
                                      //           )
                                      //         : Center(
                                      //             child: Text(
                                      //               user.initials,
                                      //               style: TextStyle(color: Colors.white, fontSize: 20),
                                      //             ),
                                      //           ),
                                      //   ),
                                      // ),
                                      // const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          user.displayNameOrEmail,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textAppBlack,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Email
                                Expanded(
                                  child: Text(
                                    user.email ?? '-',
                                    style: const TextStyle(
                                      color: AppColors.textSecondaryColor,
                                    ),
                                  ),
                                ),
                                // Phone
                                Expanded(
                                  child: Text(
                                    user.phoneNumber ?? '-',
                                    style: const TextStyle(
                                      color: AppColors.textSecondaryColor,
                                    ),
                                  ),
                                ),
                                // Role
                                Expanded(
                                  child: Text(
                                    user.role,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textAppBlack,
                                    ),
                                  ),
                                ),
                                // Created At
                                Expanded(
                                  child: Text(
                                    user.createdAt != null
                                        ? DateFormat(
                                            'dd MMM yyyy hh:mm a',
                                          ).format(user.createdAt)
                                        : '-',
                                    style: const TextStyle(
                                      color: AppColors.textSecondaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                // Actions
                                SizedBox(
                                  width: 100,
                                  child: Row(
                                    children: [
                                      // IconButton(
                                      //   onPressed: () => context.go(
                                      //     '${RouteEndpoint.users}/edit/${user.id}',
                                      //   ),
                                      //   icon: const Icon(
                                      //     Icons.edit_outlined,
                                      //     size: 18,
                                      //     color: AppColors.primaryLaurel,
                                      //   ),
                                      // ),
                                      IconButton(
                                        onPressed: userState.isLoading
                                            ? null
                                            : () => _showDeleteDialog(
                                                context,
                                                user.id,
                                              ),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // Pagination
                  if (users.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.borderColor),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${startIndex + 1} to $endIndex of ${users.length} results',
                            style: const TextStyle(
                              color: AppColors.textSecondaryColor,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: _currentPage > 1
                                    ? () => setState(() => _currentPage--)
                                    : null,
                                icon: const Icon(Icons.chevron_left),
                              ),
                              ...List.generate(totalPages, (index) {
                                final pageNumber = index + 1;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _currentPage = pageNumber),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _currentPage == pageNumber
                                          ? AppColors.primaryLaurel
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      pageNumber.toString(),
                                      style: TextStyle(
                                        color: _currentPage == pageNumber
                                            ? Colors.white
                                            : AppColors.textSecondaryColor,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              IconButton(
                                onPressed: _currentPage < totalPages
                                    ? () => setState(() => _currentPage++)
                                    : null,
                                icon: const Icon(Icons.chevron_right),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: const Text(
            'Are you sure you want to delete this user? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await ref
                    .read(userProvider.notifier)
                    .deleteUser(userId);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User deleted successfully!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
