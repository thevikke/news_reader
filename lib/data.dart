import 'dart:convert';
import 'package:http/http.dart' as http;
import 'article.dart';

const url =
    "https://newsapi.org/v2/top-headlines?country=us&apiKey=a29e8afe2e9742d3a20254d2bbbb8a9b";

class Data {
  Future<List<Article>> fetchArticles(int pageSize, int page) async {
    Articles articles;

    var response = await http.get("$url&pageSize=$pageSize&page=$page");

    try {
      if (response.statusCode == 200) {
        articles = Articles.fromJson(
          json.decode(response.body),
        );
      }
    } catch (e) {
      print(e.toString());
    }
    return articles.articles;
  }
}
