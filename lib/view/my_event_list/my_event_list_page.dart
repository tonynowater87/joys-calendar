import 'package:flutter/material.dart';

class MyEventListPage extends StatefulWidget {
  const MyEventListPage({Key? key}) : super(key: key);

  @override
  State<MyEventListPage> createState() => _MyEventListPageState();
}

class _MyEventListPageState extends State<MyEventListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的我的日曆列表'),
      ),
      body: Center(
        child: Placeholder(),
      ),
    );
  }
}
