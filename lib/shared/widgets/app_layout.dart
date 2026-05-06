import 'package:flutter/material.dart';
import 'package:bonssight/core/theme/app_colors.dart';
import 'package:bonssight/features/analysis/presentation/pages/new_analysis_page.dart';
import 'package:bonssight/features/history/presentation/pages/history_page.dart';
import 'package:bonssight/features/dashboard/presentation/pages/dashboard_page.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _selectedIndex = 1; // 1 is New Analysis

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardPage(onStartAnalysis: () {
        setState(() {
          _selectedIndex = 1;
        });
      }),
      const NewAnalysisPage(),
      const HistoryPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _Sidebar(
            selectedIndex: _selectedIndex,
            onIndexChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const _Sidebar({
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Logo
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
          color: isSelected ? AppColors.primaryBrand.withOpacity(0.1) : Colors.transparent,
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
