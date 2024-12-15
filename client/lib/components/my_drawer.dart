import 'package:flutter/material.dart';
import '/settings.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Column(
          children: [
            // do Logo
            DrawerHeader(child: Center(child: Image.asset('assets/images/logo.jpg'),
            ),
            ),
            //Home list tittle
            Padding(padding: const EdgeInsets.only(left:25.0),
            child: ListTile(title:const Text("H O M E"),
            leading:const Icon(Icons.home),
            onTap: () {
              Navigator.pop(context);
            },
            ),
            ),
//settings tittle
Padding(padding: const EdgeInsets.only(left: 25.0),
child: ListTile(title: const Text("S E T T I N G S"),
leading:const Icon(Icons.settings_applications),
onTap: () {
  Navigator.pop(context);
  Navigator.push(context, MaterialPageRoute(
    builder: (context) =>const SettingsPage(),
  ),);
},),),

            ],
        ),
     //Logout list Tittle
     Padding(padding: const EdgeInsets.only(left: 25.0, bottom:  25),
     child: ListTile(title:const Text("L O G O U T"),
     leading:const Icon(Icons.logout_rounded),
     ),)   
      ],),
      
    );
  }
}
