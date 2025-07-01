import 'package:product_app/presentation/products/add_product_page.dart';
import 'package:product_app/presentation/products/edit_product_page.dart';
import 'package:product_app/presentation/products/product_list_page.dart';

class Routes {
  static const String productList = '/';
  static const String addProduct = '/add-product';
  static const String editProduct = '/edit-product';

  static final routes = {
    productList: (context) => const ProductListPage(),
    addProduct: (context) => const AddProductPage(),
    editProduct: (context) => const EditProductPage(),
  };
}
