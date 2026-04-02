import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class TestimonialsScreen extends StatelessWidget {
  const TestimonialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final testimonials = [
      _Testimonial('Best property monitoring service in India highly reliable.', 'Property Owner, Bangalore', 5),
      _Testimonial('Excellent NRI property management and reporting service.', 'NRI Client, USA', 5),
      _Testimonial('Professional team, transparent process. Highly recommended.', 'Investor, Mumbai', 5),
    ];

    return SafeArea(child: Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real Results from Property Owners & NRIs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            ...testimonials.map((t) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          t.stars,
                          (_) => const Icon(Icons.star, color: Colors.amber, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '"${t.quote}"',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '- ${t.author}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    ));
  }
}

class _Testimonial {
  final String quote;
  final String author;
  final int stars;

  _Testimonial(this.quote, this.author, this.stars);
}
