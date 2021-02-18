import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {

  String _result = '';
  List data;
  TextEditingController _editingController;
  ScrollController _scrollController;
  int page=1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = new List();
    _editingController=new TextEditingController();
    _scrollController= new ScrollController();

    _scrollController.addListener(() {
      if(_scrollController.offset>=
      _scrollController.position.maxScrollExtent &&! _scrollController.position.outOfRange){
        print('bottom');
        page++;
        google();
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _editingController,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(hintText: '검색어를 입력하세요'),
        ),
      ),
      body: Container(
        child: Center(
            child: data.length == 0 ? Text(
              '데이터가 없습니다.', style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,) :
            ListView.builder(itemBuilder: (context, index) {
              return Card(
                child: Container(
                    child: Row(
                        children: [
                          Image.network(data[index]['thumbnail'],
                          height: 100,width: 100,fit: BoxFit.contain),
                        Column(
                          children: [
                            Container(
                              width:MediaQuery.of(context).size.width -150,
                              child:Text(data[index]['title'].toString(),
                              textAlign: TextAlign.center,),
                            ),
                Text('저자 :'+data[index]['authors'].toString()),
                Text('가격 :'+data[index]['sale_price'].toString()),
                Text('판매중 :'+data[index]['status'].toString()),

                ],
                        )
                        ,],mainAxisAlignment: MainAxisAlignment.start,
                    )
              )
              ,
              );
            }, itemCount: data.length,controller: _scrollController,)
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          page=1;
          data.clear();
          google();
        },
        child: Icon(Icons.file_download),
      ),
    );
  }

  Future<String> google() async {

    var url = 'https://dapi.kakao.com/v3/search/book?target=title&page=$page&query=${_editingController.value.text}';
    var response = await http.get(Uri.encodeFull(url),
        headers: {'Authorization': 'KakaoAK 8f766dcb354b07869bd1e2572de8db8d'});
    setState(() {
      var dataConvertedToJSON = json.decode(response.body);
      List result = dataConvertedToJSON['documents'];
      data.addAll(result);
      print(result);
    });

    return response.body;
  }
}
