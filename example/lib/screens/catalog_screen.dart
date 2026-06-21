import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '../models/product.dart';
import 'product_detail_screen.dart';
import 'setup_credentials_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  Widget _buildNetworkImage(String url,
      {required double width, required double height}) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: width,
      height: height,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Shimmer.fromColors(
          baseColor: Colors.white.withValues(alpha: 0.05),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Container(
            color: Colors.black,
            width: width,
            height: height,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.white.withValues(alpha: 0.05),
          width: width,
          height: height,
          child: const Icon(Icons.broken_image_outlined,
              color: Colors.white24, size: 30),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const products = Product.sampleProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'A U R A',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 6.0,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SetupCredentialsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [


            // Product Grid
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF16161A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image with Try-On tag
                            Expanded(
                              child: Stack(
                                children: [
                                  _buildNetworkImage(
                                    product.images[0],
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                  // Live Try On Tag
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: Colors.black
                                              .withValues(alpha: 0.7),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.5),
                                              width: 0.5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.2),
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            )
                                          ]),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.auto_awesome_rounded,
                                            size: 10,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'TRY ON LIVE',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Product details footer inside Card
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Brand and rating row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        product.brand,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white54,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${product.rating}',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white38),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(Icons.star_rounded,
                                              color: Color(0xFFFFB300),
                                              size: 10),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  // Product Title
                                  Text(
                                    product.title,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),

                                  // Prices Row
                                  Row(
                                    children: [
                                      Text(
                                        '₹${product.price.toInt()}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '₹${product.originalPrice.toInt()}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white38,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${product.discountPercentage}% OFF',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (index * 100).ms, duration: 400.ms)
                        .slideY(begin: 0.05, end: 0);
                  },
                  childCount: products.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
