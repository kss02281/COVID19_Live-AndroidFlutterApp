import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pa3/pages/page1.dart';
import 'package:pa3/pages/page2.dart';
import 'package:pa3/pages/case_death.dart';
import 'package:pa3/pages/vaccine.dart';

class Page1CounterProvider with ChangeNotifier{
  int _counter;
  get counter => _counter;

  Page1CounterProvider(this._counter);
  void incrementCounter(){
    _counter++;
    notifyListeners();
  }
}

class Page1 extends StatelessWidget {
  String _imagepath = "assets/images/corona.jpg";
  final Map<String, String> arguments;
  Page1(this.arguments);
  @override
  Widget build(BuildContext context){
    final String _id = arguments["user-id"];
    Page1CounterProvider counter = Provider.of<Page1CounterProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("2018310322 LeeSeonYe"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                "CORONA LIVE",
                style: Theme.of(context).textTheme.displayMedium),
            Text("Login Success. Hello $_id!!",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                )
            ),
            SizedBox(height: 50.0),
            SizedBox(
              width: 300,
              child:
              Image.asset(_imagepath),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              child: Text('start CORONA LIVE'),
              onPressed: () {
                Navigator.pushNamed(context, '/page2',
                arguments: {
                  "user-id": "$_id",
                  "previous-page": "Login Page",
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

