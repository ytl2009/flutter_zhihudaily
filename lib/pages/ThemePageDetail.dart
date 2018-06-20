import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zhihudaily/api/Api.dart';
import 'package:flutter_zhihudaily/utils/NetUtils.dart';
import 'package:flutter_zhihudaily/utils/flutter_html_widget.dart';

class ThemePageDetail extends StatefulWidget {
  String id;

  ThemePageDetail({Key key, this.id}) : super(key: key);

  @override
  State createState() {
    return new ThemePageDetailState(id:this.id);
  }
}

class ThemePageDetailState extends State<ThemePageDetail> {
  String id;
  bool loaded = false;
  String detailDataStr;

  var contentData;

  final key = new UniqueKey();
  var title;
  var image_url;

  var textwidget;

  ThemePageDetailState({Key key, this.id});

  @override
  void initState() {
    super.initState();
    getContent();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> titleContent = [];
    titleContent.add(new Text(
      "详情",
      style: new TextStyle(color: Colors.white),
    ));
    if (!loaded) {
      titleContent.add(new CupertinoActivityIndicator());
    }
    titleContent.add(new Container(width: 50.0));

   textwidget = new HtmlWidget(
      html: contentData.toString(),
      key: key,
    );
    return new Scaffold(
      appBar: new AppBar(
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: titleContent,
        ),
        iconTheme: new IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: new ListView(
        children: <Widget>[
          renderTitle(),
          !loaded ? new Text(" ") : textwidget,
        ],
      ),
    );
  }


  getContent() {
    var url = Api.ZHIHU_HOST + "news/" + this.id;
    NetUtils.get(url, (data) {
      Map<String, dynamic> map = json.decode(data);
      var body = map['body'];
      if (map.containsKey('title')) {
        title = map['title'];
      }
      if (map.containsKey('images')) {
        image_url = map['images'][0];
      }
      if (data != null) {
        setState(() {
          loaded = true;
          contentData = body;
        });
      }
    }, errorCallback: (e) {
      print("get news list error: $e");
    });
  }

  Widget renderTitle() {
    var  img =  new Container(
      width: MediaQuery.of(context).size.width,
      height: 400.0,
      decoration: new BoxDecoration(
        shape: BoxShape.rectangle,
        color: const Color(0xFFECECEC),
        image: new DecorationImage(
            image: new ExactAssetImage('./images/ic_img_default.jpg'),
            fit: BoxFit.cover),
        border: new Border.all(
          color: const Color(0xFFECECEC),
          width: 2.0,
        ),
      ),
    );

    if (image_url != null && image_url.length>0) {
      img =  new Container(
        width: MediaQuery.of(context).size.width,
        height: 400.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFECECEC),
          image: new DecorationImage(
              image: new NetworkImage(image_url),
              fit: BoxFit.cover),
          border: new Border.all(
            color: const Color(0xFFECECEC),
            width: 2.0,
          ),
        ),
      );
    }

    return new Container(
        height: 400.0,
        child: new Stack(
          children: <Widget>[
            img,
            new Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent, //const Color(0x50000000),
                child: new Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: new Text(title==null ? "" : title,
                      style: new TextStyle(
                        color: image_url==null ? Colors.black : Colors.white,
                        fontSize: 18.0,
                      )),
                )),
          ],
        ));
  }
}
