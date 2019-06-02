import 'package:flutter/material.dart';
import 'package:news_reader/article.dart';
import 'package:news_reader/data.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News Reader',
      home: Scaffold(
        appBar: AppBar(
          title: Text('News Reader'),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
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
  Data data = Data();
  int pageSize = 15, page = 1;
  Future<List<Article>> fetchArticles;

  @override
  void initState() {
    fetchArticles = data.fetchArticles(pageSize, page);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchArticles,
      builder: (BuildContext context, AsyncSnapshot<List<Article>> snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView.builder(
                itemCount: pageSize,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: InkWell(
                      splashColor: Colors.black,
                      onTap: () {
                        if (snapshot.data[index].content != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => ArticlePage(
                                    article: snapshot.data[index],
                                  ),
                            ),
                          );
                        } else {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Sorry, no content!"),
                              backgroundColor: Colors.redAccent,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(
                              snapshot.data[index].title ??= "Empty",
                              style: Theme.of(context).textTheme.title,
                            ),
                            Text(
                              snapshot.data[index].description ??= "Empty",
                              style: Theme.of(context).textTheme.subtitle,
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class ArticlePage extends StatefulWidget {
  ArticlePage({this.article});
  final Article article;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.article.title),
          centerTitle: true,
          backgroundColor: Colors.grey[800],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(widget.article.content),
              Text(_words[_indexWords]),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_left),
                    onPressed: () {},
                  ),
                  _isReading
                      ? IconButton(
                          icon: Icon(Icons.pause),
                          onPressed: _toggleReading,
                        )
                      : IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: _toggleReading,
                        ),
                  IconButton(
                    icon: Icon(Icons.arrow_right),
                    onPressed: () {},
                  ),
                ],
              ),
              Slider(
                onChanged: (value) {
                  setState(() {
                    _wpm = value.toInt();
                  });
                },
                value: _wpm.toDouble(),
                min: 100,
                max: 500,
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
