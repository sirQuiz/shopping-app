import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() {
    return _AddItem();
  }
}

class _AddItem extends State<AddItem> {
  final _formKey        = GlobalKey<FormState>();
  var _enteredTitle     = '';
  var _enteredQuantity  = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending        = false;

  void _saveItem() async {
    if(_formKey.currentState!.validate()) {

      setState(() {
        _isSending = true;
      });

      _formKey.currentState!.save();
      var url = Uri.https('shopping-list-bfd27-default-rtdb.firebaseio.com', 'shopping-list.json');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json'
        },
        body:
          json.encode(
            {
              'name': _enteredTitle,
              'quantity': _enteredQuantity,
              'category': _selectedCategory.title,
            },
          ),
      );

      final Map<String, dynamic> responseDecoded = json.decode(response.body);

      if(!context.mounted) {
        return;
      }
      
      Navigator.of(context).pop(
        GroceryItem(
          id: responseDecoded['name'],
          name: _enteredTitle,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between from 1 to 50 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredTitle = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      initialValue: '1',
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must a positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for(final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 15,
                                  height: 15,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending ? null : _resetForm,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
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