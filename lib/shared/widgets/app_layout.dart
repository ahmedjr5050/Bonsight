import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bonssight/core/di/injection_container.dart';
import 'package:bonssight/core/theme/app_colors.dart';
import 'package:bonssight/features/analysis/presentation/pages/new_analysis_page.dart';
import 'package:bonssight/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:bonssight/features/auth/presentation/cubit/auth_state.dart';
import 'package:bonssight/features/auth/presentation/pages/sign_in_page.dart';
import 'package:bonssight/features/history/presentation/pages/history_page.dart';
import 'package:bonssight/features/dashboard/presentation/pages/dashboard_page.dart';

class AppLayout extends StatefulWidget {
  final String uid;
  final String email;

  const AppLayout({super.key, required this.uid, required this.email});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SignInPage()),
              (_) => false,
            );
          }
        },
        child: _AppLayoutBody(
          uid: widget.uid,
          email: widget.email,
          selectedIndex: _selectedIndex,
          onIndexChanged: (i) => setState(() => _selectedIndex = i),
        ),
      ),
    );
  }
}

class _AppLayoutBody extends StatelessWidget {
  final String uid;
  final String email;
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const _AppLayoutBody({
    required this.uid,
    required this.email,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardPage(uid: uid, onStartAnalysis: () => onIndexChanged(1)),
      NewAnalysisPage(uid: uid),
      HistoryPage(uid: uid),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _Sidebar(
            email: email,
            selectedIndex: selectedIndex,
            onIndexChanged: onIndexChanged,
          ),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: pages[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String email;
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const _Sidebar({
    required this.email,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.health_and_safety, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),
              const Text(
                'BoneSight',
                style: TextStyle(
                  color: AppColors.primaryBrand,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            title: 'Dashboard',
            isSelected: selectedIndex == 0,
            onTap: () => onIndexChanged(0),
          ),
          _SidebarItem(
            icon: Icons.camera_alt_outlined,
            title: 'New Analysis',
            isSelected: selectedIndex == 1,
            onTap: () => onIndexChanged(1),
          ),
          _SidebarItem(
            icon: Icons.insert_chart_outlined,
            title: 'History',
            isSelected: selectedIndex == 2,
            onTap: () => onIndexChanged(2),
          ),
          const Spacer(),
          const Divider(height: 1, indent: 16, endIndent: 16),
          // Logged-in user info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryBrand.withValues(alpha: 0.1),
                  child: Text(
                    email.isNotEmpty ? email[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.primaryBrand,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    email,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _SidebarItem(
            icon: Icons.logout,
            title: 'Sign Out',
            isSelected: false,
            onTap: () => context.read<AuthCubit>().signOut(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBrand.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryBrand : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primaryBrand : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
