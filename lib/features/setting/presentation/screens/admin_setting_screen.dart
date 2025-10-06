import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_willbefore/core/utils/extensions/button_extensions.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/route_endpoint.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminSettingScreen extends ConsumerStatefulWidget {
  const AdminSettingScreen({super.key});

  @override
  ConsumerState<AdminSettingScreen> createState() => _AdminSettingScreenState();
}

class _AdminSettingScreenState extends ConsumerState<AdminSettingScreen> {
  void _logout() async {
    try {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.goNamed(RouteEndpoint.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return AppScaffold(
      appBar: AppBar(title: const Text('Admin Settings')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile avatar section
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                // decoration: AppDecorations.cardDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Container(
                    //   width: 100,
                    //   height: 100,
                    //   decoration: BoxDecoration(
                    //     shape: BoxShape.circle,
                    //     color: AppColors.primaryLaurel.withAlpha(
                    //       (0.1 * 255).toInt(),
                    //     ),
                    //     border: Border.all(color: AppColors.primaryLaurel),
                    //   ),
                    //   child: ClipOval(
                    //     child:
                    //         user?.photoURL != null && user!.photoURL!.isNotEmpty
                    //         ? AppCachedImage(
                    //             imageUrl: user.photoURL!,
                    //             fit: BoxFit.cover,
                    //           )
                    //         : const Icon(
                    //             Icons.person,
                    //             size: 60,
                    //             color: AppColors.primaryLaurel,
                    //           ),
                    //   ),
                    // ),
                    Gap.w20,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.email ?? 'Admin',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textAppLaurel,
                          ),
                        ),
                        Gap.h4,
                        Text(
                          user?.email ?? '',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        // Gap.h4,
                        // Text(
                        //   user?.phoneNumber ?? '',
                        //   style: GoogleFonts.notoSansKr(
                        //     fontSize: 12,
                        //     fontWeight: FontWeight.w400,
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Gap.h24,

            // Admin Settings Menu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              // decoration: AppDecorations.cardDecoration,
              child: Column(
                children: [
                  _AdminMenuItem(
                    icon: Icons.people_outline,
                    title: 'Manage Users',
                    onTap: () {
                      // context.pushNamed(RoutePaths.manageUsers);
                    },
                  ),
                  _AdminMenuItem(
                    icon: Icons.bar_chart_outlined,
                    title: 'View Reports',
                    onTap: () {
                      // context.pushNamed(RoutePaths.viewReports);
                    },
                  ),
                  _AdminMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'App Settings',
                    onTap: () {
                      // context.pushNamed(RoutePaths.appSettings);
                    },
                  ),
                  _AdminMenuItem(
                    icon: Icons.security_outlined,
                    title: 'Account Security',
                    onTap: () {
                      // context.pushNamed(RoutePaths.changePassword);
                    },
                  ),
                  _AdminMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _AdminMenuItem(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            Gap.h24,

            // Logout button
            context.secondaryButton(
              onPressed: () => _logout(),
              isLoading: authState.isLoading,
              borderRadius: 30,
              height: 48,
              borderColor: AppColors.errorRed,
              textColor: AppColors.errorRed,
              // prefixIconPath: AssetsPath.logout,
              text: 'Log Out',
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AdminMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.black),
      title: Text(title, style: TextStyle(color: AppColors.textAppBlack)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}
