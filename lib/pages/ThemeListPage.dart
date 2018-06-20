import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_zhihudaily/api/Api.dart';
import 'package:flutter_zhihudaily/constants/Constants.dart';
import 'package:flutter_zhihudaily/pages/MainPageDetail.dart';
import 'package:flutter_zhihudaily/pages/ThemePageDetail.dart';
import 'package:flutter_zhihudaily/utils/NetUtils.dart';
import 'package:flutter_zhihudaily/widgets/CommonEndLine.dart';

class ThemeListPage extends StatefulWidget {
  String id;
  String title;

  ThemeListPage(String id, String title) {
    this.id = id;
    this.title = title;
  }

  @override
  State createState() {
    return new ThemeListPageState(this.id, this.title);
  }
}

class ThemeListPageState extends State<ThemeListPage> {
  int currentPage = 1;
  ScrollController _scrollControl = new ScrollController();
  int listTotalSize = 0;
  var listData;
  String id;
  String title;

  ThemeListPageState(String id, String title) {
    this.id = id;
    this.title = title;
    _scrollControl.addListener(() {
      var maxScroll = _scrollControl.position.maxScrollExtent;
      var pixels = _scrollControl.position.pixels;
      if (maxScroll == pixels && listData.length < listTotalSize) {
        currentPage++;
        getThemeListPages(true);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getThemeListPages(false);
  }

  Future<Null> _pullToRefresh() async {
    currentPage = 1;
    getThemeListPages(false);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (listData == null) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      Widget listView = new ListView.builder(
        itemCount: listData.length,
        itemBuilder: (context, i) => renderRow(context, i),
        controller: _scrollControl,
      );
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(title, style: new TextStyle(color: Colors.white)),
          iconTheme: new IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: new RefreshIndicator(child: listView, onRefresh: _pullToRefresh),
      );
//      return new RefreshIndicator(child: listView, onRefresh: _pullToRefresh);
    }
  }

  Widget renderRow(BuildContext context, int i) {
    i -= 1;
    if (i.isOdd) {
      return new Divider(height: 1.0);
    }
    i = i ~/ 2;
    var itemData = listData[i];
    if (itemData is String && itemData == Constants.END_LINE_TAG) {
      return new CommonEndLine();
    }

    var thumbUrl = itemData['images'];
    var image = new Container(
      width: 60.0,
      height: 60.0,
      decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFECECEC),
          image: new DecorationImage(
              image: new ExactAssetImage('./images/ic_img_default.jpg'),
              fit: BoxFit.cover),
          border: new Border.all(
            color: const Color(0xFFECECEC),
            width: 2.0,
          )),
    );

    if (thumbUrl != null && thumbUrl.length > 0) {
      image = new Container(
        width: 60.0,
        height: 60.0,
        decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            color: const Color(0xFFECECEC),
            image: new DecorationImage(
                image: new NetworkImage(thumbUrl[0]), fit: BoxFit.cover),
            border: new Border.all(
              color: const Color(0xFFECECEC),
              width: 2.0,
            )),
      );
    }

    var row = new Container(
      padding: const EdgeInsets.all(10.0),
      child: new Row(
        children: <Widget>[
          image,
          new Expanded(
            flex: 1,
            child: new Padding(
              padding: const EdgeInsets.all(10.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    itemData['title'],
                    style: new TextStyle(fontSize: 14.0),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return new InkWell(
      child: row,
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (ctx) =>
                new ThemePageDetail(id: itemData["id"].toString())));
      },
    );
  }

  void getThemeListPages(bool isMore) {
    String url = Api.ZHIHU_HOST + "theme/" + this.id;

    NetUtils.get(url, (data) {
      if (data != null) {
        Map<String, dynamic> map = json.decode(data);
        print("the listData count is ***************" +
            map['stories'].length.toString());
        if (map['stories'].length != 0) {
          listTotalSize = map['stories'].length;
          var _listData = map['stories'];
          setState(() {
            if (!isMore) {
              listData = _listData;
              print(
                  "the listData of ThemePage is ******" + listData.toString());
            } else {
              List list1 = new List();
              list1.addAll(listData);
              list1.addAll(_listData);
              if (list1.length >= listTotalSize) {
                list1.add(Constants.END_LINE_TAG);
              }
              listData = list1;
            }
          });
        }
      }
    }, errorCallback: (e) {
      print("get news list error: $e");
    });
  }
}
