import 'package:flutter/foundation.dart';

class CartItem {
  String id;
  String title;
  double price;
  int quantity;

  CartItem({
    this.id,
    this.title,
    this.price,
    this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  double get totalAmount{
    double total = 0.0;
    _items.forEach((key,value){
      total += value.price * value.quantity;
    });
    return total;
  }

  int get itemCount{
    return _items.length;
  }

  void removeById(String id){
    _items.remove(id);
    notifyListeners();
  }

  void clear(){
    _items = {};
    notifyListeners();
  }

  void removeSingleItem(productId){
    if(!_items.containsKey(productId))
      return;
    if(_items[productId].quantity > 1){
      _items.update(productId, (cartItem){
        return CartItem(
          id: cartItem.id,
          title: cartItem.title,
          price: cartItem.price,
          quantity: cartItem.quantity - 1,
        );
      },);
    }else{
      _items.remove(productId);
    }
    notifyListeners();
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (item) {
          return CartItem(
            id: item.id,
            title: item.title,
            price: item.price,
            quantity: item.quantity + 1,
          );
        },
      );
    } else {
      _items.putIfAbsent(productId, () {
        return CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        );
      });
    }
    notifyListeners();
  }
}
