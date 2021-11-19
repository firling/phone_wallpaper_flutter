import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class Unsplash {

  String id;
  String? description;
  String regularUrl;
  String fullUrl;
  String rawUrl; //For downloading image only
  String userName; //Attribution to the photographer
  String userProfileUrl; //Photographer's profile
  String userProfileImage; //Photographer's profile image
  int likes;
  String? blurHash; //Optional
  String? downloadLocation; //Optional
  Color? color; //Optional

  Unsplash({
    required this.id,
    this.description,
    required this.regularUrl,
    required this.fullUrl,
    required this.rawUrl,
    required this.userName,
    required this.userProfileUrl,
    required this.userProfileImage,
    required this.likes,
    this.blurHash,
    this.downloadLocation,
    this.color
  });

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  factory Unsplash.fromJson(Map<String, dynamic> json) {
    return Unsplash(
      id: json['id'],
      description: json['description'],
      regularUrl: json['urls']['regular'],
      fullUrl: json['urls']['full'],
      rawUrl: json['urls']['raw'],
      userName: json['user']['username'],
      userProfileUrl: json['user']['links']['self'],
      userProfileImage: json['user']['profile_image']['small'],
      likes: json['likes'],
      blurHash: json['blur_hash'],
      downloadLocation: json['links']['download_location'],
      color: Color(int.parse(json['color'].substring(1, 7), radix: 16) + 0xFF000000),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<String> imageUrlListToDisplay = [
    "https://picsum.photos/id/1000/800/800",
    "https://picsum.photos/id/1005/800/800",
    "https://picsum.photos/id/1004/800/800"
  ];

  late List<Unsplash> images;

  void initState() {
    super.initState();
    // NOTE: Calling this function here would crash the app.

    _fetchImages().then((value) => images = value);
  }

  Future<List<Unsplash>> _fetchImages() async {
    final response = await http
                            .get(Uri.parse('https://api.unsplash.com/photos?client_id=dgd3rbzquWKRfMdqYlPOnQJ4Clg9ow5hg-9sqUSjiSw&per_page=30&page=0'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      List<Unsplash> images = [];

      jsonDecode(response.body).forEach((elt) => {
        images.add(Unsplash.fromJson(elt))
      });

      return images;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: GridView.count(
          crossAxisCount: 2,
          children: List.generate(images.length, (index) {
            return Container(
                margin: const EdgeInsets.all(10.0),
                child: FlatButton(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                        images[index].regularUrl,
                        fit: BoxFit.fill
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SecondRoute(image: images[index])),
                    );
                  },
                ),
            );
          }),
        )
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  const SecondRoute({Key? key, required this.image}) : super(key: key);

  final Unsplash image;

  void _launchURL() async =>
      await canLaunch(image.userProfileUrl) ? await launch(image.userProfileUrl) : throw 'Could not launch $image.userProfileUrl';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 500,
        height: 1000,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(
                  image.regularUrl
                ),
                fit: BoxFit.cover
            )
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('<'),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(10.0),
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget> [
                                Text(image.description == null ? "" : image.description!)
                              ]
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.all(10.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _launchURL();
                                  },
                                  child: Text('Download'),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(10.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _launchURL();
                                  },
                                  child: Text('Show profile'),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    )
                  )
                ],
              )
            ]
        )
      ),
    );
  }
}
