import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop/models/product.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shop/models/product_list.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _priceFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  final _imageUrlFocus = FocusNode();
  final _imageUrlControler = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _formData = Map<String, Object>();

  @override
  void initState() {
    super.initState();
    _imageUrlFocus.addListener(updateImage);
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocus.dispose();
    _descriptionFocus.dispose();
    _imageUrlFocus.removeListener(updateImage);
    _imageUrlFocus.dispose();
  }

  void updateImage() {
    setState(() {});
  }

  bool isValidImageUrl(String url) {
    bool isValidUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;
    bool endsWithFile = url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpge');

    return isValidUrl && endsWithFile;
  }

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }
    _formKey.currentState?.save();
    Provider.of<ProductList>(context, listen: false)
        .addProductFromData(_formData);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Formulário de Produto'),
        actions: [IconButton(onPressed: _submitForm, icon: Icon(Icons.save))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocus);
                  },
                  onSaved: (name) => _formData['name'] = name ?? '',
                  validator: (_name) {
                    final name = _name ?? '';
                    if (name.trim().isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    if (name.trim().length < 3) {
                      return 'Nome precisa no mínimo de 3 letras.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Preço',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  textInputAction: TextInputAction.next,
                  focusNode: _priceFocus,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocus);
                  },
                  onSaved: (price) =>
                      _formData['price'] = double.parse(price ?? '0'),
                  validator: (_price) {
                    final priceString = _price ?? '';
                    final price = double.tryParse(priceString) ?? -1;

                    if (price <= 0) {
                      return 'Informe um preço válido.';
                    }

                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  // textInputAction: TextInputAction.next,
                  focusNode: _descriptionFocus,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  onSaved: (description) =>
                      _formData['description'] = description ?? '',
                  validator: (_description) {
                    final description = _description ?? '';
                    if (description.trim().isEmpty) {
                      return 'Descrição é obrigatório';
                    }
                    if (description.trim().length < 10) {
                      return 'Descrição precisa no mínimo de 10 letras.';
                    }
                    return null;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Url da Imagem',
                          labelStyle: TextStyle(color: Colors.black),
                        ),
                        focusNode: _imageUrlFocus,
                        controller: _imageUrlControler,
                        onFieldSubmitted: (_) => _submitForm(),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.url,
                        onSaved: (imageUrl) =>
                            _formData['imageUrl'] = imageUrl ?? '',
                        validator: (_imageUrl) {
                          final imageUrl = _imageUrl ?? '';

                          if (!isValidImageUrl(imageUrl)) {
                            return 'Informe uma Url válida!';
                          }
                        },
                      ),
                    ),
                    Container(
                      height: 100,
                      width: 100,
                      margin: const EdgeInsets.only(
                        top: 10,
                        left: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: _imageUrlControler.text.isEmpty
                          ? const Text('Informe a Url')
                          : FittedBox(
                              child: Image.network(_imageUrlControler.text),
                              fit: BoxFit.cover,
                            ),
                    )
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
