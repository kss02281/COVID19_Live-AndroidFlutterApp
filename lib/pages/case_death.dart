import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:pa3/pages/page1.dart';
import 'package:pa3/pages/page2.dart';
import 'package:pa3/pages/case_death.dart';
import 'package:pa3/pages/vaccine.dart';


Future<List<Continent>> fetchContinent() async{
  final http.Response response = await http
      .get('https://covid.ourworldindata.org/data/owid-covid-data.json');
  final Map<String, dynamic> jsonResponse = json.decode(response.body);

  return compute(parseContinent, response.body);
}

List<Continent> parseContinent(String responseBody){
  final List<Continent> sum_con = List<Continent>();
  final parsed = json.decode(responseBody);
  parsed.forEach((key, value) {
    Continent con = new Continent.fromJson(value);
    sum_con.add(con);
  });
  return sum_con;
}

class Continent{
  final String continent;
  final String location;
  final List<dynamic> data;

  Continent({
    @required this.continent, @required this.location, @required this.data
});

  factory Continent.fromJson(Map<String, dynamic>json){
    return Continent(
    continent: json['continent'] as String,
        location: json['location'] as String,
        data: json['data'] as List<dynamic>
    );
  }
}

var date_data;
var date_mon;
var total_case_data;
var daily_case_data;
var total_case_mon;
var daily_case_mon;

class Case_Death extends StatelessWidget {
  final bag = {"first":0, "second":0};
  final Map<String, String> arguments;
  Case_Death(this.arguments);

