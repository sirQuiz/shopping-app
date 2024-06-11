import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/add_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() {
    return _GroceryListState();
  }
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    var url = Uri.https('shopping-list-bfd27-default-rtdb.firebaseio.com', 'shopping-list.json');

    final response = await http.get(url);

    if(response.statusCode >= 400) {
      setState(() {
        _error = 'Faild to fetch data. PLease, try again later.';
      });
    }
    
    if(response.statusCode == 200) {
      final Map<String, dynamic> listLoaded = json.decode(response.body);
      final List<GroceryItem> loadedList = [];

      for(final item in listLoaded.entries) {
        var category = categories.entries.firstWhere((catElement) => catElement.value.title == item.value['category']).value;

        loadedList.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ));
      }

      setState(() {
        _groceryItems = loadedList;
        _isLoading = false;
      });
    }
  } 

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const AddItem(),
      ),
    );

    if(newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem groceryItem) {
    setState(() {
      _groceryItems.remove(groceryItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget startScreen = const Center(
        child: Text(
      'No grocery added',
      style: TextStyle(fontSize: 18),
    ));

    if(_isLoading) {
      startScreen = const Center(child: CircularProgressIndicator());
    }

    if(_error != null) {
      startScreen = Center(
        child: Text(_error!),
      );
    } 

    if(_groceryItems.isNotEmpty) {
      startScreen = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Grocories'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: startScreen,
    );
  }
}
