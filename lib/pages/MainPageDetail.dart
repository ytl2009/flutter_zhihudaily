import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html_textview/flutter_html_text.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_zhihudaily/api/Api.dart';
import 'package:flutter_zhihudaily/htmlparse/flutter_html_view.dart';
import 'package:flutter_zhihudaily/utils/NetUtils.dart';
import 'package:flutter_zhihudaily/utils/flutter_html_widget.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;

class MainPageDetail extends StatefulWidget {
  String id;

  MainPageDetail({Key key, this.id}) : super(key: key);

  @override
  State createState() {
    return new MainPageDetailState(id: this.id);
  }
}

class MainPageDetailState extends State<MainPageDetail> {
  String id;
  bool loaded = false;
  String detailDataStr;
  final flutterWebViewPlugin = new FlutterWebviewPlugin();
  var contentData;

  final key = new UniqueKey();
  var image_source;
  var title;
  var image_url;

  MainPageDetailState({Key key, this.id});

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
          new HtmlWidget(
            html: contentData.toString(),
            key: key,
          ),
        ],
      ),
//        body: new HtmlWidget(html:contentData.toString(),key: key,),
//      body: new HtmlView(data: contentData.toString(),),
//      body: new HtmlTextView(data: contentData.toString()),
    );
  }

  getContent() {
    var url = Api.ZHIHU_HOST + "news/" + this.id;
    NetUtils.get(url, (data) {
      Map<String, dynamic> map = json.decode(data);
      var body = map['body'];
      image_source = map['image_source'];
      image_url = map['image'];
      title = map['title'];
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
    if (image_url == null) {
      return null;
    }
    return new Container(
        height: 400.0,
        child: new Stack(
          children: <Widget>[
            new Image.network(
              image_url,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            new Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent, //const Color(0x50000000),
                child: new Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: new Text(title,
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      )),
                )),
            new Container(
                alignment: Alignment.topRight,
                color: Colors.transparent, //const Color(0x50000000),
                child: new Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: new Text(image_source,
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      )),
                )),
          ],
        ));
  }
}
