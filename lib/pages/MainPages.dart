import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_zhihudaily/api/Api.dart';
import 'package:flutter_zhihudaily/constants/Constants.dart';
import 'package:flutter_zhihudaily/pages/MainPageDetail.dart';
import 'package:flutter_zhihudaily/utils/NetUtils.dart';
import 'package:flutter_zhihudaily/widgets/CommonEndLine.dart';
import 'package:flutter_zhihudaily/widgets/DateText.dart';
import 'package:flutter_zhihudaily/widgets/SlideView.dart';

class MainPages extends StatefulWidget {
  @override
  State createState() {
    return new MainPagesState();
  }
}

class MainPagesState extends State<MainPages> {
  int currentPage = 1;
  var listData;
  var slideData;
  int listTotalSize = 0;
  String dateText;
  var isloadMore = true;
  var listDate = new List();

  ScrollController _scorollController = new ScrollController();
  TextStyle titleStyle = new TextStyle(
    fontSize: 15.0,
  );
  TextStyle subTitleStyle =
      new TextStyle(color: const Color(0xFFB5BDC0), fontSize: 12.0);

  MainPagesState() {
    _scorollController.addListener(() {
      var maxScroll = _scorollController.position.maxScrollExtent;
      var pixels = _scorollController.position.pixels;
      if (isloadMore &&
          maxScroll == pixels &&
          listData.length <= listTotalSize) {
        getNewList(true);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getNewList(false);
  }

  Future<Null> _pullToRefresh() async {
    currentPage = 1;
    getNewList(false);
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
        itemBuilder: (context, i) => renderRow(context, i),
        controller: _scorollController,
        physics: new AlwaysScrollableScrollPhysics(),
      );

//      return new NotificationListener(
//          onNotification: _onNotification,
//          child: new RefreshIndicator(child: listView, onRefresh: _pullToRefresh)
//      );

      return new RefreshIndicator(
        child: listView,
        onRefresh: _pullToRefresh,
      );
    }
  }

  getNewList(bool isMore) {
    String url = Api.MAIN_PAGE;
    var date;
    if (isMore) {
      date = new DateTime.now();
      var year = date.year;
      var month = date.month;
      var day = date.day - currentPage;
      dateText = new DateTime(year, month, day).toString().substring(0, 10);

      date = new DateTime(year, month, day)
          .toString()
          .substring(0, 10)
          .replaceAll("-", "");
      url = Api.MAIN_PAGE_BEFORE + date.toString();
      if (currentPage > 5) {
        isloadMore = false;
      }
    }

    NetUtils.get(url, (data) {
      if (data != null) {
        Map<String, dynamic> map = json.decode(data);
        if (map['date'] != 0) {
          listTotalSize += map['stories'].length;
          var _listData = map['stories'];
          var _slideData;
          if (!isMore) {
            _slideData = map['top_stories'];
          }
          setState(() {
            if (!isMore) {
              listData = _listData;
              slideData = _slideData;
            } else {
              List list1 = new List();
              list1.addAll(listData);
              list1.add(Constants.ADD_DATE_TEXT + dateText);
              list1.addAll(_listData);
              listTotalSize++;
              if (currentPage > 5) {
                list1.add(Constants.END_LINE_TAG);
                listTotalSize++;
              }
              listData = list1;
              currentPage++;
            }
          });
        }
      }
    }, errorCallback: (e) {
      print("get news list error: $e");
    });
  }

  Widget renderRow(BuildContext context, int i) {
    if (i == 0) {
      return new Container(
        height: 180.0,
        child: new SlideView(slideData),
      );
    }
    i -= 1;
    if (i.isOdd) {
      return new Divider(height: 1.0);
    }
    i = i ~/ 2;
    var itemData = listData[i];
    if (itemData is String && itemData == Constants.END_LINE_TAG) {
      return new CommonEndLine();
    }

    if (itemData is String &&
        itemData.substring(0, 8) == Constants.ADD_DATE_TEXT) {
      dateText = itemData.substring(8);
      return new DateText(dateText);
    }
    var titleRow = new Row(
      children: <Widget>[
        new Expanded(
          child: new Text(itemData['title'], style: titleStyle),
        )
      ],
    );
    var timeRow = new Row(
      children: <Widget>[
        new Container(
          width: 20.0,
          height: 20.0,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFECECEC),
            image: new DecorationImage(
                image: new NetworkImage(itemData['images'][0]),
                fit: BoxFit.cover),
            border: new Border.all(
              color: const Color(0xFFECECEC),
              width: 2.0,
            ),
          ),
        ),
      ],
    );
    var thumbImgUrl = itemData['images'][0];
    var thumbImg = new Container(
      margin: const EdgeInsets.all(10.0),
      width: 60.0,
      height: 60.0,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
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
    if (thumbImgUrl != null && thumbImgUrl.length > 0) {
      thumbImg = new Container(
        width: 60.0,
        height: 60.0,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFECECEC),
          image: new DecorationImage(
              image: new NetworkImage(thumbImgUrl), fit: BoxFit.cover),
          border: new Border.all(
            color: const Color(0xFFECECEC),
            width: 2.0,
          ),
        ),
      );
    }
    var row = new Row(
      children: <Widget>[
        new Expanded(
          flex: 1,
          child: new Padding(
            padding: const EdgeInsets.all(10.0),
            child: new Column(
              children: <Widget>[
                titleRow,
              ],
            ),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.all(6.0),
          child: new Container(
            color: const Color(0xFFECECEC),
            child: new Center(
              child: thumbImg,
            ),
          ),
        )
      ],
    );
    return new InkWell(
      child: row,
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(
            builder: (ctx) =>
                new MainPageDetail(id: itemData["id"].toString())));
      },
    );
  }
}
