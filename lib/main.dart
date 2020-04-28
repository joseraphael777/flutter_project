import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<String> getData() async {
    var response = await http.get(Uri.encodeFull(dataUrl), headers: {"Accept": "application/json"});

    setState(() {
    var extractData = json.decode(response.body);
    dishes = extractData[0]["table_menu_list"];
    print(dishes.length);
    _tabController = TabController(length: dishes.length, vsync: this,initialIndex: 0);
    showTab = true;
    });
    return response.body;
  }

  @override
  void initState() {
    super.initState();
    getData(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('UNI Resto Cafe', style: TextStyle(color: Colors.grey[800])),
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
                  Icon(Icons.shopping_cart,color: Colors.black,),
                  new Positioned(
                      top: 1.0,
                      right: -3.0,
                      child: Container(
                          height: 15,
                          width: 15,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(5)
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
            visible: showTab == true?true:false,
            child: bodyItem()
          ),
          Visibility(
            visible: showTab == false? true: false,
            child: Center(
              child: Container(
                padding: EdgeInsets.only(top: 100.0),
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
            )
          );
  }

  Widget listTileTitle(index) {
    return Column(
      children: [
      Row(
      children: [
        Column(children: [
          Container(
            width: 250,
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
            Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 15,top: 5,bottom: 5),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if(itemCount > 0){
                          itemCount -= 1;
                        }
                      });
                    },
                    child: Text(
                      '-',
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 25)
                      ),
                  ),
                )
              ],
            ),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 7,bottom: 5),
                  child: Text(
                  itemCount.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 20)
                  )
                )
              ],
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.only(right: 15,top: 5,bottom: 5),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        itemCount += 1;
                      });
                    },
                    child: Text(
                      '+',
                      style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 25)
                      ),
                  ),
                )
              ],
            )
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