  Widget _firstBoxView(List<Continent> continents){
    int k_indx = 0;
    int data_len = 0;
    double tot_case = 0.0;
    double tot_death = 0.0;
    double n_cases = 0.0;
    for (int i = 0; i < continents.length; i++) {
      if (continents[i].location == 'South Korea') {
        k_indx = i;
      }
    }

    data_len = continents[k_indx].data.length;


    int calcuate_tot_case(int d) {
      tot_case = 0;
      for (int i = 0; i < continents.length; i++) {
        int len = continents[i].data.length;

        if(len-d < 0)
          continue;

        double c_result1 = continents[i].data[len - d]['total_cases'] ?? -1;

        if (continents[i].data[len - d]['date'] ==
            continents[k_indx].data[data_len - d]['date']) {
          if (c_result1 != -1)
            tot_case += continents[i].data[len - d]['total_cases'];
          else {
            if (len > 1) {
              if(len-(d+1) < 0)
                continue;
              else {
                double c_result2 = continents[i].data[len -
                    (d + 1)]['total_cases'] ?? -2;
                if (c_result2 != -2)
                  tot_case += continents[i].data[len - (d + 1)]['total_cases'];
              }
            }
          }
        } else {
          if (c_result1 != -1)
            tot_case += continents[i].data[len - d]['total_cases'];
          else {
            if (len > 1) {
              if(len-(d+1) < 0)
                continue;
              else {
                double c_result2 = continents[i].data[len -
                    (d + 1)]['total_cases'] ?? -2;
                if (c_result2 != -2)
                  tot_case += continents[i].data[len - (d + 1)]['total_cases'];
              }
            }
          }
        }
      }
      return tot_case.toInt();
    }

    int calcuate_daily_case(int d) {
      n_cases = 0;
      for (int i = 0; i < continents.length; i++) {
        int len = continents[i].data.length;

        if(len-d < 0)
          continue;

        double n_result1 = continents[i].data[len - d]['new_cases'] ?? -1;

        if (continents[i].data[len - d]['date'] ==
            continents[k_indx].data[data_len - d]['date']) {
          if (n_result1 != -1)
            n_cases += continents[i].data[len - d]['new_cases'];
          else {
            if (len > 1) {
              if(len-(d+1) < 0)
                continue;
              else {
                double n_result2 = continents[i].data[len -
                    (d + 1)]['new_cases'] ?? -2;
                if (n_result2 != -2)
                  n_cases += continents[i].data[len - (d + 1)]['new_cases'];
              }
            }
          }
        } else {
          if (n_result1 != -1)
            n_cases += continents[i].data[len - (d+1)]['new_cases'];
          else {
            if (len > 1) {
              if(len-(d+1) < 0)
                continue;
              else {
                double n_result2 = continents[i].data[len -
                    (d + 1)]['new_cases'] ?? -2;
                if (n_result2 != -2)
                  n_cases += continents[i].data[len - (d + 1)]['new_cases'];
              }
            }
          }
        }
      }
      return n_cases.toInt();
    }

    for (int i = 0; i < continents.length; i++) {
      int len = continents[i].data.length;

      double d_result1 = continents[i].data[len-1]['total_deaths'] ?? -1;

      if (continents[i].data[len-1]['date'] == continents[k_indx].data[data_len - 1]['date']) {
        if(d_result1 != -1)
          tot_death += continents[i].data[len-1]['total_deaths'];
        else {
          if(len>1) {
            double d_result2 = continents[i].data[len - 2]['total_deaths'] ?? -2;
            if(d_result2 != -2)
              tot_death += continents[i].data[len-2]['total_deaths'];
          }
        }
      }else{
        if(d_result1 != -1)
          tot_death += continents[i].data[len-1]['total_deaths'];
        else {
          if(len>1) {
            double d_result2 = continents[i].data[len - 2]['total_deaths'] ?? -2;
            if(d_result2 != -2)
              tot_death += continents[i].data[len-2]['total_deaths'];
          }
        }
      }
    }


    return Container(
        padding: EdgeInsets.fromLTRB(20.0, 2.0, 20.0, 2.0),
        child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 7.5/2,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total cases."),
                  Text(calcuate_tot_case(1).toString()+" people"),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Parsed latest date"),
                  Text("${continents[k_indx].data[data_len-1]['date']}"),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Deaths"),
                  Text(tot_death.toInt().toString()+" people"),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Daily Cases."),
                  Text(calcuate_daily_case(1).toString()+" people"),
                ],
              ),
            ]
        )
    );
  }

  Widget _secondBoxView(List<Continent> continents, int num){
    int k_indx = 0;
    int data_len = 0;
    double tot_case = 0.0;
    double n_cases = 0.0;

    for (int i = 0; i < continents.length; i++) {
      if (continents[i].location == 'South Korea') {
        k_indx = i;
      }
    }

    data_len = continents[k_indx].data.length;

    date_data = List.generate(7, (index) =>
        continents[k_indx].data[data_len-(7-index)]['date'].toString().substring(5,), growable: true);

    date_mon = List.generate(29, (index) =>
        continents[k_indx].data[data_len-(29-index)]['date'].toString().substring(5,), growable: true);

    int calcuate_tot_case(int d) {
      tot_case = 0;
      for (int i = 0; i < continents.length; i++) {
        int len = continents[i].data.length;

        if(len-d < 0)
          continue;

        double c_result1 = continents[i].data[len - d]['total_cases'] ?? -1;

        if (continents[i].data[len - d]['date'] ==
            continents[k_indx].data[data_len - d]['date']) {
          if (c_result1 != -1)
            tot_case += continents[i].data[len - d]['total_cases'];
          else {
            if (len > 1) {
              if(len-(d+1) < 0)
                continue;
              else {
                double c_result2 = continents[i].data[len -
                    (d + 1)]['total_cases'] ?? -2;
                if (c_result2 != -2)
                  tot_case += continents[i].data[len - (d + 1)]['total_cases'];
              }
            }
          }
        } else {
          if (c_result1 != -1)
            tot_case += continents[i].data[len - d]['total_cases'];
          else {
            if (len > 1) {
              if(len-(d+1) < 0)
                continue;
              else {
                double c_result2 = continents[i].data[len -
                    (d + 1)]['total_cases'] ?? -2;
                if (c_result2 != -2)
                  tot_case += continents[i].data[len - (d + 1)]['total_cases'];
              }
            }
          }
        }
      }
      return tot_case.toInt();
    }

    int calcuate_daily_case(int d) {
      n_cases = 0;
      for (int i = 0; i < continents.length; i++) {
        int len = continents[i].data.length;

        if(len-d < 0)
          continue;

        double n_result1 = continents[i].data[len - d]['new_cases'] ?? -1;

        if (continents[i].data[len - d]['date'] ==
            continents[k_indx].data[data_len - d]['date']) {
          if (n_result1 != -1)
            n_cases += continents[i].data[len - d]['new_cases'];
          else {
            if (len > 1) {
              if(len-(d+1) < 0)
                continue;
              else {
                double n_result2 = continents[i].data[len -
                    (d + 1)]['new_cases'] ?? -2;
                if (n_result2 != -2)
                  n_cases += continents[i].data[len - (d + 1)]['new_cases'];
              }
            }
          }
        } else {
          if (n_result1 != -1)
            n_cases += continents[i].data[len - (d+1)]['new_cases'];
          else {
            if (len > 1) {
              if(len-(d+1) < 0)
                continue;
              else {
                double n_result2 = continents[i].data[len -
                    (d + 1)]['new_cases'] ?? -2;
                if (n_result2 != -2)
                  n_cases += continents[i].data[len - (d + 1)]['new_cases'];
              }
            }
          }
        }
      }
      return n_cases.toInt();
    }



    total_case_data = List.generate(7, (index) => (calcuate_tot_case(7-index)/100000000).toStringAsFixed(2), growable: true);
    total_case_mon = List.generate(29, (index) => (calcuate_tot_case(29-index)/100000000).toStringAsFixed(2), growable: true);


    daily_case_data = List.generate(7, (index) => (calcuate_daily_case(7-index)/1000000).toStringAsFixed(2), growable: true);
    daily_case_mon = List.generate(29, (index) => (calcuate_daily_case(29-index)/1000000).toStringAsFixed(2), growable: true);
    for(int i = 0; i<29; i++){
      print("tot_case$i: "+total_case_mon[i].toString());
      print("daily_case$i: "+daily_case_mon[i].toString());
    }
    if(num == 1) {
      return Flexible(
        child: Container(
            height: 180,
            margin: EdgeInsets.all(2),
            child: AspectRatio(
              aspectRatio: 4.2 / 2,
              child: Container(
                height: 180,
                width: 350,
                decoration: BoxDecoration(
                    color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                  child: LineChart(
                      chart1()
                  ),
                ),
              ),
            )
        ),
      );
    }else if(num == 2){
      return Flexible(
        child: Container(
            height: 180,
            margin: EdgeInsets.all(2),
            child: AspectRatio(
              aspectRatio: 4 / 2,
              child: Container(
                height: 180,
                width: 350,
                decoration: BoxDecoration(
                    color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                  child: LineChart(
                      chart2()
                  ),
                ),
              ),
            )
        ),
      );
    }else if(num == 3){
      return Flexible(
        child: Container(
            height: 180,
            margin: EdgeInsets.all(2),
            child: AspectRatio(
              aspectRatio: 4 / 2.1,
              child: Container(
                height: 180,
                width: 350,
                decoration: BoxDecoration(
                    color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                  child: LineChart(
                      chart3()
                  ),
                ),
              ),
            )
        ),
      );
    }else if(num == 4){
      return Flexible(
        child: Container(
            height: 180,
            margin: EdgeInsets.all(2),
            child: AspectRatio(
              aspectRatio: 4 / 2.2,
              child: Container(
                height: 180,
                width: 350,
                decoration: BoxDecoration(
                    color: Colors.white),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                  child: LineChart(
                      chart4()
                  ),
                ),
              ),
            )
        ),
      );
    }
  }

  Widget _thirdBoxView1(List<Continent> continents) {
    int row = continents.length+1;
    int col = 4;
    var dataList = List.generate(row, (idx) => List(col), growable: false);

    dataList[0][0] = "Country";
    dataList[0][1] = "total cases";
    dataList[0][2] = "daily cases";
    dataList[0][3] = "total deaths";

    for(int i = 0; i < continents.length; i++){
      int len = continents[i].data.length;

      if(len > 0){
        String country_name = continents[i].location ?? "null";
        double result1 = continents[i].data[len-1]['total_cases'] ?? -1;
        double result2 = continents[i].data[len-1]['new_cases'] ?? -2;
        double result3 = continents[i].data[len-1]['total_deaths'] ?? -3;

        dataList[i+1][0] = country_name;

        if(result1 != -1)
          dataList[i+1][1] = result1.toString();
        else
          dataList[i+1][1] = "0";

        if(result2 != -2)
          dataList[i+1][2] = result2.toString();
        else
          dataList[i+1][2] = "0";

        if(result3 != -3)
          dataList[i+1][3] = result3.toString();
        else
          dataList[i+1][3] = "0";
      }
    }

    for(int i = 1; i<continents.length+1; i++){
      for(int j = i; j < continents.length+1; j++) {
        if (double.parse(dataList[i][1]) < double.parse(dataList[j][1])) {
          var tmp = dataList[i];
          dataList[i] = dataList[j];
          dataList[j] = tmp;
        }
      }
    }

    return Flexible(
        child: Container(
          height: 180,
          margin: EdgeInsets.all(2),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: 8,

            itemBuilder: (context, index){
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(dataList[index][0]+"      ", textAlign: TextAlign.left, style: TextStyle(fontSize: 14)),
                  Text((dataList[index][1]).toString()+"    ", style: TextStyle(fontSize: 14)),
                  Text((dataList[index][2]).toString(), style: TextStyle(fontSize: 14)),
                  Text("   "+(dataList[index][3]).toString(), textAlign: TextAlign.right, style: TextStyle(fontSize: 14)),
                ],
              );
            },
            separatorBuilder: (context, index){
              return SizedBox(
                height: 15,
              );
            },
          ),

        )
    );
  }

  Widget _thirdBoxView2(List<Continent> continents) {
    int row = continents.length+1;
    int col = 4;
    var dataList = List.generate(row, (idx) => List(col), growable: false);

    dataList[0][0] = "Country";
    dataList[0][1] = "total cases";
    dataList[0][2] = "daily cases";
    dataList[0][3] = "total deaths";

    for(int i = 0; i < continents.length; i++){
      int len = continents[i].data.length;

      if(len > 0){
        String country_name = continents[i].location ?? "null";
        double result1 = continents[i].data[len-1]['total_cases'] ?? -1;
        double result2 = continents[i].data[len-1]['new_cases'] ?? -2;
        double result3 = continents[i].data[len-1]['total_deaths'] ?? -3;

        dataList[i+1][0] = country_name;

        if(result1 != -1)
          dataList[i+1][1] = result1.toString();
        else
          dataList[i+1][1] = "0";

        if(result2 != -2)
          dataList[i+1][2] = result2.toString();
        else
          dataList[i+1][2] = "0";

        if(result3 != -3)
          dataList[i+1][3] = result3.toString();
        else
          dataList[i+1][3] = "0";
      }
    }

    for(int i = 1; i<continents.length+1; i++){
      for(int j = i; j < continents.length+1; j++) {
        if (double.parse(dataList[i][3]) < double.parse(dataList[j][3])) {
          var tmp = dataList[i];
          dataList[i] = dataList[j];
          dataList[j] = tmp;
        }
      }
    }

    return Flexible(
        child: Container(
          height: 180,
          margin: EdgeInsets.all(2),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: 8,

            itemBuilder: (context, index){
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(dataList[index][0]+"      ", textAlign: TextAlign.left, style: TextStyle(fontSize: 14)),
                  Text((dataList[index][1]).toString()+"    ", style: TextStyle(fontSize: 14)),
                  Text((dataList[index][2]).toString(), style: TextStyle(fontSize: 14)),
                  Text("   "+(dataList[index][3]).toString(), textAlign: TextAlign.right, style: TextStyle(fontSize: 14)),
                ],
              );
            },
            separatorBuilder: (context, index){
              return SizedBox(
                height: 15,
              );
            },
          ),

        )
    );
  }


  @override
  Widget build(BuildContext context){
    final String _id = arguments["user-id"];
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 100.0),
            Container(
              height: 120,
              width: 350,
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
              child: FutureBuilder(
                future: fetchContinent(),
                builder: (context, snapshot){
                  if(snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? _firstBoxView(snapshot.data)
                      :Center(child: CircularProgressIndicator());
                },
              ),
            ),
            SizedBox(height: 15.0),
            Container(
              height: 220,
              width: 350,
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
                  SizedBox(height: 35, child:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                          child: Container(
                            alignment: Alignment.center,
                            width: 70.0,
                            height: 30.0,
                            child: Text("Graph1",
                                style: TextStyle(color: Colors.blueAccent )),
                          ),
                          onTap: (){
                            bag["first"] = 1;
                            (context as Element).markNeedsBuild();
                          }
                      ),
                      GestureDetector(
                          child: Container(
                            alignment: Alignment.center,
                            width: 70.0,
                            height: 30.0,
                            child: Text("Graph2",
                                style: TextStyle(color: Colors.blueAccent )),
                          ),
                          onTap: (){
                            bag["first"] = 2;
                            (context as Element).markNeedsBuild();
                          }
                      ),
                      GestureDetector(
                          child: Container(
                            alignment: Alignment.center,
                            width: 70.0,
                            height: 30.0,
                            child: Text("Graph3",
                                style: TextStyle(color: Colors.blueAccent )),
                          ),
                          onTap: (){
                            bag["first"] = 3;
                            (context as Element).markNeedsBuild();
                          }
                      ),
                      GestureDetector(
                          child: Container(
                            alignment: Alignment.center,
                            width: 70.0,
                            height: 30.0,
                            child: Text("Graph4",
                                style: TextStyle(color: Colors.blueAccent )),
                          ),
                          onTap: (){
                            bag["first"] = 4;
                            (context as Element).markNeedsBuild();
                          }
                      ),
                    ],
                  )
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 2.0,
                    height: 5,
                  ),
            if(bag["first"]==1)
              FutureBuilder<List<Continent>>(
                future: fetchContinent(),
                builder: (context, snapshot){
                  if(snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? _secondBoxView(snapshot.data, bag["first"])
                      :Center(child: CircularProgressIndicator());
                },
              )

            else if(bag["first"]==2)
              FutureBuilder<List<Continent>>(
                future: fetchContinent(),
                builder: (context, snapshot){
                  if(snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? _secondBoxView(snapshot.data, bag["first"])
                      :Center(child: CircularProgressIndicator());
                },
              )
            else if(bag["first"]==3)
                FutureBuilder<List<Continent>>(
                  future: fetchContinent(),
                  builder: (context, snapshot){
                    if(snapshot.hasError) print(snapshot.error);

                    return snapshot.hasData
                        ? _secondBoxView(snapshot.data, bag["first"])
                        :Center(child: CircularProgressIndicator());
                  },
                )
              else if(bag["first"]==4)
                  FutureBuilder<List<Continent>>(
                    future: fetchContinent(),
                    builder: (context, snapshot){
                      if(snapshot.hasError) print(snapshot.error);

                      return snapshot.hasData
                          ? _secondBoxView(snapshot.data, bag["first"])
                          :Center(child: CircularProgressIndicator());
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.0),
            Container(
              height: 220,
              width: 350,
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
                  SizedBox(height: 35, child:  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                          child: Container(
                            alignment: Alignment.center,
                            width: 100.0,
                            height: 30.0,
                            child: Text("Total Cases",
                                style: TextStyle(color: Colors.blueAccent )),
                          ),
                          onTap: (){
                            bag["second"] = 1;
                            (context as Element).markNeedsBuild();
                          }
                      ),
                      GestureDetector(
                          child: Container(
                            alignment: Alignment.center,
                            width: 100.0,
                            height: 30.0,
                            child: Text("Total Deaths",
                                style: TextStyle(color: Colors.blueAccent )),
                          ),
                          onTap: (){
                            bag["second"] = 2;
                            (context as Element).markNeedsBuild();
                          }
                      ),
                    ],
                  )),
                  Divider(
                    color: Colors.grey,
                    thickness: 2.0,
                    height: 5,
                  ),
                  if(bag["second"]==1)
                    FutureBuilder(
                        future: fetchContinent(),
                        builder: (context, snapshot){
                          if(snapshot.hasError) print(snapshot.error);

                          return snapshot.hasData
                              ? _thirdBoxView1(snapshot.data)
                              :Center(child: CircularProgressIndicator());
                        }
                    )
                  else if(bag["second"]==2)
                    FutureBuilder(
                      future: fetchContinent(),
                      builder: (context, snapshot){
                        if(snapshot.hasError) print(snapshot.error);

                        return snapshot.hasData
                            ? _thirdBoxView2(snapshot.data)
                            :Center(child: CircularProgressIndicator());
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/page2',
              arguments: {
                "user-id": "$_id",
                "previous-page": "Cases/Deaths Page",
              });
        },
        child: Icon(Icons.list),
      ),
    );
  }
}


