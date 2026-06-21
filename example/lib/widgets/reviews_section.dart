import 'package:flutter/material.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RATINGS & REVIEWS',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Average Rating Card
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '4.3',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '/5',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                      color: const Color(0xFFFFB300),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '124 Ratings',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 32),
            // Progress Bar Breakdown
            Expanded(
              child: Column(
                children: [
                  _buildRatingRow('5 ★', 0.65, context),
                  _buildRatingRow('4 ★', 0.20, context),
                  _buildRatingRow('3 ★', 0.08, context),
                  _buildRatingRow('2 ★', 0.04, context),
                  _buildRatingRow('1 ★', 0.03, context),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(color: Colors.white12),
        const SizedBox(height: 16),
        // Selected Reviews List
        _buildReviewCard(
          name: 'Nisha R.',
          rating: 5,
          date: '24 May 2026',
          title: 'Unmatched Vibe!',
          content:
              'This denim crop top looks so chic! The flared sleeves are beautiful. I was hesitant about the off-shoulder fit, but I used the SnapIT Virtual Try-on feature in the app and the size matching was spot on!',
        ),
        _buildReviewCard(
          name: 'Pooja K.',
          rating: 4,
          date: '10 May 2026',
          title: 'Premium Denim Quality',
          content:
              'Pure cotton denim fabric which feels soft on the skin and breathes well. The color matches the picture perfectly. Highly recommend!',
        ),
      ],
    );
  }

  Widget _buildRatingRow(
      String label, double percentage, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white54,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage > 0.5
                      ? Theme.of(context).primaryColor
                      : Colors.white54,
                ),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(fontSize: 11, color: Colors.white38),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required int rating,
    required String date,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white10,
                    child: Text(
                      name[0],
                      style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_user_rounded,
                      color: Colors.green, size: 14),
                ],
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 11, color: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    color: index < rating
                        ? const Color(0xFFFFB300)
                        : Colors.white12,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
                fontSize: 13, color: Colors.white60, height: 1.4),
          ),
        ],
      ),
    );
  }
}
