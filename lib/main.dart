import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news_reader/article.dart';
import 'package:news_reader/data.dart';
import 'package:flutter_fluid_slider/flutter_fluid_slider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

///! This project is on hold until I get proper news api
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News Reader',
      home: Scaffold(
        body: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController controller;
  Data articleData = Data();
  final int pageSize = 15;
  int page = 1;
  @override
  void initState() {
    articleData.fetchArticles(pageSize, page);
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      articleData.fetchArticles(pageSize, page + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<Data>(
      model: articleData,
      child: ScopedModelDescendant<Data>(
        builder: (context, child, model) {
          return model.articles.length != 0
              ? Container(
                  // Background color.
                  color: Colors.grey[200],
                  child: CustomScrollView(
                    controller: controller,
                    slivers: <Widget>[
                      SliverAppBar(
                        title: Text("terve"),
                        floating: true,
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            var data = model.articles;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      children: <Widget>[
                                        // Image.network(data[index].urlToImage ??=
                                        //     "http://via.placeholder.com/350x150"),
                                        CachedNetworkImage(
                                          imageUrl: data[index].urlToImage ??=
                                              "http://via.placeholder.com/350x150",
                                          placeholder: (context, url) =>
                                              new CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              new Icon(Icons.error),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(15),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Text(
                                                data[index].title ??= "Empty",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .title,
                                              ),
                                              Text(
                                                data[index].description ??=
                                                    "Empty",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subhead,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned.fill(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          splashColor: Colors.blueAccent,
                                          onTap: () {
                                            if (data[index].url != null) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ArticleWebPage(
                                                          data[index].url),
                                                ),
                                              );
                                            } else {
                                              Scaffold.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "Sorry we are missing url!"),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: model.articles.length,
                        ),
                      ),
                    ],
                  ))
              : Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
        },
      ),
    );
  }
}

class ArticleWebPage extends StatelessWidget {
  ArticleWebPage(this.url);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

class SpeedReaderPage extends StatefulWidget {
  SpeedReaderPage({this.article});
  final Article article;

  @override
  _SpeedReaderPageState createState() => _SpeedReaderPageState();
}

class _SpeedReaderPageState extends State<SpeedReaderPage> {
  List<String> _words;
  int _indexWords = 0;
  int _wpm = 100;
  bool _isReading = false;

  @override
  void initState() {
    _words = widget.article.content.split(" ");
    super.initState();
  }

  @override
  void dispose() {
    _isReading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            widget.article.title,
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                widget.article.content,
              ),
              Card(
                child: Container(
                  height: 150,
                  width: 200,
                  child: Center(
                    child: Text(
                      _words[_indexWords],
                      style: Theme.of(context).textTheme.body2.copyWith(
                            fontSize: 25,
                          ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_left),
                    onPressed: () {
                      if (_indexWords != 0) {
                        setState(() {
                          _isReading = false;
                          _indexWords--;
                        });
                      }
                    },
                    iconSize: 80,
                  ),
                  _isReading
                      ? IconButton(
                          icon: Icon(Icons.pause),
                          onPressed: _toggleReading,
                          iconSize: 80,
                        )
                      : IconButton(
                          icon: Icon(Icons.play_arrow),
                          iconSize: 80,
                          onPressed: () {
                            _toggleReading();
                          },
                        ),
                  IconButton(
                    icon: Icon(Icons.arrow_right),
                    iconSize: 80,
                    onPressed: () {
                      if (_indexWords != _words.length - 1) {
                        setState(() {
                          _isReading = false;
                          _indexWords++;
                        });
                      }
                    },
                  ),
                ],
              ),
              FluidSlider(
                sliderColor: Colors.grey[800],
                thumbColor: Colors.black,
                valueTextStyle: Theme.of(context).textTheme.title.copyWith(
                      color: Colors.white,
                    ),
                onChanged: (value) {
                  setState(() {
                    _wpm = value.toInt();
                  });
                },
                value: _wpm.toDouble(),
                min: 100,
                max: 600,
              )
            ],
          ),
        ));
  }

  Future _toggleReading() async {
    if (_isReading) {
      setState(() {
        _isReading = false;
      });
    } else {
      setState(() {
        _isReading = true;
      });
    }
    while (_indexWords != _words.length - 1 && _isReading) {
      setState(() {
        _indexWords++;
      });
      await sleep();
    }
    if (_indexWords == _words.length - 1) {
      setState(() {
        _indexWords = 0;
        _isReading = false;
      });
    }
  }

  Future sleep() {
    return Future.delayed(
      Duration(
        milliseconds: (60000 / _wpm).round(),
      ),
    );
  }
}
