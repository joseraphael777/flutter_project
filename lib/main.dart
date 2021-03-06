import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNI Resto Cafe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  TabController _tabController;
  String dataUrl = 'https://www.mocky.io/v2/5dfccffc310000efc8d2c1ad';
  List dishes;
  List categoryItems = [];
  num itemIndex = 0;
  num itemCount = 0;
  bool showTab = false;
  HttpClient client = new HttpClient();
  


  Future<String> getData() async {
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    HttpClientRequest request = await client.getUrl(Uri.parse(dataUrl));
    request.headers.set('content-type', 'application/json');

      HttpClientResponse response = await request.close();

      String reply = await response.transform(utf8.decoder).join();

      print(reply);


    print('aaaaa');
    //var response = await http.get(Uri.encodeFull(dataUrl), headers: {"Accept": "application/json"});
    //var r = await Requests.get(dataUrl);
    print('ccccc');
    setState(() {
      print('bbbbb');
    var extractData = json.decode(reply);
    dishes = extractData[0]["table_menu_list"];
    _tabController = TabController(length: dishes.length, vsync: this,initialIndex: 0);
    showTab = true;
    });
    return reply;
  }

  @override
  void initState() {
    super.initState();
    getData();
    print('aaaa');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('UNI Resto Cafe ', style: TextStyle(color: Colors.grey[800])),
        leading: Icon(Icons.arrow_back,color: Colors.black,),
        bottom: showTab?  TabBar(
            controller: _tabController,
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            isScrollable: true,
            unselectedLabelColor: Colors.grey[800],
            onTap: (int index) {
              setState(() {
                getDishes(index);
              });
            },
            tabs: List<Tab>.generate(dishes.length, (int index) {
              return new Tab(
                child: Text(dishes[index]["menu_category"]),
              );
            })
            ): null,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 25),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Orders', style: TextStyle(color: Colors.grey[800], fontSize: 15, fontWeight: FontWeight.bold),),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      getData();
                    },
                    child: Icon(Icons.shopping_cart,color: Colors.black,),
                  ),
                  new Positioned(
                      top: 1.0,
                      right: 0.0,
                      child: Container(
                          height: 15,
                          width: 15,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Center(
                            child: new Text(
                          itemCount.toString(),
                          style: new TextStyle(
                              color: Colors.white,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                          )
                        )
                      ),
                ],
              )
            ],
          )
          )
        ],
      ),
      body: Stack(
        children: [
          Visibility(
            visible: showTab?true:false,
            child: bodyItem()
          ),
          Visibility(
            visible: showTab?false:true,
            child: Center(
              child: Container(
                padding: EdgeInsets.only(top: 10.0),
                child: CircularProgressIndicator(
                backgroundColor: Colors.transparent,
              ),
              ),
            )
            ),
        ],
      )
    );
  }

  Widget bodyItem() {
    return ListView.separated(
        shrinkWrap: true,
        itemCount: dishes == null? 0: dishes[itemIndex]["category_dishes"].length,
        separatorBuilder: (context, int index){
          return Divider();
        },
        itemBuilder: (context, int index) {
          return listViewTile(index);
        },
      );
  }

  Widget listViewTile(index) {
    return ListTile(
            dense: true,
            title: listTileTitle(index),
            subtitle: listTileSubtitle(index),
            trailing: Container(
              height: 60,
              width: 60,
              child: Image.network(dishes[itemIndex]["category_dishes"][index]["dish_image"],fit: BoxFit.cover,),
            ),
            leading: Container(
              width: 30,
              margin: EdgeInsets.only(left: 10),
              child: Image.asset(dishes[itemIndex]["category_dishes"][index]["dish_Type"] == 2?'assets/veg.png':'assets/nonVeg.png'),
            ),
          );
  }

  Widget listTileTitle(index) {
    return Column(
      children: [
      Row(
      children: [
        Column(children: [
          Container(
            width: 200,
            child:  Text(
            dishes[itemIndex]["category_dishes"][index]["dish_name"],
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.grey[800]))
          )
        ],),
      ],
      ),
      SizedBox(height: 5),
      Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(children: [
          Text(
            dishes[itemIndex]["category_dishes"][index]["dish_currency"].toString() + ' ' + dishes[itemIndex]["category_dishes"][index]["dish_price"].toString(),
            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey[800])
            )
        ],),
        Column(children: [
          Text(
            dishes[itemIndex]["category_dishes"][index]["dish_calories"].round().toString() + ' calories',
            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey[800])
          )
        ],)
      ],
      ),
      ],
      );
  }

  Widget listTileSubtitle(index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(dishes[itemIndex]["category_dishes"][index]["dish_description"]),
        SizedBox(height: 8),
        Container(
          alignment: Alignment.bottomLeft,
          width: 125,
          height: 40,
          //color: Colors.green,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.green
          ),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                      if(dishes[itemIndex]["category_dishes"][index]["itemCount"] != null) {
                        if(itemCount > 0 && dishes[itemIndex]["category_dishes"][index]["itemCount"] > 0){
                          itemCount -= 1;
                          dishes[itemIndex]["category_dishes"][index]["itemCount"] -= 1;
                        }
                      } else {
                        dishes[itemIndex]["category_dishes"][index]["itemCount"] = 0;
/*                         if(itemCount > 0){
                          itemCount -= 1;
                        } */
                      }
                    
                  });
              },
              child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 15,top: 0,bottom: 0),
                  child: Text(
                      '-',
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 30)
                      ),
                )
              ],
            ),
            ),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 7,bottom: 5),
                  child: Text( dishes[itemIndex]["category_dishes"][index]["itemCount"] != null?dishes[itemIndex]["category_dishes"][index]["itemCount"].toString():0.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20)
                  )
                )
              ],
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  if(dishes[itemIndex]["category_dishes"][index]["itemCount"] != null) {
                    dishes[itemIndex]["category_dishes"][index]["itemCount"] += 1;
                  } else {
                    dishes[itemIndex]["category_dishes"][index]["itemCount"] = 0;
                    dishes[itemIndex]["category_dishes"][index]["itemCount"] += 1; 
                  }
                  itemCount += 1;
                });
              },
              child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(right: 15,top: 0,bottom: 0),
                  child: Text(
                      '+',
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 30)
                      ),
                )
              ],
            )
            ),
          ],
        ),
        ),
        SizedBox(height: dishes[itemIndex]["category_dishes"][index]["addonCat"].length>0?8:0),
        Visibility(
          visible: dishes[itemIndex]["category_dishes"][index]["addonCat"].length>0? true:false,
          child: Text('Customizations available', style: TextStyle(fontSize: 15),)
          )
      ],
    );
  }

    getDishes(index){
      setState(() {
        itemIndex = index;
      });
    }
}
