import 'package:flutter/material.dart';
import 'package:joys_calendar/view/search_result/search_result_argument.dart';

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({Key? key}) : super(key: key);

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  SearchResultArguments? args;

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context)!.settings.arguments as SearchResultArguments;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('搜尋 ${args?.keyword}'),
      ),
      body: Center(
        child: Container(
          child: Text('SearchResultPage, args=${args?.keyword}'),
        ),
      ),
    );
  }
}
