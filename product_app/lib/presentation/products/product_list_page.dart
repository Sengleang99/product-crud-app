import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:product_app/data/models/product.dart';
import 'package:product_app/presentation/providers/product_provider.dart';
import 'package:product_app/presentation/widgets/loading_indicator.dart';
import 'package:product_app/presentation/widgets/product_card.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:product_app/app/route.dart';
import 'package:path_provider/path_provider.dart'; 
import 'package:open_filex/open_filex.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final RefreshController _refreshController = RefreshController();

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initially load products when the page loads
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  /// Handle search input changes with debounce
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ProductProvider>().searchProducts(query);
      _sortProducts(); // Re-sort after search
    });
  }

  /// Sort products based on selected criteria
  void _sortProducts() {
    final productProvider = context.read<ProductProvider>();
    productProvider.sortProducts(_sortBy, _sortAscending);
  }

  /// Load more products when the user scrolls to the bottom
  Future<void> _loadMoreProducts() async {
    final productProvider = context.read<ProductProvider>();
    if (!(productProvider.isLoadingMore)) {
      await productProvider.loadMoreProducts();
    }
  }

  /// Export products to PDF
  Future<void> _exportToPDF(List<Product> productsToExport) async {
    // Create a new PDF document.
    final PdfDocument document = PdfDocument();
    // Add a page to the document.
    final PdfPage page = document.pages.add();
    // Create a PDF grid.
    final PdfGrid grid = PdfGrid();

    // Specify the columns.
    grid.columns.add(count: 4);
    // Add a header row.
    grid.headers.add(1);

    // Set header row values.
    final PdfGridRow headerRow = grid.headers[0];
    headerRow.cells[0].value = 'Name';
    headerRow.cells[1].value = 'Price';
    headerRow.cells[2].value = 'Stock';
    headerRow.cells[3].value = 'ID';

    // Add rows to the grid.
    for (final product in productsToExport) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = product.name;
      row.cells[1].value = '\$${product.price.toStringAsFixed(2)}';
      row.cells[2].value = product.stock.toString();
      row.cells[3].value = product.id.toString(); // Ensure ID is string
    }

    // Draw the grid on the page.
    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(
          0, 0, page.getClientSize().width, page.getClientSize().height),
    );

    // Save the document.
    final List<int> bytes = await document.save();
    // Dispose the document.
    document.dispose();

    // Get the temporary directory to save the file.
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/products.pdf';
    final file = File(path);
    await file.writeAsBytes(bytes);

    if (mounted) {
      // Show a snackbar and try to open the file.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to PDF at $path')),
      );
      await OpenFilex.open(path);
    }
  }

  /// Export products to CSV
  Future<void> _exportToCSV(List<Product> productsToExport) async {
    final StringBuffer csv = StringBuffer();
    // Add CSV header.
    csv.writeln('Name,Price,Stock,ID');

    // Add product data to CSV.
    for (final product in productsToExport) {
      csv.writeln(
          '${_csvEscape(product.name)},${product.price.toStringAsFixed(2)},${product.stock},${product.id}');
    }

    // Get the temporary directory to save the file.
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/products.csv';
    final file = File(path);
    await file.writeAsString(csv.toString());

    if (mounted) {
      // Show a snackbar and try to open the file.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to CSV at $path')),
      );
      await OpenFilex.open(path);
    }
  }

  // Helper function to escape strings for CSV
  String _csvEscape(String? field) {
    if (field == null) return '';
    // If the field contains a comma, double quote, or newline, enclose it in double quotes.
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<ProductProvider>().deleteProduct(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final displayedProducts = productProvider.filteredProducts;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product List'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Navigate to add product page and refresh upon return
                Navigator.pushNamed(context, Routes.addProduct).then((_) {
                  // This callback is executed when the add product screen is popped
                  productProvider.loadProducts(
                      isRefresh: true); // Force a refresh
                });
              },
              tooltip: 'Add Product',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'pdf') {
                  _exportToPDF(displayedProducts);
                } else if (value == 'csv') {
                  _exportToCSV(displayedProducts);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'pdf',
                  child: Text('Export to PDF'),
                ),
                const PopupMenuItem(
                  value: 'csv',
                  child: Text('Export to CSV'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // Sort and filter controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  const Text('Sort by:'),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _sortBy,
                    items: const [
                      DropdownMenuItem(value: 'name', child: Text('Name')),
                      DropdownMenuItem(value: 'price', child: Text('Price')),
                      DropdownMenuItem(value: 'stock', child: Text('Stock')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                        _sortProducts();
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                    ),
                    onPressed: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                        _sortProducts();
                      });
                    },
                    tooltip: 'Sort direction',
                  ),
                ],
              ),
            ),

            // Product list
            Expanded(
              child: productProvider.isLoading && displayedProducts.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : productProvider.error.isNotEmpty
                      ? Center(child: Text('Error: ${productProvider.error}'))
                      : displayedProducts.isEmpty
                          ? const Center(child: Text('No products found'))
                          : SmartRefresher(
                              controller: _refreshController,
                              onRefresh: () async {
                                await productProvider.loadProducts(
                                    isRefresh: true);
                                _refreshController.refreshCompleted();
                                // After refresh, re-apply search and sort if any
                                _onSearchChanged(_searchController.text);
                                _sortProducts();
                              },
                              // Ensure hasMoreProducts is not null before using it
                              enablePullUp: productProvider.hasMoreProducts,
                              onLoading: () async {
                                await _loadMoreProducts();
                                _refreshController.loadComplete();
                              },
                              child: ListView.builder(
                                itemCount: displayedProducts.length +
                                    // Ensure isLoadingMore is not null before using it
                                    ((productProvider.isLoadingMore) ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == displayedProducts.length) {
                                    return const LoadingIndicator();
                                  }
                                  final product = displayedProducts[index];
                                  return ProductCard(
                                    product: product,
                                    onEdit: () {
                                      // Navigate to edit product page
                                      Navigator.pushNamed(
                                        context,
                                        Routes.editProduct,
                                        arguments: product,
                                      ).then((_) {
                                        // Refresh products after returning from edit
                                        productProvider.loadProducts(
                                            isRefresh: true);
                                      });
                                    },
                                    onDelete: () {
                                      if (product.id != null) {
                                        _confirmDelete(context, product.id!);
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
