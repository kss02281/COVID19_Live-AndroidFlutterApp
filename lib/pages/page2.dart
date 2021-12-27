import 'package:flutter/material.dart';
import 'package:pa3/pages/page1.dart';
import 'package:pa3/pages/page2.dart';
import 'package:pa3/pages/case_death.dart';
import 'package:pa3/pages/vaccine.dart';

class Page2 extends StatelessWidget {

  final Map<String, String> arguments;
  Page2(this.arguments);
  Widget build(BuildContext context){
    final String USER_ID = arguments["user-id"];
    final String PREVIOUS_PAGE_NAME = arguments["previous-page"];
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.coronavirus_outlined),
              title: Text('Cases/Deaths'),
              onTap: (){
                Navigator.pushNamed(context, '/case_death',
                    arguments: {
                      "user-id": "$USER_ID",
                    });
              },
            ),
            SizedBox(height: 10.0),
            ListTile(
              leading: Icon(Icons.local_hospital),
              title: Text('Vaccine'),
              onTap: (){
                Navigator.pushNamed(context, '/vaccine',
                    arguments: {
                      "user-id": "$USER_ID",
                    });
              },
            ),
            SizedBox(height: 350.0),
            Text("Welcome! $USER_ID"),
            Text("Previous: $PREVIOUS_PAGE_NAME")
          ],
        ),
      ),
    );
  }
}
