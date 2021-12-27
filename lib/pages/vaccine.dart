import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:pa3/main.dart';
import 'package:pa3/pages/page1.dart';
import 'package:pa3/pages/page2.dart';
import 'package:pa3/pages/case_death.dart';
import 'package:pa3/pages/vaccine.dart';

Future<List<Country>> fetchCountry(http.Client client) async{
  final response = await client
      .get(Uri.parse('https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.json'));

  return compute(parseCountry, response.body);
}

List<Country> parseCountry(String responseBody){
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Country>((json)=>Country.fromJson(json)).toList();
}

class Country{
  final String country;
  final String iso_code;
  final List<dynamic> data;

  Country({
    @required this.country, @required this.iso_code, @required this.data
  });
  factory Country.fromJson(Map<String, dynamic> json){
    return Country(
      country: json['country'] as String,
      iso_code: json['iso_code'] as String,
      data: json['data'] as List<dynamic>
    );
  }
}

var date_data;
var date_mon;
var total_vac_data;
var daily_vac_data;
var total_vac_mon;
var daily_vac_mon;

class Vaccine extends StatelessWidget {
  final Map<String, String> arguments;
  Vaccine(this.arguments);

  final bag = {"first":1, "second":1};

  @override
  Widget build(BuildContext context){
    final String _id = arguments["user-id"];
    Widget _firstBoxView(List<Country> countries){
      int k_indx = 0;
      int data_len = 0;
      int tot_vac = 0;
      int tot_ful_vac = 0;
      int d_vac = 0;
      for (int i = 0; i < countries.length; i++) {
        if (countries[i].country == 'South Korea') {
          k_indx = i;
        }
      }
      data_len = countries[k_indx].data.length;

      int calcuate_tot_vac(int day){
        tot_vac = 0;
        for (int i = 0; i < countries.length; i++) {
          int len = countries[i].data.length;

          if(len-day < 0)
            continue;

          int result1 = countries[i].data[len-day]['total_vaccinations'] ?? -1;
          int result2 = countries[i].data[len-day]['people_vaccinated'] ?? -2;
          int result3 = countries[i].data[len-day]['people_fully_vaccinated'] ?? -3;

          if (countries[i].data[len-day]['date'] == countries[k_indx].data[data_len-day]['date']) {
            //tot_vac
            if(result1 != -1)
              tot_vac += countries[i].data[len-day]['total_vaccinations'];
            else{
              if(result2 != -2)
                tot_vac += countries[i].data[len-day]['people_vaccinated'];
              else if(result3 != -3)
                tot_vac += countries[i].data[len-day]['people_fully_vaccinated'];
            }
          }else {
            if (result1 != -1)
              tot_vac += countries[i].data[len - day]['total_vaccinations'];
            else {
              if (result2 != -2)
                tot_vac += countries[i].data[len - day]['people_vaccinated'];
              else if (result3 != -3)
                tot_vac += countries[i].data[len - day]['people_fully_vaccinated'];
            }
          }
        }
        return tot_vac;
      }

      int calcuate_daily_vac(int day){
        d_vac = 0;
        for (int i = 0; i < countries.length; i++) {
          int len = countries[i].data.length;

          if(len-day < 0)
            continue;

          int d_result1 = countries[i].data[len-day]['daily_vaccinations'] ?? -1;

          if (countries[i].data[len-day]['date'] == countries[k_indx].data[data_len - 1]['date']) {
            //d_vac
            if(d_result1 != -1)
              d_vac += countries[i].data[len-day]['daily_vaccinations'];
            else {
              if(len>1) {
                int d_result2 = countries[i].data[len - (day+1)]['daily_vaccinations'] ?? -2;
                if(d_result2 != -2)
                  d_vac += countries[i].data[len-(day+1)]['daily_vaccinations'];
              }
            }
          }else{
            //d_vac
            if(d_result1 != -1)
              d_vac += countries[i].data[len-day]['daily_vaccinations'];
            else {
              if(len>1) {
                int d_result2 = countries[i].data[len - (day+1)]['daily_vaccinations'] ?? -2;
                if(d_result2 != -2)
                  d_vac += countries[i].data[len-(day+1)]['daily_vaccinations'];
              }
            }
          }
        }
        return d_vac;
      }

      for (int i = 0; i < countries.length; i++) {
        int len = countries[i].data.length;

        int pf_result1 = countries[i].data[len-1]['people_fully_vaccinated'] ?? -1;

        if (countries[i].data[len-1]['date'] == countries[k_indx].data[data_len - 1]['date']) {
          //tot_ful_vac
          if(pf_result1 != -1)
            tot_ful_vac += countries[i].data[len-1]['people_fully_vaccinated'];
          else {
            if(len>1) {
              int pf_result2 = countries[i].data[len - 2]['people_fully_vaccinated'] ?? -2;
              if(pf_result2 != -2)
                tot_ful_vac += countries[i].data[len-2]['people_fully_vaccinated'];
            }
          }
        }else{
          if(pf_result1 != -1)
            tot_ful_vac += countries[i].data[len-1]['people_fully_vaccinated'];
          else {
            if(len>1) {
              int pf_result2 = countries[i].data[len - 2]['people_fully_vaccinated'] ?? -2;
              if(pf_result2 != -2)
                tot_ful_vac += countries[i].data[len-2]['people_fully_vaccinated'];
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
                  Text("Total Vacc."),
                  Text(calcuate_tot_vac(1).toString()+" people"),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Parsed latest date", textAlign: TextAlign.right),
                  Text("${countries[k_indx].data[data_len - 1]['date']}", textAlign: TextAlign.right),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total fully Vacc.", textAlign: TextAlign.left),
                  Text("$tot_ful_vac people", textAlign: TextAlign.left),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Daily Vacc.", textAlign: TextAlign.right),
                  Text(calcuate_daily_vac(1).toString()+" people", textAlign: TextAlign.right),
                ],
              ),
            ]
        )
      );


    }

