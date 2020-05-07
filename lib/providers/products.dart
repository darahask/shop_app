import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get listProducts {
    return [..._items];
  }

  Product findProductById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  Future<void> fetchProducts() async {
    const url = "https://dummy-80ba4.firebaseio.com/products.json";
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<Product> loadedProducts = [];
      extractedData.forEach((key, value) {
        loadedProducts.add(Product(
          id: key,
          title: value['title'],
          price: value['price'],
          description: value['description'],
          isFavorite: value['isFavourite'],
          imageUrl: value['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = "https://dummy-80ba4.firebaseio.com/products/$id.json";
    final index = _items.indexWhere((p) => p.id == id);
    var prod = _items[index];
    _items.removeAt(index);
    notifyListeners();
    var response = await http.delete(url);
    if(response.statusCode >= 400){
      _items.insert(index, prod);
      notifyListeners();
      throw HttpException('Couldnt delete product');
    }
    prod = null;
  }

  Future<void> editProduct(String id, Product product) async {
    final index = _items.indexWhere((p) => (p.id == id));
    if (index >= 0) {
      final url = "https://dummy-80ba4.firebaseio.com/products/$id.json";
      await http.patch(
        url,
        body: json.encode(
          {
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
          },
        ),
      );
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    const url = "https://dummy-80ba4.firebaseio.com/products.json";
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'isFavourite': false,
            'imageUrl': product.imageUrl,
          },
        ),
      );

      final myproduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(myproduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
