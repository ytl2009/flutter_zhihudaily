import 'package:flutter/material.dart';
import 'package:flutter_zhihudaily/pages/MainPages.dart';
import 'package:flutter_zhihudaily/pages/ThemePage.dart';

void main() => runApp(new MyZhihuApp());

class MyZhihuApp extends StatefulWidget {
  @override
  State createState() {
    return new MyZhihuAppState();
  }
}

class MyZhihuAppState extends State<MyZhihuApp> {
  int _tabIndex = 0;
  final tabTextStyleNormal =
      new TextStyle(color: Colors.blueGrey, fontSize: 12.0);
  final tabTextStyleSelected =
      new TextStyle(color: Colors.cyan, fontSize: 12.0);

  var tabImages;
  var _body;
  var appTabbarTitle = ['主页', '主题'];

  Image getTabImage(path) {
    return new Image.asset(
      path,
      width: 20.0,
      height: 20.0,
    );
  }

  void initData() {
    if (tabImages == null) {
      tabImages = [
        [
          getTabImage('images/icon_main.png'),
          getTabImage('images/icon_main_selected.png')
        ],
        [
          getTabImage('images/icon_theme.png'),
          getTabImage('images/icon_theme_selected.png')
        ]
      ];
    }

    _body = new IndexedStack(
      children: <Widget>[new MainPages(), new ThemePage()],
      index: _tabIndex,
    );
  }

  TextStyle getTabTextStyle(int currentIndex) {
    if (currentIndex == _tabIndex) {
      return tabTextStyleSelected;
    } else {
      return tabTextStyleNormal;
    }
  }

  Image getTabIcon(int currentIndex) {
    if (currentIndex == _tabIndex) {
      return tabImages[currentIndex][1];
    } else {
      return tabImages[currentIndex][0];
    }
  }

  Text getTabBarTitle(int currentIndex) {
    return new Text(appTabbarTitle[currentIndex],
        style: getTabTextStyle(currentIndex));
  }

  @override
  Widget build(BuildContext context) {
    initData();
    return new MaterialApp(
      theme: new ThemeData(primaryColor: Colors.indigoAccent),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text(appTabbarTitle[_tabIndex],
              style: new TextStyle(color: Colors.white)),
          iconTheme: new IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: _body,
        bottomNavigationBar: new BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            new BottomNavigationBarItem(
              icon: getTabIcon(0),
              title: getTabBarTitle(0),
            ),
            new BottomNavigationBarItem(
                icon: getTabIcon(1), title: getTabBarTitle(1))
          ],
          currentIndex: _tabIndex,
          onTap: (index) {
            setState(() {
              _tabIndex = index;
            });
          },
        ),
      ),
    );
  }
}
