import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';
import '../utils/app_colors.dart';
import '../widgets/product_card.dart';
import 'PDP.dart';

class PLPScreen extends StatefulWidget {
  final String? category;
  final String? searchQuery;

  const PLPScreen({
    super.key,
    this.category,
    this.searchQuery,
  });

  @override
  State<PLPScreen> createState() => _PLPScreenState();
}

class _PLPScreenState extends State<PLPScreen> {
  final _searchController = TextEditingController();
  String _sortBy = 'name';
  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFilteredProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    List<ProductModel> products;
    
    if (widget.category != null) {
      products = productProvider.getProductsByCategory(widget.category!);
    } else if (_searchController.text.isNotEmpty) {
      products = productProvider.searchProducts(_searchController.text);
    } else {
      products = productProvider.products;
    }
    
    // Sort products
    switch (_sortBy) {
      case 'price_low':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        products.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
      default:
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    
    setState(() {
      _filteredProducts = products;
    });
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort by'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption('Name', 'name'),
            _buildSortOption('Price: Low to High', 'price_low'),
            _buildSortOption('Price: High to Low', 'price_high'),
            _buildSortOption('Rating', 'rating'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String value) {
    return ListTile(
      title: Text(title),
      leading: Radio<String>(
        value: value,
        groupValue: _sortBy,
        onChanged: (String? newValue) {
          setState(() {
            _sortBy = newValue!;
          });
          _updateFilteredProducts();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.category ?? 
                  (widget.searchQuery != null ? 'Search Results' : 'All Products');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          if (widget.category == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onChanged: (value) {
                    _updateFilteredProducts();
                  },
                ),
              ),
            ),
          
          // Products Count and Sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredProducts.length} products found',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Sorted by: ${_getSortDisplayName()}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          
          // Products Grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try searching with different keywords',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PDPScreen(product: product),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getSortDisplayName() {
    switch (_sortBy) {
      case 'price_low':
        return 'Price (Low to High)';
      case 'price_high':
        return 'Price (High to Low)';
      case 'rating':
        return 'Rating';
      case 'name':
      default:
        return 'Name';
    }
  }
}