import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';

class PDPScreen extends StatefulWidget {
  final ProductModel product;

  const PDPScreen({
    super.key,
    required this.product,
  });

  @override
  State<PDPScreen> createState() => _PDPScreenState();
}

class _PDPScreenState extends State<PDPScreen> {
  double _selectedQuantity = 0.5;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedQuantity = widget.product.minQuantity;
  }

  void _addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart(widget.product, _selectedQuantity);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to cart successfully!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    final isFavorite = productProvider.isFavorite(widget.product.id);
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? AppColors.error : AppColors.textPrimary,
                      ),
                      onPressed: () {
                        productProvider.toggleFavorite(widget.product.id);
                      },
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: widget.product.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: widget.product.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.restaurant,
                            size: 40,
                            color: AppColors.textLight,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Image Indicators
                  if (widget.product.images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.product.images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentImageIndex
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '₹${widget.product.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  '/${widget.product.unit}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.product.hasDiscount) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '₹${widget.product.originalPrice!.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textLight,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${widget.product.discountPercentage.round()}% OFF',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Rating
                      if (widget.product.rating > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.product.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    widget.product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quantity Selector
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (_selectedQuantity > widget.product.minQuantity) {
                              setState(() {
                                _selectedQuantity -= widget.product.minQuantity;
                              });
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${_selectedQuantity.toStringAsFixed(1)} ${widget.product.unit}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '₹${(widget.product.price * _selectedQuantity).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        GestureDetector(
                          onTap: () {
                            if (_selectedQuantity < widget.product.maxQuantity) {
                              setState(() {
                                _selectedQuantity += widget.product.minQuantity;
                              });
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Add to Cart Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomButton(
            onPressed: _addToCart,
            child: Text(
              'Add to Cart - ₹${(widget.product.price * _selectedQuantity).toStringAsFixed(0)}',
            ),
          ),
        ),
      ),
    );
  }
}