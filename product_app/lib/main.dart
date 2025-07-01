import 'package:flutter/material.dart';
import 'package:product_app/app/app.dart';
import 'package:product_app/data/services/api_service.dart';
import 'package:product_app/data/repositories/product_repository.dart';
import 'package:product_app/presentation/providers/product_provider.dart';
import 'package:provider/provider.dart';

void main() {
  // ApiService instance
  final apiService = ApiService();

  // ProductRepository
  final repository = ProductRepository(appService: apiService);

  // Provide it to ProductProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(repository: repository),
        ),
      ],
      child: const App(),
    ),
  );
}
