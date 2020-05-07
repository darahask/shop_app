import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/widgets/product_item.dart';
import '../providers/products.dart';

class ProductsGrid extends StatelessWidget {
  final int value;
  ProductsGrid(this.value);
  @override
  Widget build(BuildContext context) {
    final List<Product> listOfProducts =
        (value == 0)?Provider.of<Products>(context).listProducts.where((item)=>item.isFavorite).toList():
        Provider.of<Products>(context).listProducts;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: listOfProducts.length,
      itemBuilder: (BuildContext context, int i) {
        return ChangeNotifierProvider.value(
          value:listOfProducts[i],
          child: ProductItem(
          ),
        );
      },
    );
  }
}
