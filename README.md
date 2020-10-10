# listenable_collections

A collection of Dart collections that behave like ValueNotifier if their data changes.

Currently `ListNotifier` is implemented

planed are:

* MapNotifier
* SetNotifier

Please check the API documentation for more details

**PRs  for other collections or test are very welcome**

#### Example for ListNotifier:


```Dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:listenable_collections/listenable_collections.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'List Notifier Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _list = ListNotifier();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              actionsButtonMenu,
              ValueListenableBuilder(
                valueListenable: _list,
                builder: (context, value, child) => Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _list.map<Widget>((value) => Text('List Item: $value')).toList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Row get actionsButtonMenu => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RaisedButton(
            onPressed: _addItem,
            child: Icon(Icons.add),
          ),
          SizedBox(
            width: 16.0,
          ),
          RaisedButton(
            onPressed: _removeItem,
            child: Icon(Icons.remove),
          ),
          SizedBox(
            width: 16.0,
          ),
          RaisedButton(
            onPressed: _clearAllItems,
            child: Icon(Icons.delete),
          ),
        ],
      );

  void _addItem() {
    _list.add('${_list.length}');
  }

  void _removeItem() {
    if (_list.isNotEmpty) _list.removeLast();
  }

  void _clearAllItems() {
    if (_list.isNotEmpty) _list.clear();
  }
}
```