LineChartData chart1(){
  return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,

      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 2,
          getTitles: (value){
            switch(value.toInt()){
              case 0:
                return date_data[0];
              case 1:
                return date_data[1];
              case 2:
                return date_data[2];
              case 3:
                return date_data[3];
              case 4:
                return date_data[4];
              case 5:
                return date_data[5];
              case 6:
                return date_data[6];
            }
            return '';
          },
          margin: 8,
        ),

        leftTitles: SideTitles(
          showTitles: true,
          getTitles: (value){
            return value.toString();

          },
          margin: 8,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white, width: 1)),

      lineBarsData: [
        LineChartBarData(
          colors: [Colors.blueAccent],
          spots: [
            FlSpot(0, double.parse(total_case_data[0])),
            FlSpot(1, double.parse(total_case_data[1])),
            FlSpot(2, double.parse(total_case_data[2])),
            FlSpot(3, double.parse(total_case_data[3])),
            FlSpot(4, double.parse(total_case_data[4])),
            FlSpot(5, double.parse(total_case_data[5])),
            FlSpot(6, double.parse(total_case_data[6])),
          ],
          barWidth: 3,
          isCurved: false,
          belowBarData: BarAreaData(
            show:false,
          ),
          dotData: FlDotData(show:true),
        )
      ]
  );

}

