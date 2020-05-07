import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProducts extends StatefulWidget {
  static final String routeName = '/editproducts';

  @override
  _EditProductsState createState() => _EditProductsState();
}

class _EditProductsState extends State<EditProducts> {
  final _priceFocus = FocusNode();
  final _descFocus = FocusNode();
  final _imgController = TextEditingController();
  final _imgFocus = FocusNode();
  final _form = GlobalKey<FormState>();
  Product _product =
      Product(id: null, title: '', price: 0, description: '', imageUrl: '');
  var _initValues = {
    'id': null,
    'title': '',
    'price': '',
    'description': '',
  };
  bool isLoading = false;

  @override
  void initState() {
    _imgFocus.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final id = ModalRoute.of(context).settings.arguments as String;
    if (id != null) {
      _product = Provider.of<Products>(context).findProductById(id);
      _initValues = {
        'id': _product.id,
        'title': _product.title,
        'price': _product.price.toString(),
        'description': _product.description,
      };
      _imgController.text = _product.imageUrl;
    }
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imgFocus.hasFocus) {
      setState(() {});
    }
  }

  void saveForm() async{
    setState(() {
      isLoading = true;
    });
    final validate = _form.currentState.validate();
    if (!validate) {
      return;
    }
    _form.currentState.save();
    if (_product.id != null) {
      await Provider.of<Products>(context, listen: false)
          .editProduct(_product.id, _product);
      setState(() {
        isLoading = false;  
      });
      Navigator.of(context).pop();
    } else {
      Provider.of<Products>(context, listen: false)
          .addProduct(_product)
          .catchError(
        (error) {
          showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Something went Wrong'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Okay'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
        },
      ).then((_) {
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              saveForm();
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _initValues['title'],
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocus);
                },
                onSaved: (t) {
                  _product = Product(
                    id: _product.id,
                    title: t,
                    description: _product.description,
                    price: _product.price,
                    imageUrl: _product.imageUrl,
                  );
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please Enter data';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initValues['price'],
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                focusNode: _priceFocus,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descFocus);
                },
                onSaved: (t) {
                  _product = Product(
                    id: _product.id,
                    title: _product.title,
                    description: _product.description,
                    price: double.parse(t),
                    imageUrl: _product.imageUrl,
                  );
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please Enter Value';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initValues['description'],
                decoration: InputDecoration(labelText: 'Description'),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                textInputAction: TextInputAction.next,
                focusNode: _descFocus,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_imgFocus);
                },
                onSaved: (t) {
                  _product = Product(
                    id: _product.id,
                    title: _product.title,
                    description: t,
                    price: _product.price,
                    imageUrl: _product.imageUrl,
                  );
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter data';
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    child: _imgController.text.isEmpty
                        ? Text('Enter a URL')
                        : FittedBox(
                            child: Image.network(
                              _imgController.text,
                              fit: BoxFit.fill,
                            ),
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Image URL'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imgController,
                      focusNode: _imgFocus,
                      onSaved: (t) {
                        _product = Product(
                          id: _product.id,
                          title: _product.title,
                          description: _product.description,
                          price: _product.price,
                          imageUrl: t,
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter data';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
