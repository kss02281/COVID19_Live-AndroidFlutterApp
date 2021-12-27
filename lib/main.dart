import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'package:pa3/pages/page1.dart';
import 'package:pa3/pages/page2.dart';
import 'package:pa3/pages/case_death.dart';
import 'package:pa3/pages/vaccine.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context)=>Page1CounterProvider(0)),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          initialRoute: '/',
          onGenerateRoute: (routerSettings) {
            switch(routerSettings.name){
              case '/':
                return MaterialPageRoute(builder: (_)=>MyHomePage(title: "2018310322 LeeSeonYe"));
              case '/page1':
                return MaterialPageRoute(builder: (_)=>Page1(routerSettings.arguments));
                break;
              case '/page2':
                return MaterialPageRoute(builder: (_)=>Page2(routerSettings.arguments));
                break;
              case '/case_death':
                return MaterialPageRoute(builder: (_)=>Case_Death(routerSettings.arguments));
                break;
              case '/vaccine':
                return MaterialPageRoute(builder: (_)=>Vaccine(routerSettings.arguments));
                break;
              default:
                return MaterialPageRoute(builder: (_)=>MyHomePage(title: "Error Unknown Route!",));
            }
          },
        )
    );
  }
}

class MyHomePage extends StatelessWidget {
  final TextEditingController _idController =
  TextEditingController(text: 'skku');
  final TextEditingController _passwordController =
  TextEditingController(text: '1234');

  void _onLogin(BuildContext context){
    final String id = _idController.text;

    Navigator.pushNamed(context,
      '/page1',
      arguments: {
        "user-id": "$id"
      },
    );
  }

  MyHomePage({Key key, this.title}):super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    final String id = _idController.text;
    final Page1CounterProvider counter = Provider.of<Page1CounterProvider>(context);
      return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                "CORONA LIVE",
                style: Theme.of(context).textTheme.displayMedium),
            Text(
                "Login Please...",
                style: Theme.of(context).textTheme.bodyText1),
            SizedBox(height: 45.0),
            Container(
              height: 180,
              width: 300,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: Colors.grey,
                      style: BorderStyle.solid,
                      width: 3
                  ),
                borderRadius: BorderRadius.all(Radius.circular(15))
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('ID: ', style: TextStyle(fontSize: 20)),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _idController,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('PW: ', style: TextStyle(fontSize: 20)),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _passwordController,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    child: Text('Login'),
                    onPressed: () => _onLogin(context)
                  ),
                ],
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