LineChartData chart2(){
  return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          getTitles: (value){
            switch(value.toInt()){
              case 0:
                return date_data[0];
              case 1:
                return date_data[1];
              case 2:
                return date_data[2];
              case 3:
                return date_data[3];
              case 4:
                return date_data[4];
              case 5:
                return date_data[5];
              case 6:
                return date_data[6];
            }
            return '';
          },
          margin: 8,
        ),

        leftTitles: SideTitles(
          showTitles: true,
          reservedSize: 20,
          getTitles: (value){
            return value.toString();
          },
          margin: 8,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white, width: 1)),

      lineBarsData: [
        LineChartBarData(
          colors: [Colors.blueAccent],
          spots: [
            FlSpot(0, double.parse(daily_case_data[0])),
            FlSpot(1, double.parse(daily_case_data[1])),
            FlSpot(2, double.parse(daily_case_data[2])),
            FlSpot(3, double.parse(daily_case_data[3])),
            FlSpot(4, double.parse(daily_case_data[4])),
            FlSpot(5, double.parse(daily_case_data[5])),
            FlSpot(6, double.parse(daily_case_data[6])),
          ],
          barWidth: 3,
          isCurved: false,
          belowBarData: BarAreaData(
            show:false,
          ),
          dotData: FlDotData(show:true),
        )
      ]
  );

}

