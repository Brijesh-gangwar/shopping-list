

import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

final groceryItems = [
  GroceryItem(
      id: 'a',
      name: 'fruits',
      quantity: 1,
      category: categories[Categories.fruits]!),
  GroceryItem(
      id: 'b',
      name: 'vegetables',
      quantity: 4,
      category: categories[Categories.vegetables]!),
  GroceryItem(
      id: 'c',
      name: 'other',
      quantity: 2,
      category: categories[Categories.other]!),
  GroceryItem(
      id: 'd',
      name: 'fruits',
      quantity: 4,
      category: categories[Categories.fruits]!),
];
