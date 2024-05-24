import 'package:flutter/material.dart';

enum Categories { vegetables, fruits, other }

class Category {
  const Category(this.title, this.color);

  final String title;
  final Color color;
}
