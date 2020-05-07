import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [];
  String _token;
  String _userId;

  void updateItems(token,items,userid){
    _token = token;
    _items = items;
    _userId = userid;
    notifyListeners();
  }

  List<Product> get listProducts {
    return [..._items];
  }

  Product findProductById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$_userId"' : '';
    var url =
        'https://dummy-80ba4.firebaseio.com/products.json?auth=$_token&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://dummy-80ba4.firebaseio.com/userFavorites/$_userId.json?auth=$_token';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        "https://dummy-80ba4.firebaseio.com/products/$id.json?auth=$_token";
    final index = _items.indexWhere((p) => p.id == id);
    var prod = _items[index];
    _items.removeAt(index);
    notifyListeners();
    var response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(index, prod);
      notifyListeners();
      throw HttpException('Couldnt delete product');
    }
    prod = null;
  }

  Future<void> editProduct(String id, Product product) async {
    final index = _items.indexWhere((p) => (p.id == id));
    if (index >= 0) {
      final url =
          "https://dummy-80ba4.firebaseio.com/products/$id.json?auth=$_token";
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
    final url = 'https://dummy-80ba4.firebaseio.com/products.json?auth=$_token';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': _userId,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
