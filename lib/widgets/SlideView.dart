import 'package:flutter/material.dart';
import 'package:flutter_zhihudaily/pages/MainPageDetail.dart';

class SlideView extends StatefulWidget {
  var data;

  SlideView(data) {
    this.data = data;
  }

  @override
  State<StatefulWidget> createState() {
    return new SlideViewState(data);
  }
}

class SlideViewState extends State<SlideView>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  List slideData;

  SlideViewState(data) {
    slideData = data;
  }

  @override
  void initState() {
    super.initState();
    tabController = new TabController(
        length: slideData == null ? 0 : slideData.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Widget generateCard() {
    return new Card(
      color: Colors.blue,
      child: new Image.asset(
        "images/ic_avatar_default.png",
        width: 20.0,
        height: 20.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if (slideData != null && slideData.length > 0) {
      for (var i = 0; i < slideData.length; i++) {
        var item = slideData[i];
        var imgUrl = item['image'];
        var title = item['title'];
        var detailUrl = item['id'].toString();
        items.add(new GestureDetector(
          onTap: () {
            // 点击跳转到详情
            Navigator.of(context).push(new MaterialPageRoute(
                builder: (ctx) => new MainPageDetail(id: detailUrl)));
          },
          child: new Stack(
            children: <Widget>[
              new Image.network(
                imgUrl,
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
            ],
          ),
        ));
      }
    }
    return new TabBarView(
      controller: tabController,
      children: items,
    );

//    return new Stack(
//      children: <Widget>[
//        new TabBarView(
//          controller: tabController,
//          children: items,
//        ),
//        new Container(
//          alignment: Alignment.bottomCenter,
//          color: Colors.transparent,
//          child:  new Dot(slideData.length),
//        )
//      ],
//    );
  }
}
