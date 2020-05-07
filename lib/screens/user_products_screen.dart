import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProducts extends StatelessWidget {
  static final String routeName = '/userproducts';

  Future<void> _refreshProducts(BuildContext context) async{
    await Provider.of<Products>(context).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context).listProducts;
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Manage Products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, EditProducts.routeName);
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: (){
          return _refreshProducts(context);
        },
        child: ListView.builder(
          itemBuilder: (_, index) {
            return UserProduct(
              products[index].id,
              products[index].title,
              products[index].imageUrl,
            );
          },
          itemCount: products.length,
        ),
      ),
    );
  }
}