    Widget _secondBoxView(List<Country> countries, int num){
      int k_indx = 0;
      int data_len = 0;
      int tot_vac = 0;
      int d_vac = 0;

      for (int i = 0; i < countries.length; i++) {
        if (countries[i].country == 'South Korea') {
          k_indx = i;
        }
      }
      data_len = countries[k_indx].data.length;

      date_data = List.generate(7, (index) =>
          countries[k_indx].data[data_len-(7-index)]['date'].toString().substring(5,), growable: true);

      date_mon = List.generate(29, (index) =>
          countries[k_indx].data[data_len-(29-index)]['date'].toString().substring(5,), growable: true);

      int calcuate_tot_vac(int day){
        tot_vac = 0;
        for (int i = 0; i < countries.length; i++) {
          int len = countries[i].data.length;


          if(len-day < 0)
            continue;

          int result1 = countries[i].data[len-day]['total_vaccinations'] ?? -1;
          int result2 = countries[i].data[len-day]['people_vaccinated'] ?? -2;
          int result3 = countries[i].data[len-day]['people_fully_vaccinated'] ?? -3;

          if (countries[i].data[len-day]['date'] == countries[k_indx].data[data_len-day]['date']) {
            //tot_vac
            if(result1 != -1)
              tot_vac += countries[i].data[len-day]['total_vaccinations'];
            else{
              if(result2 != -2)
                tot_vac += countries[i].data[len-day]['people_vaccinated'];
              else if(result3 != -3)
                tot_vac += countries[i].data[len-day]['people_fully_vaccinated'];
            }
          }else {
            if (result1 != -1)
              tot_vac += countries[i].data[len - day]['total_vaccinations'];
            else {
              if (result2 != -2)
                tot_vac += countries[i].data[len - day]['people_vaccinated'];
              else if (result3 != -3)
                tot_vac += countries[i].data[len - day]['people_fully_vaccinated'];
            }
          }
        }
        return tot_vac;
      }



      int calcuate_daily_vac(int day){
        d_vac = 0;
        for (int i = 0; i < countries.length; i++) {
          int len = countries[i].data.length;

          if(len - day < 0)
            continue;

          int d_result1 = countries[i].data[len-day]['daily_vaccinations'] ?? -1;

          if (countries[i].data[len-day]['date'] == countries[k_indx].data[data_len - 1]['date']) {
            //d_vac
            if(d_result1 != -1)
              d_vac += countries[i].data[len-day]['daily_vaccinations'];
            else {
              if(len>1) {
                if(len - day - 1< 0)
                  continue;
                int d_result2 = countries[i].data[len - (day+1)]['daily_vaccinations'] ?? -2;
                if(d_result2 != -2)
                  d_vac += countries[i].data[len-(day+1)]['daily_vaccinations'];
              }
            }
          }else{
            //d_vac
            if(d_result1 != -1)
              d_vac += countries[i].data[len-day]['daily_vaccinations'];
            else {
              if(len - day - 1< 0)
                continue;
              if(len>1) {
                int d_result2 = countries[i].data[len - (day+1)]['daily_vaccinations'] ?? -2;
                if(d_result2 != -2)
                  d_vac += countries[i].data[len-(day+1)]['daily_vaccinations'];
              }
            }
          }
        }
        return d_vac;
      }

      total_vac_data = List.generate(7, (index) => (calcuate_tot_vac(7-index)/1000000000).toStringAsFixed(2), growable: true);
      total_vac_mon = List.generate(29, (index) => (calcuate_tot_vac(29-index)/1000000000).toStringAsFixed(2), growable: true);


      daily_vac_data = List.generate(7, (index) => (calcuate_daily_vac(7-index)/100000000).toStringAsFixed(2), growable: true);
      daily_vac_mon = List.generate(29, (index) => (calcuate_daily_vac(29-index)/10000000).toStringAsFixed(2), growable: true);

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

    Widget _thirdBoxView1(List<Country> countries) {
      int row = 8;
      int col = 4;
      var dataList = List.generate(row, (idx) => List(col), growable: false);

      dataList[0][0] = "Country";
      dataList[0][1] = "total";
      dataList[0][2] = "fully";
      dataList[0][3] = "daily";

      for(int i = 0; i < 7; i++){
        int len = countries[i].data.length;

        if(len > 0){
          String country_name = countries[i].country ?? "null";
          int result1 = countries[i].data[len-1]['total_vaccinations'] ?? -1;
          int result2 = countries[i].data[len-1]['people_fully_vaccinated'] ?? -2;
          int result3 = countries[i].data[len-1]['daily_vaccinations'] ?? -3;

          dataList[i+1][0] = country_name;

          if(result1 != -1)
            dataList[i+1][1] = result1.toString();
          else
            dataList[i+1][1] = "null";

          if(result2 != -2)
            dataList[i+1][2] = result2.toString();
          else
            dataList[i+1][2] = "null";

          if(result3 != -3)
            dataList[i+1][3] = result3.toString();
          else
            dataList[i+1][3] = "null";
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
                    Text(dataList[index][1]+"    ", style: TextStyle(fontSize: 14)),
                    Text(dataList[index][2], style: TextStyle(fontSize: 14)),
                    Text("      "+dataList[index][3], textAlign: TextAlign.right, style: TextStyle(fontSize: 14)),
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

    Widget _thirdBoxView2(List<Country> countries) {
      int row = countries.length+1;
      int col = 4;
      var dataList = List.generate(row, (idx) => List(col), growable: false);

      dataList[0][0] = "Country";
      dataList[0][1] = "total";
      dataList[0][2] = "fully";
      dataList[0][3] = "daily";

      for(int i = 0; i < countries.length; i++){
        int len = countries[i].data.length;

        if(len > 0){
          String country_name = countries[i].country ?? "null";
          int result1 = countries[i].data[len-1]['total_vaccinations'] ?? -1;
          int result2 = countries[i].data[len-1]['people_fully_vaccinated'] ?? -2;
          int result3 = countries[i].data[len-1]['daily_vaccinations'] ?? -3;

          dataList[i+1][0] = country_name;

          if(result1 != -1)
            dataList[i+1][1] = result1.toString();
          else
            dataList[i+1][1] = "null";

          if(result2 != -2)
            dataList[i+1][2] = result2.toString();
          else
            dataList[i+1][2] = "null";

          if(result3 != -3)
            dataList[i+1][3] = result3.toString();
          else
            dataList[i+1][3] = "null";
        }
      }

      for(int i = 1; i<countries.length+1; i++){
        for(int j = i; j < countries.length+1; j++) {
          if (int.parse(dataList[i][1]) < int.parse(dataList[j][1])) {
            var tmp = dataList[i];
            dataList[i] = dataList[j];
            dataList[j] = tmp;
          }
        }
      }

      return Flexible(
          child: Container(
            height: 180,
            width: 350,
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
                    Text(dataList[index][0]+"      ", textAlign: TextAlign.left, style: TextStyle(fontSize: 12)),
                    Text(dataList[index][1]+"    ", style: TextStyle(fontSize: 13)),
                    Text(dataList[index][2], style: TextStyle(fontSize: 13)),
                    Text("   "+dataList[index][3], textAlign: TextAlign.right, style: TextStyle(fontSize: 13)),
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
              child: FutureBuilder<List<Country>>(
                future: fetchCountry(http.Client()),
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
                  )),
                  Divider(
                    color: Colors.grey,
                    thickness: 2.0,
                    height: 5,
                  ),
                  if(bag["first"]==1)
                    FutureBuilder<List<Country>>(
                      future: fetchCountry(http.Client()),
                      builder: (context, snapshot){
                      if(snapshot.hasError) print(snapshot.error);

                      return snapshot.hasData
                      ? _secondBoxView(snapshot.data, bag["first"])
                          :Center(child: CircularProgressIndicator());
                      },
                    )

                  else if(bag["first"]==2)
                    FutureBuilder<List<Country>>(
                      future: fetchCountry(http.Client()),
                      builder: (context, snapshot){
                        if(snapshot.hasError) print(snapshot.error);

                        return snapshot.hasData
                            ? _secondBoxView(snapshot.data, bag["first"])
                            :Center(child: CircularProgressIndicator());
                      },
                    )
                  else if(bag["first"]==3)
                      FutureBuilder<List<Country>>(
                        future: fetchCountry(http.Client()),
                        builder: (context, snapshot){
                          if(snapshot.hasError) print(snapshot.error);

                          return snapshot.hasData
                              ? _secondBoxView(snapshot.data, bag["first"])
                              :Center(child: CircularProgressIndicator());
                        },
                      )
                  else if(bag["first"]==4)
                    FutureBuilder<List<Country>>(
                        future: fetchCountry(http.Client()),
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
                            child: Text("Country_name",
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
                            child: Text("Total_vacc",
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
                    FutureBuilder<List<Country>>(
                      future: fetchCountry(http.Client()),
                      builder: (context, snapshot){
                        if(snapshot.hasError) print(snapshot.error);

                        return snapshot.hasData
                            ? _thirdBoxView1(snapshot.data)
                            :Center(child: CircularProgressIndicator());
                      },
                    )
                  else if(bag["second"]==2)
                    FutureBuilder<List<Country>>(
                      future: fetchCountry(http.Client()),
                      builder: (context, snapshot){
                        if(snapshot.hasError) print(snapshot.error);

                        return snapshot.hasData
                            ? _thirdBoxView2(snapshot.data)
                            :Center(child: CircularProgressIndicator());
                      },
                    )
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
                "previous-page": "Vaccine Page",
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
        reservedSize: 20,

        getTitles: (value){
          return (value/10+double.parse(total_vac_data[0])).toStringAsFixed(2);

        },
        margin: 8,
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border.all(color: Colors.white, width: 1)),
      minY: (double.parse(total_vac_data[0])-double.parse(total_vac_data[0]))*10-0.05,
      maxY: (double.parse(total_vac_data[6])-double.parse(total_vac_data[0]))*10+1,
      lineBarsData: [
        LineChartBarData(
          colors: [Colors.blueAccent],
          spots: [
            FlSpot(0, (double.parse(total_vac_data[0])-double.parse(total_vac_data[0]))*10),
            FlSpot(1, (double.parse(total_vac_data[1])-double.parse(total_vac_data[0]))*10),
            FlSpot(2, (double.parse(total_vac_data[2])-double.parse(total_vac_data[0]))*10),
            FlSpot(3, (double.parse(total_vac_data[3])-double.parse(total_vac_data[0]))*10),
            FlSpot(4, (double.parse(total_vac_data[4])-double.parse(total_vac_data[0]))*10),
            FlSpot(5, (double.parse(total_vac_data[5])-double.parse(total_vac_data[0]))*10),
            FlSpot(6, (double.parse(total_vac_data[6])-double.parse(total_vac_data[0]))*10),
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
          reservedSize: 20,
          getTitles: (value){
            return (value.toDouble()/100+double.parse(daily_vac_data[0])).toStringAsFixed(2);
          },
          margin: 8,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white, width: 1)),
      minY: (double.parse(daily_vac_data[0])-double.parse(daily_vac_data[0]))*100-1,
      maxY: (double.parse(daily_vac_data[6])-double.parse(daily_vac_data[0]))*100+5,
      lineBarsData: [
        LineChartBarData(
          colors: [Colors.blueAccent],
          spots: [
            FlSpot(0, (double.parse(daily_vac_data[0])-double.parse(daily_vac_data[0]))*100),
            FlSpot(1, (double.parse(daily_vac_data[1])-double.parse(daily_vac_data[0]))*100),
            FlSpot(2, (double.parse(daily_vac_data[2])-double.parse(daily_vac_data[0]))*100),
            FlSpot(3, (double.parse(daily_vac_data[3])-double.parse(daily_vac_data[0]))*100),
            FlSpot(4, (double.parse(daily_vac_data[4])-double.parse(daily_vac_data[0]))*100),
            FlSpot(5, (double.parse(daily_vac_data[5])-double.parse(daily_vac_data[0]))*100),
            FlSpot(6, (double.parse(daily_vac_data[6])-double.parse(daily_vac_data[0]))*100),
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
          reservedSize: 25,
          textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 9.5,
          ),
          getTitles: (value){
            return (value/10+double.parse(total_vac_mon[0])).toStringAsFixed(2)+"M";
          },
          margin: 8,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white, width: 1)),
      minY: (double.parse(total_vac_mon[0])-double.parse(total_vac_mon[0]))*10-0.05,
      maxY: (double.parse(total_vac_mon[28])-double.parse(total_vac_mon[0]))*10+1,
      lineBarsData: [
        LineChartBarData(
          colors: [Colors.blueAccent],
          spots: [
            FlSpot(0, (double.parse(total_vac_mon[0])-double.parse(total_vac_mon[0]))*10),
            FlSpot(1, (double.parse(total_vac_mon[1])-double.parse(total_vac_mon[0]))*10),
            FlSpot(2, (double.parse(total_vac_mon[2])-double.parse(total_vac_mon[0]))*10),
            FlSpot(3, (double.parse(total_vac_mon[3])-double.parse(total_vac_mon[0]))*10),
            FlSpot(4, (double.parse(total_vac_mon[4])-double.parse(total_vac_mon[0]))*10),
            FlSpot(5, (double.parse(total_vac_mon[5])-double.parse(total_vac_mon[0]))*10),
            FlSpot(6, (double.parse(total_vac_mon[6])-double.parse(total_vac_mon[0]))*10),
            FlSpot(7, (double.parse(total_vac_mon[7])-double.parse(total_vac_mon[0]))*10),
            FlSpot(8, (double.parse(total_vac_mon[8])-double.parse(total_vac_mon[0]))*10),
            FlSpot(9, (double.parse(total_vac_mon[9])-double.parse(total_vac_mon[0]))*10),
            FlSpot(10, (double.parse(total_vac_mon[10])-double.parse(total_vac_mon[0]))*10),
            FlSpot(11, (double.parse(total_vac_mon[11])-double.parse(total_vac_mon[0]))*10),
            FlSpot(12, (double.parse(total_vac_mon[12])-double.parse(total_vac_mon[0]))*10),
            FlSpot(13, (double.parse(total_vac_mon[13])-double.parse(total_vac_mon[0]))*10),
            FlSpot(14, (double.parse(total_vac_mon[14])-double.parse(total_vac_mon[0]))*10),
            FlSpot(15, (double.parse(total_vac_mon[15])-double.parse(total_vac_mon[0]))*10),
            FlSpot(16, (double.parse(total_vac_mon[16])-double.parse(total_vac_mon[0]))*10),
            FlSpot(17, (double.parse(total_vac_mon[17])-double.parse(total_vac_mon[0]))*10),
            FlSpot(18, (double.parse(total_vac_mon[18])-double.parse(total_vac_mon[0]))*10),
            FlSpot(19, (double.parse(total_vac_mon[19])-double.parse(total_vac_mon[0]))*10),
            FlSpot(20, (double.parse(total_vac_mon[20])-double.parse(total_vac_mon[0]))*10),
            FlSpot(21, (double.parse(total_vac_mon[21])-double.parse(total_vac_mon[0]))*10),
            FlSpot(22, (double.parse(total_vac_mon[22])-double.parse(total_vac_mon[0]))*10),
            FlSpot(23, (double.parse(total_vac_mon[23])-double.parse(total_vac_mon[0]))*10),
            FlSpot(24, (double.parse(total_vac_mon[24])-double.parse(total_vac_mon[0]))*10),
            FlSpot(25, (double.parse(total_vac_mon[25])-double.parse(total_vac_mon[0]))*10),
            FlSpot(26, (double.parse(total_vac_mon[26])-double.parse(total_vac_mon[0]))*10),
            FlSpot(27, (double.parse(total_vac_mon[27])-double.parse(total_vac_mon[0]))*10),
            FlSpot(28, (double.parse(total_vac_mon[28])-double.parse(total_vac_mon[0]))*10),
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
            fontSize: 8.5,
          ),
          getTitles: (value){
            return (value.toDouble()/100+double.parse(daily_vac_mon[0])).toStringAsFixed(2)+"M";
          },
          margin: 8,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white, width: 1)),
      minY: (double.parse(daily_vac_mon[0])-double.parse(daily_vac_mon[0]))*100-1,
      maxY: (double.parse(daily_vac_mon[28])-double.parse(daily_vac_mon[0]))*100+20,
      lineBarsData: [
        LineChartBarData(
          colors: [Colors.blueAccent],
          spots: [
            FlSpot(0, (double.parse(daily_vac_mon[0])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(1, (double.parse(daily_vac_mon[1])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(2, (double.parse(daily_vac_mon[2])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(3, (double.parse(daily_vac_mon[3])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(4, (double.parse(daily_vac_mon[4])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(5, (double.parse(daily_vac_mon[5])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(6, (double.parse(daily_vac_mon[6])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(7, (double.parse(daily_vac_mon[7])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(8, (double.parse(daily_vac_mon[8])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(9, (double.parse(daily_vac_mon[9])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(10, (double.parse(daily_vac_mon[10])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(11, (double.parse(daily_vac_mon[11])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(12, (double.parse(daily_vac_mon[12])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(13, (double.parse(daily_vac_mon[13])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(14, (double.parse(daily_vac_mon[14])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(15, (double.parse(daily_vac_mon[15])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(16, (double.parse(daily_vac_mon[16])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(17, (double.parse(daily_vac_mon[17])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(18, (double.parse(daily_vac_mon[18])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(19, (double.parse(daily_vac_mon[19])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(20, (double.parse(daily_vac_mon[20])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(21, (double.parse(daily_vac_mon[21])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(22, (double.parse(daily_vac_mon[22])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(23, (double.parse(daily_vac_mon[23])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(24, (double.parse(daily_vac_mon[24])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(25, (double.parse(daily_vac_mon[25])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(26, (double.parse(daily_vac_mon[26])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(27, (double.parse(daily_vac_mon[27])-double.parse(daily_vac_mon[0]))*100),
            FlSpot(28, (double.parse(daily_vac_mon[28])-double.parse(daily_vac_mon[0]))*100),
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