LineChartData chart3(){
  return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,

      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 2,
          getTitles: (value){
            switch(value.toInt()){
              case 0:
                return date_mon[0];
              case 7:
                return date_mon[7];
              case 14:
                return date_mon[14];
              case 21:
                return date_mon[21];
              case 28:
                return date_mon[28];
            }
            return '';
          },
          margin: 8,
        ),

        leftTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 9.5,
          ),
          getTitles: (value){
            return value.toString()+"M";
          },
          margin: 8,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white, width: 1)),
      lineBarsData: [
        LineChartBarData(
          colors: [Colors.blueAccent],
          spots: [
            FlSpot(0, double.parse(total_case_mon[0])),
            FlSpot(1, double.parse(total_case_mon[1])),
            FlSpot(2, double.parse(total_case_mon[2])),
            FlSpot(3, double.parse(total_case_mon[3])),
            FlSpot(4, double.parse(total_case_mon[4])),
            FlSpot(5, double.parse(total_case_mon[5])),
            FlSpot(6, double.parse(total_case_mon[6])),
            FlSpot(7, double.parse(total_case_mon[7])),
            FlSpot(8, double.parse(total_case_mon[8])),
            FlSpot(9, double.parse(total_case_mon[9])),
            FlSpot(10, double.parse(total_case_mon[10])),
            FlSpot(11, double.parse(total_case_mon[11])),
            FlSpot(12, double.parse(total_case_mon[12])),
            FlSpot(13, double.parse(total_case_mon[13])),
            FlSpot(14, double.parse(total_case_mon[14])),
            FlSpot(15, double.parse(total_case_mon[15])),
            FlSpot(16, double.parse(total_case_mon[16])),
            FlSpot(17, double.parse(total_case_mon[17])),
            FlSpot(18, double.parse(total_case_mon[18])),
            FlSpot(19, double.parse(total_case_mon[19])),
            FlSpot(20, double.parse(total_case_mon[20])),
            FlSpot(21, double.parse(total_case_mon[21])),
            FlSpot(22, double.parse(total_case_mon[22])),
            FlSpot(23, double.parse(total_case_mon[23])),
            FlSpot(24, double.parse(total_case_mon[24])),
            FlSpot(25, double.parse(total_case_mon[25])),
            FlSpot(26, double.parse(total_case_mon[26])),
            FlSpot(27, double.parse(total_case_mon[27])),
            FlSpot(28, double.parse(total_case_mon[28])),
          ],
          barWidth: 3,
          isCurved: false,
          belowBarData: BarAreaData(
            show:false,
          ),
          dotData: FlDotData(show:true),
        )
      ]
  );

}

