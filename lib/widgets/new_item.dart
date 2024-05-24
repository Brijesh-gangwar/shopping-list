import 'dart:convert';

import 'package:flutter/material.dart';



import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';


class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var _enteredname = '';
  var _enteredquantity = 1;
  var _selectedcategories = categories[Categories.vegetables]!;

  bool is_sending = false;

  void _saveItem() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      // Navigator.of(context).pop(GroceryItem(
      //     id: DateTime.now().toString(),
      //     name: _enteredname,
      //     quantity: _enteredquantity,
      //     category: _selectedcategories));

      setState(() {
        is_sending = true;
      });

      try {
        final url = Uri.https(
            'api-app-92477-default-rtdb.firebaseio.com', 'shopping-list.json');

        final response = await http.post(url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': _enteredname,
              'quantity': _enteredquantity,
              'category': _selectedcategories.title
            }));

        final Map<String, dynamic> resdata = json.decode(response.body);
        // print(response.body);
        // print(response.statusCode);

        if (response.statusCode == 200) {
          Navigator.of(context).pop(GroceryItem(
              id: resdata['name'],
              name: _enteredname,
              quantity: _enteredquantity,
              category: _selectedcategories));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("data not sent")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Something went wrong. Please try again.")));
        setState(() {
          is_sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("add new item"),
        ),
        body: Form(
            key: _formkey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: InputDecoration(label: Text("Name")),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length > 50 ||
                        value.trim().length <= 1) {
                      return "characters must be between 1 and 50";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredname = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          label: const Text("Quantity"),
                        ),
                        initialValue: _enteredquantity.toString(),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value)! <= 0 ||
                              int.tryParse(value) == null) {
                            return "characters must be between 1 and 50";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredquantity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                          value: _selectedcategories,
                          items: [
                            for (final Category in categories.entries)
                              DropdownMenuItem(
                                  value: Category.value,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        color: Category.value.color,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(Category.value.title)
                                    ],
                                  )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedcategories = value!;
                            });
                          }),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: is_sending
                            ? null
                            : () {
                                _formkey.currentState!.reset();
                              },
                        child: const Text("Reset")),
                    ElevatedButton(
                      onPressed: is_sending ? null : _saveItem,
                      child: is_sending
                          ? const CircularProgressIndicator()
                          : const Text("Add Item"),
                    )
                  ],
                )
              ],
            )));
  }
}
