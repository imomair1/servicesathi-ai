import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../data/mock_data.dart';
import '../widgets/provider_card.dart';

class ProviderRecommendationScreen extends StatelessWidget {
  final VoidCallback onBook;
  final VoidCallback onBack;

  const ProviderRecommendationScreen({
    super.key,
    required this.onBook,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final providers = MockData.providers;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: onBack,
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'AI Recommendations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A2D5A), Color(0xFF2D1B69)],
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.filter_list, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      'Filter',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Summary
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success.withOpacity(isDark ? 0.15 : 0.08),
                    AppColors.electricBlue.withOpacity(isDark ? 0.1 : 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology_rounded,
                      color: AppColors.success, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Found ${providers.length} best matches',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ranked by rating, distance, price & availability',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Provider List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ProviderCard(
                    provider: providers[index],
                    rank: index + 1,
                    onBook: onBook,
                  );
                },
                childCount: providers.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
