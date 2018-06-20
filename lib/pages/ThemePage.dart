import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_zhihudaily/api/Api.dart';
import 'package:flutter_zhihudaily/pages/ThemeListPage.dart';
import 'package:flutter_zhihudaily/utils/NetUtils.dart';

import 'package:path/path.dart';

class ThemePage extends StatefulWidget {
  @override
  State createState() {
    return new ThemePageState();
  }
}

class ThemePageState extends State<ThemePage> {
  int currentPage = 1;
  var listData;
  int listTotalSize = 0;
  double width = 0.0;

  ScrollController _controller = new ScrollController();
  TextStyle titleStyle = new TextStyle(
    fontSize: 18.0,
  );
  TextStyle subTitleStyle =
      new TextStyle(color: const Color(0xFFB5BDC0), fontSize: 14.0);

  ThemePageState() {
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll == pixels && listData.length < listTotalSize) {
        currentPage++;
        getThemeList(true);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getThemeList(false);
  }

  Future<Null> _pullToRefresh() async {
    currentPage = 1;
    getThemeList(true);
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
        itemCount: listData.length * 2,
        itemBuilder: (context, i) => renderColumn(context, i),
        controller: _controller,
      );
      return new RefreshIndicator(child: listView, onRefresh: _pullToRefresh);
    }
  }

  Widget renderColumn(BuildContext context, int i) {
    print("the enter the renderColumn method");
    i -= 1;
    if (i.isOdd) {
      return new Divider(height: 1.0);
    }
    i = i ~/ 2;
    var itemData = listData[i];
    var titleSection = new Container(
      padding: const EdgeInsets.all(16.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: new Text(itemData['name'], style: titleStyle),
          ),
          new Text(
            itemData['description'],
            style: subTitleStyle,
          ),
        ],
      ),
    );

    var column = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Container(
          width: MediaQuery.of(context).size.width,
          height: 200.0,
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            color: const Color(0xFFECECEC),
            image: new DecorationImage(
                image: new NetworkImage(itemData['thumbnail']),
                fit: BoxFit.cover),
            border: new Border.all(
              color: const Color(0xFFECECEC),
              width: 2.0,
            ),
          ),
        ),
        titleSection
      ],
    );

    return new InkWell(
      child: column,
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (ctx) => new ThemeListPage(
                itemData['id'].toString(), itemData['name'])));
      },
    );
  }

  void getThemeList(bool isMore) {
    String url = Api.THEME_PAGE;
    NetUtils.get(url, (data) {
      if (data != null) {
        Map<String, dynamic> map = json.decode(data);
        if (map['limit'] != 0) {
          listTotalSize = map['others'].length;
          var _listData = map['others'];
          setState(() {
            if (!isMore) {
              listData = _listData;
            } else {
              List list1 = new List();
              list1.addAll(listData);
              list1.addAll(_listData);
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
