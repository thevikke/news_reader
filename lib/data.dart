import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scoped_model/scoped_model.dart';
import 'article.dart';

const url =
    "https://newsapi.org/v2/top-headlines?country=us&apiKey=a29e8afe2e9742d3a20254d2bbbb8a9b";

class Data extends Model {
  List<Article> articles = List<Article>();
  fetchArticles(int pageSize, int page) async {
    print("$url&pageSize=$pageSize&page=$page");
    var response = await http.get("$url&pageSize=$pageSize&page=$page");

    try {
      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        print("page:$page");
        if (json['articles'] != null) {
          json['articles'].forEach((v) {
            articles.add(new Article.fromJson(v));
          });
          articles.forEach((article) {
            print(article.title);
          });
          notifyListeners();
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}

class DataRepository {
  DataRepository._private();
  bool _ready = false;
  List<Completer<Articles>> _listeners = List<Completer<Articles>>();

  Future<Articles> getArticlesList() async {
    if (_ready) {
      print("Init is ready, returning articles");
      return articleList;
    } else {
      print("Init not ready, returning articles.future");
      Completer<Articles> listener = Completer<Articles>();
      _listeners.add(listener);
      return listener.future;
    }
  }

  // Future<Articles> getMoreArticles() {
  //   if (_ready) {
  //   } else {
  //     print("Init not ready, returning articles.future");
  //     Completer<Articles> listener = Completer<Articles>();
  //     _listeners.add(listener);
  //     return listener.future;
  //   }
  // }

  Articles articleList;

  Future fetch(int pageSize, int page) async {
    try {
      articleList = null;
      print("Making call to api: $url");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print("Api call succesful with status: ${response.statusCode}");
        articleList = Articles.fromJson(
          json.decode(response.body),
        );
      }
    } catch (e) {
      print("Api call failed with error : $e");
    }

    _ready = true;
    for (var listener in _listeners) {
      listener.complete(articleList);
    }
    _listeners = List<Completer<Articles>>();
  }
}
