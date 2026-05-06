import 'package:flutter/material.dart';
import 'package:bonssight/core/theme/app_colors.dart';

class DashboardPage extends StatelessWidget {
  final VoidCallback onStartAnalysis;
  const DashboardPage({super.key, required this.onStartAnalysis});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to BoneSight AI 👋',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your intelligent assistant for orthopedic diagnostics. Get started by exploring your recent activity or analyzing a new scan.',
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 48),
          Row(
            children: const [
              _StatCard(title: 'Total Scans', value: '1,248', icon: Icons.fact_check_outlined, color: Colors.blue),
              SizedBox(width: 24),
              _StatCard(title: 'Anomalies Detected', value: '84', icon: Icons.troubleshoot, color: Colors.orange),
              SizedBox(width: 24),
              _StatCard(title: 'Accuracy Rate', value: '98.4%', icon: Icons.verified_user_outlined, color: Colors.green),
            ],
          ),
          const SizedBox(height: 48),
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
                 BoxShadow(color: AppColors.primaryBrand.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
              ]
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ready for a new analysis?',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Upload a new X-Ray image and let our advanced AI model evaluate it for potential fractures and anomalies in seconds.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: onStartAnalysis,
                        icon: const Icon(Icons.rocket_launch, color: AppColors.primaryBrand),
                        label: const Text('Start AI Analysis Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryBrand,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                const Icon(Icons.hub_outlined, size: 140, color: Colors.white54),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

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
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
