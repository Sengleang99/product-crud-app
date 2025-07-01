import 'package:product_app/data/models/product.dart';
import 'package:product_app/data/services/api_service.dart';

class ProductRepository {
  final ApiService appService;


  ProductRepository({required this.appService,});

    Future<List<Product>> getProducts({int? page, int? limit}) async {
    return await appService.fetchProducts(page: page, limit: limit);
  }
  Future<Product> getProductById(int id) => appService.fetchProductById(id);
  Future<Product> addProduct(Product product) => appService.addProduct(product);
  Future<Product> updateProduct(Product product) =>
      appService.updateProduct(product);
  Future<void> deleteProduct(int id) => appService.deleteProduct(id);
}
