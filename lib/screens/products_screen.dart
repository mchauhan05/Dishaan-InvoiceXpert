import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../utils/barcode_utils.dart';
import '../widgets/header.dart';
import '../widgets/sidebar.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final allProducts = productProvider.products;
    final categories = productProvider.categories;

    // Filter products
    List<Product> filteredProducts = allProducts;

    // Apply category filter
    if (_selectedCategory != null) {
      filteredProducts = filteredProducts.where((p) => p.category == _selectedCategory).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowercaseQuery = _searchQuery.toLowerCase();
      filteredProducts = filteredProducts.where((p) =>
        p.name.toLowerCase().contains(lowercaseQuery) ||
        p.description.toLowerCase().contains(lowercaseQuery) ||
        p.sku.toLowerCase().contains(lowercaseQuery) ||
        p.barcode.contains(_searchQuery)
      ).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: Row(
        children: [
          // Sidebar
          Sidebar(currentRoute: '/products'),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                const Header(),

                // Products content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Page title and actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Products & Services',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Row(
                              children: [
                                // Scan barcode button
                                OutlinedButton.icon(
                                  onPressed: () => _scanBarcode(context),
                                  icon: const Icon(Icons.qr_code_scanner),
                                  label: const Text('Scan Barcode'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryBlue,
                                    side: BorderSide(color: AppColors.primaryBlue),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Add product button
                                ElevatedButton.icon(
                                  onPressed: () => _showAddProductDialog(context),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Product'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Filters and search
                        Row(
                          children: [
                            // Category filter
                            Container(
                              width: 200,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.borderGray),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String?>(
                                  value: _selectedCategory,
                                  hint: Text(
                                    'All Categories',
                                    style: TextStyle(color: AppColors.textGray),
                                  ),
                                  icon: Icon(Icons.arrow_drop_down, color: AppColors.textGray),
                                  isExpanded: true,
                                  items: [
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('All Categories'),
                                    ),
                                    ...categories.map((category) => DropdownMenuItem<String?>(
                                      value: category,
                                      child: Text(category),
                                    )),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Search box
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search by name, SKU, or barcode',
                                  prefixIcon: Icon(Icons.search, color: AppColors.textGray),
                                  suffixIcon: _searchQuery.isNotEmpty ?
                                    IconButton(
                                      icon: Icon(Icons.clear, color: AppColors.textGray),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                    ) : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(color: AppColors.borderGray),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Products table
                        Expanded(
                          child: filteredProducts.isEmpty
                            ? _buildEmptyState()
                            : _buildProductsTable(filteredProducts),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.textGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 8),
          if (_searchQuery.isNotEmpty || _selectedCategory != null)
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
              ),
            )
          else
            Text(
              'Add your first product to get started',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
              ),
            ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty && _selectedCategory == null)
            ElevatedButton.icon(
              onPressed: () => _showAddProductDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsTable(List<Product> products) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'PRODUCT/SERVICE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'SKU',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'BARCODE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'PRICE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'STOCK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 40),
              ],
            ),
          ),

          // Product items
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: products.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: AppColors.borderGray,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductItem(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return InkWell(
      onTap: () => _showProductDetails(context, product),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Product name & description
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  // Image or icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: product.type == ProductType.service
                        ? Icon(Icons.build_outlined, color: AppColors.textGray)
                        : Icon(Icons.inventory_2_outlined, color: AppColors.textGray),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.description,
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // SKU
            Expanded(
              flex: 1,
              child: Text(
                product.sku,
                style: const TextStyle(
                  fontFamily: 'monospace',
                ),
              ),
            ),

            // Barcode
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Text(
                    product.formattedBarcode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _showBarcodeDialog(context, product),
                    child: Icon(
                      Icons.qr_code,
                      color: AppColors.primaryBlue,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Expanded(
              flex: 1,
              child: Text(
                '\$${product.sellingPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ),

            // Stock
            Expanded(
              flex: 1,
              child: Center(
                child: product.type == ProductType.service
                ? Text(
                    'N/A',
                    style: TextStyle(
                      color: AppColors.textGray,
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.stockStatusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.stockStatus,
                      style: TextStyle(
                        color: product.stockStatusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ),
            ),

            // Actions
            SizedBox(
              width: 40,
              child: IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.textGray,
                ),
                onPressed: () => _showProductOptions(context, product),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods to keep the code shorter
  void _scanBarcode(BuildContext context) async {
    final result = await BarcodeUtils.scanBarcode(context);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scanned barcode: $result')),
      );
    }
  }

  void _showAddProductDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add product functionality coming soon')),
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product details functionality coming soon')),
    );
  }

  void _showBarcodeDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Barcode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BarcodeUtils.buildBarcodeWidget(product.barcode, width: 300, height: 120),
            const SizedBox(height: 16),
            Text(
              product.formattedBarcode,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'monospace',
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${BarcodeUtils.getBarcodeType(product.barcode)}',
              style: TextStyle(
                color: AppColors.textGray,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showProductOptions(BuildContext context, Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product options functionality coming soon')),
    );
  }
}
