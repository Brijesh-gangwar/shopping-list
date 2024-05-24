import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/widgets/new_item.dart';


import '../models/grocery_item.dart';
import 'package:http/http.dart' as http;

class Grocerylist extends StatefulWidget {
  const Grocerylist({super.key});

  @override
  State<Grocerylist> createState() => _GrocerylistState();
}

class _GrocerylistState extends State<Grocerylist> {
  List<GroceryItem> _groceryItems = [];
  String? _error;

  bool isloading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    try {
      final url = await Uri.https(
          'api-app-92477-default-rtdb.firebaseio.com', 'shopping-list.json');

      final response = await http.get(url);

      if (response.body == 'null') {
        setState(() {
          isloading = false;
        });
        return;
      }

      final Map<String, dynamic> Listdata = json.decode(response.body);
      print(Listdata);

      List<GroceryItem> _loadedItems = [];

      for (var item in Listdata.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        _loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ));
      }

      setState(() {
        _groceryItems = _loadedItems;
        isloading = false;
      });

      if (response.statusCode >= 400) {
        _error = "Data not fetched. Please try again later.";
      }
    } catch (e) {
      setState(() {
        _error = "Something went wrong. Please try again later.";
      });
    }
  }

  void _addItem() async {
    final newItem =
        await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(
      builder: (context) => NewItem(),
    ));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });

    // _loadItems();
  }

  void _removeItem(item) async {
    final index = _groceryItems.indexOf(item);
    try {
      final url = Uri.https('api-app-92477-default-rtdb.firebaseio.com',
          'shopping-list/${item.id}.json');
      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        setState(() {
          _groceryItems.insert(index, item);
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("data not deleted")));
      }
    } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Something went wrong. Please try again.")));
    }

    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text("No item is added"),
    );

    if (isloading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (context, index) => Dismissible(
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
              ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Groceries"),
        actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