LineChartData chart4(){
  return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 2,
          getTitles: (value){
            switch(value.toInt()){
              case 0:
                return date_mon[0];
              case 7:
                return date_mon[7];
              case 14:
                return date_mon[14];
              case 21:
                return date_mon[21];
              case 28:
                return date_mon[28];
            }
            return '';
          },
          margin: 8,
        ),

        leftTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 8,
          ),
          getTitles: (value){
            return value.toString()+"M";
          },
          margin: 8,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white, width: 1)),
      // minY: (double.parse(daily_case_mon[0])-1,
      // maxY: (double.parse(daily_case_mon[28])+20,
      lineBarsData: [
        LineChartBarData(
          colors: [Colors.blueAccent],
          spots: [
            FlSpot(0, double.parse(daily_case_mon[0])),
            FlSpot(1, double.parse(daily_case_mon[1])),
            FlSpot(2, double.parse(daily_case_mon[2])),
            FlSpot(3, double.parse(daily_case_mon[3])),
            FlSpot(4, double.parse(daily_case_mon[4])),
            FlSpot(5, double.parse(daily_case_mon[5])),
            FlSpot(6, double.parse(daily_case_mon[6])),
            FlSpot(7, double.parse(daily_case_mon[7])),
            FlSpot(8, double.parse(daily_case_mon[8])),
            FlSpot(9, double.parse(daily_case_mon[9])),
            FlSpot(10,double.parse(daily_case_mon[10])),
            FlSpot(11,double.parse(daily_case_mon[11])),
            FlSpot(12,double.parse(daily_case_mon[12])),
            FlSpot(13,double.parse(daily_case_mon[13])),
            FlSpot(14,double.parse(daily_case_mon[14])),
            FlSpot(15,double.parse(daily_case_mon[15])),
            FlSpot(16,double.parse(daily_case_mon[16])),
            FlSpot(17,double.parse(daily_case_mon[17])),
            FlSpot(18,double.parse(daily_case_mon[18])),
            FlSpot(19,double.parse(daily_case_mon[19])),
            FlSpot(20,double.parse(daily_case_mon[20])),
            FlSpot(21,double.parse(daily_case_mon[21])),
            FlSpot(22,double.parse(daily_case_mon[22])),
            FlSpot(23,double.parse(daily_case_mon[23])),
            FlSpot(24,double.parse(daily_case_mon[24])),
            FlSpot(25,double.parse(daily_case_mon[25])),
            FlSpot(26,double.parse(daily_case_mon[26])),
            FlSpot(27,double.parse(daily_case_mon[27])),
            FlSpot(28,double.parse(daily_case_mon[28])),
          ],
          barWidth: 2,
          isCurved: false,
          belowBarData: BarAreaData(
            show:false,
          ),
          dotData: FlDotData(show:true),

        )
      ]
  );

}