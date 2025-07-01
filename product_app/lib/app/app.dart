import 'package:flutter/material.dart';
import 'package:product_app/app/route.dart';
import 'package:product_app/core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: Routes.productList,
      routes: Routes.routes,
    );
  }
}
