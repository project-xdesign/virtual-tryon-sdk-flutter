import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snapit_sdk/snapit_sdk.dart';
import 'package:path_provider/path_provider.dart';

import '../config.dart';
import '../models/product.dart';
import '../widgets/product_carousel.dart';
import '../widgets/size_selector.dart';
import '../widgets/reviews_section.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = "S";
  bool _isWishlisted = false;

  /// Core logic to launch the try-on flow directly using the pre-hosted garment URL.
  void _handleVirtualTryOn() {
    _launchSDKFlow(widget.product.images[0]);
  }

  Future<void> _downloadResultImage(String url) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to download image. Status: ${response.statusCode}');
      }
      final bytes = await response
          .fold<List<int>>([], (list, element) => list..addAll(element));

      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          downloadDir = await getDownloadsDirectory();
        }
      } else {
        downloadDir = await getDownloadsDirectory();
      }

      if (downloadDir == null) {
        throw Exception('Could not find downloads directory');
      }

      final filename = 'tryon_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${downloadDir.path}/$filename');
      await file.writeAsBytes(bytes);

      if (Platform.isAndroid) {
        try {
          const channel =
              MethodChannel('com.example.fashion_ecommerce_sample/media_scan');
          await channel.invokeMethod('scanFile', {'path': file.path});
        } catch (e) {
          debugPrint('Failed to scan file via MethodChannel: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image downloaded to: ${file.path}'),
            backgroundColor: Colors.green[800],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      rethrow;
    }
  }

  void _launchSDKFlow(String garmentUrl) {
    SnapIT.launchTryOnFlow(
      context: context,
      apiKey: SnapITConfig.apiKey,
      userId: SnapITConfig.userId,
      garmentImageUrl: garmentUrl,
      productId: widget.product.id,
      modelName: SnapITConfig.modelName,
      version: SnapITConfig.version,
      onDownloadImage: _downloadResultImage,
      metadata: {
        'selected_size': _selectedSize,
        'source': 'flutter_sample_ecommerce',
      },
      theme: SnapITTheme(
        primaryColor: Theme.of(context).primaryColor,
        backgroundColor: const Color(0xFF0A0A0C),
        cardColor: const Color(0xFF16161A),
        borderRadius: 16.0,
      ),
      onSuccess: (resultImageUrl, generationId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Generation Completed Successfully!'),
              ],
            ),
            backgroundColor: Colors.green[800],
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      },
      onFailure: (errorMessage) {
        _showErrorDialog(errorMessage);
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16161A),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('VTON Integration Error'),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Premium Product Header Image Bar
              SliverAppBar(
                expandedHeight: 440,
                pinned: true,
                stretch: true,
                backgroundColor: const Color(0xFF0A0A0C),
                leading: IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined,
                        color: Colors.white),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: ProductCarousel(images: widget.product.images),
                ),
              ),

              // Product Info Body List
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand and Rating Line
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.product.brand,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                color: Colors.white70,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${widget.product.rating}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.star_rounded,
                                      color: Color(0xFFFFB300), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '| ${widget.product.reviewsCount}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white38),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: -0.05, end: 0),

                        const SizedBox(height: 8),

                        // Title
                        Text(
                          widget.product.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                            color: Colors.white70,
                          ),
                        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                        const SizedBox(height: 16),

                        // Pricing Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹${widget.product.price.toInt()}',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'MRP ₹${widget.product.originalPrice.toInt()}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white38,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '(${widget.product.discountPercentage}% OFF)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[400],
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                        const SizedBox(height: 8),
                        const Text(
                          'inclusive of all taxes',
                          style: TextStyle(fontSize: 11, color: Colors.white38),
                        ),

                        const SizedBox(height: 24),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 16),

                        // Size Selector
                        SizeSelector(
                          sizes: const ['XS', 'S', 'M', 'L', 'XL'],
                          onSizeSelected: (size) {
                            _selectedSize = size;
                          },
                        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                        const SizedBox(height: 24),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 16),

                        // Product Details Section
                        const Text(
                          'PRODUCT DETAILS',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...widget.product.details.entries
                            .map((e) => _buildDetailRow(e.key, e.value)),

                        const SizedBox(height: 24),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 16),

                        // Reviews & Ratings
                        const ReviewsSection()
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 400.ms),

                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ],
      ),

      // Fixed bottom action bar (Wishlist, Try-On CTA, Buy)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0C),
          border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Wishlist Button
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _isWishlisted ? Colors.red : Colors.white,
                    side: BorderSide(
                      color: _isWishlisted ? Colors.red : Colors.white24,
                    ),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      _isWishlisted = !_isWishlisted;
                    });
                  },
                  child: Icon(
                    _isWishlisted
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Virtual Try-On SDK CTA (Visual standout highlight)
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                      label: const Text(
                        'TRY ON',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                      onPressed: _handleVirtualTryOn,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Buy Now / Add to Bag Button
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'BUY NOW',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              name,
              style: const TextStyle(fontSize: 13, color: Colors.white38),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
