class Product {
  final String id;
  final String brand;
  final String title;
  final double price;
  final double originalPrice;
  final int discountPercentage;
  final List<String> images;
  final Map<String, String> details;
  final double rating;
  final int reviewsCount;

  const Product({
    required this.id,
    required this.brand,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.discountPercentage,
    required this.images,
    required this.details,
    required this.rating,
    required this.reviewsCount,
  });

  static const List<Product> sampleProducts = [
    Product(
      id: 'pid-1',
      brand: 'AURA LUXE',
      title: 'Elegant Green A-Line Dress',
      price: 1499,
      originalPrice: 2999,
      discountPercentage: 50,
      images: [
        'https://images.unsplash.com/flagged/photo-1585052201332-b8c0ce30972f?q=80&w=435&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      details: {
        'Fabric': 'Polyester',
        'Type': 'A-Line Dress',
        'Sleeve Style': 'Sleeveless',
        'Neckline': 'Round Neck',
        'Pattern': 'Solid',
        'Length': 'Maxi length',
        'Transparency': 'Opaque',
      },
      rating: 4.5,
      reviewsCount: 142,
    ),
    Product(
      id: 'pid-2',
      brand: 'AURA TRENDS',
      title: 'Classic White Net Top',
      price: 699,
      originalPrice: 1399,
      discountPercentage: 50,
      images: [
        'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?q=80&w=405&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      details: {
        'Fabric': 'Net / Mesh',
        'Type': 'Net Top',
        'Sleeve Style': 'Long Sleeves',
        'Neckline': 'Mock Neck',
        'Pattern': 'Self-Design',
        'Length': 'Regular length',
        'Transparency': 'Semi-Transparent',
      },
      rating: 4.2,
      reviewsCount: 88,
    ),
  ];
}
