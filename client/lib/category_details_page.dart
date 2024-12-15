import 'package:cattle_management_app/cattle_page.dart';
import 'package:flutter/material.dart';
import 'models/list.dart';


class CategoryDetailsPage extends StatelessWidget {
  final CategoryM category;

  const CategoryDetailsPage({Key? key, required this.category})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Navigate to respective pages based on the category index
    switch (category.name) {
      case 'Goats':
        // Navigate to GoatPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Cattle(),
          ),
        );
        break;
      case 'Stuff':
        // Navigate to StuffPage
        
      // Add more cases for additional categories as needed
      default:
        // Handle cases for other categories or do nothing
        break;
    }

    // Returning an empty container since the navigation is done
    return Container();
  }
}
