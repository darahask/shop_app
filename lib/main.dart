import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/cart_details.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/order_screen.dart';
import 'package:shop_app/screens/product_detail.dart';
import 'package:shop_app/screens/product_overview_screen.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/user_products_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Products(),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProvider.value(
          value: Orders(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            primarySwatch: Colors.purple),
        home: ProductsOverviewScreen(),
        routes: {
            ProductDetail.routeName: (ctx) => ProductDetail(),
            CartDetails.routeName: (ctx) => CartDetails(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProducts.routeName:(ctx) => UserProducts(),
            EditProducts.routeName:(ctx) => EditProducts(),
          },
      ),
    );
  }
}
