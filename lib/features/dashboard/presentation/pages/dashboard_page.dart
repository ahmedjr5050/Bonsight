import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bonssight/core/di/injection_container.dart';
import 'package:bonssight/core/theme/app_colors.dart';
import 'package:bonssight/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:bonssight/features/history/data/datasources/history_remote_data_source.dart';
import 'package:bonssight/features/history/presentation/pages/analysis_detail_page.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  final String uid;
  final VoidCallback onStartAnalysis;

  const DashboardPage({super.key, required this.uid, required this.onStartAnalysis});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl.get<DashboardCubit>(param1: uid),
      child: _DashboardView(uid: uid, onStartAnalysis: onStartAnalysis),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final String uid;
  final VoidCallback onStartAnalysis;
  const _DashboardView({required this.uid, required this.onStartAnalysis});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final isLoading = state is DashboardLoading || state is DashboardInitial;
        final loaded = state is DashboardLoaded ? state : null;

        return RefreshIndicator(
          onRefresh: () => context.read<DashboardCubit>().load(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to BoneSight AI',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your intelligent assistant for orthopedic diagnostics.',
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 40),

                // Stat cards
                Row(
                  children: [
                    _StatCard(
                      title: 'Total Scans',
                      value: isLoading ? '—' : '${loaded?.totalScans ?? 0}',
                      icon: Icons.fact_check_outlined,
                      color: Colors.blue,
                      isLoading: isLoading,
                    ),
                    const SizedBox(width: 24),
                    _StatCard(
                      title: 'Anomalies Detected',
                      value: isLoading ? '—' : '${loaded?.anomaliesDetected ?? 0}',
                      icon: Icons.troubleshoot,
                      color: Colors.orange,
                      isLoading: isLoading,
                    ),
                    const SizedBox(width: 24),
                    _StatCard(
                      title: 'Accuracy Rate',
                      value: '98.4%',
                      icon: Icons.verified_user_outlined,
                      color: Colors.green,
                      isLoading: false,
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // CTA banner
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBrand.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ready for a new analysis?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Upload a new X-Ray image and let our advanced AI model evaluate it for potential fractures in seconds.',
                              style: TextStyle(color: Colors.white70, fontSize: 15),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: onStartAnalysis,
                              icon: const Icon(Icons.rocket_launch, color: AppColors.primaryBrand),
                              label: const Text('Start AI Analysis Now'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primaryBrand,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                      const Icon(Icons.hub_outlined, size: 120, color: Colors.white24),
                    ],
                  ),
                ),

                // Recent analyses
                if (!isLoading && (loaded?.recentAnalyses.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 40),
                  const Text(
                    'Recent Analyses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...loaded!.recentAnalyses.map((item) => _RecentItem(
                        uid: uid,
                        item: item,
                        dataSource: sl<HistoryRemoteDataSource>(),
                      )),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoading
                    ? Container(
                        width: 60,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      )
                    : Text(
                        value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentItem extends StatelessWidget {
  final String uid;
  final Map<String, dynamic> item;
  final HistoryRemoteDataSource dataSource;

  const _RecentItem({required this.uid, required this.item, required this.dataSource});

  @override
  Widget build(BuildContext context) {
    final detections = (item['detections'] as List?) ?? [];
    final isSevere = detections.any((d) => (d as Map)['severity'] == 'Severe');
    final timestamp = item['timestamp'] as DateTime?;
    final dateStr = timestamp != null
        ? DateFormat('MMM d, yyyy • h:mm a').format(timestamp)
        : 'Unknown date';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AnalysisDetailPage(uid: uid, item: item, dataSource: dataSource),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSevere ? Colors.red.withValues(alpha: 0.2) : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSevere
                    ? Colors.red.withValues(alpha: 0.1)
                    : AppColors.primaryBrand.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.description_outlined,
                color: isSevere ? Colors.red.shade700 : AppColors.primaryBrand,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['imageName'] as String? ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateStr,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${detections.length} finding${detections.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSevere ? Colors.red.shade700 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
