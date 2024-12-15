import 'package:flutter/material.dart';

class CategoryM {
  String name;
  String iconPath;
  Color boxColor;

  CategoryM(
      {required this.name, required this.iconPath, required this.boxColor});

  static List<CategoryM> getCategories() {
    List<CategoryM> categories = [];

    categories.add(CategoryM(
        name: 'Goats',
        iconPath: 'assets/images/goat.png',
        boxColor: Colors.green));

    categories.add(CategoryM(
        name: 'Stuff',
        iconPath: 'assets/images/stuff.png',
        boxColor: Colors.blue));

    categories.add(CategoryM(
      name: 'Feeds',
      iconPath: 'assets/images/feed.png',
      boxColor: Colors.orange,
    ));

    categories.add(CategoryM(
      name: 'Vet',
      iconPath: 'assets/images/vet.png',
      boxColor: Colors.purple,
    ));

    categories.add(CategoryM(
      name: 'Sales',
      iconPath: 'assets/images/sales.png',
      boxColor: Colors.yellow,
    ));

    categories.add(CategoryM(
      name: 'weather',
      iconPath: 'assets/images/weather.png',
      boxColor: Colors.teal,
    ));

    return categories;
  }
}
