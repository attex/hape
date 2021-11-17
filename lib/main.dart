import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:dino_game/og.dart';
import 'package:dino_game/plane.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'cactus.dart';
import 'cloud.dart';
import 'constants.dart';
import 'dart:typed_data';
import 'dino.dart';
import 'game-object.dart';
import 'ground.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Get Haped',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'GET HⱯPED'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  Dino dino = Dino();
  double runDistance = 0;
  double runVelocity = 50;
  int highscore = 0;

  AnimationController worldController;
  Duration lastUpdateCall = Duration();

  List<Cactus> cacti = [Cactus(worldLocation: Offset(200, 0))];

  List<Ground> ground = [
    Ground(worldLocation: Offset(0, 0)),
    Ground(worldLocation: Offset(groundSprite.imageWidth / 10, 0))
  ];

  List<Cloud> clouds = [
    Cloud(worldLocation: Offset(100, 20)),
    Cloud(worldLocation: Offset(200, 10)),
    Cloud(worldLocation: Offset(350, -10)),
  ];

  List<Plane> planes = [
    Plane(worldLocation: Offset(250, 30)),
    Plane(worldLocation: Offset(450, 10)),
  ];

  List<OG> og = [
    OG(worldLocation: Offset(2000, 0)),
  ];

  Uint8List bamData;

  AudioPlayer audioPlayer = AudioPlayer();
  @override
  void initState() {
    SharedPreferences.setMockInitialValues({});
    super.initState();
    worldController =
        AnimationController(vsync: this, duration: Duration(days: 99));
    worldController.addListener(_update);
    loadHighscore();
  }

  Future loadHighscore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    highscore = prefs.getInt('highscore') ?? 0;
  }

  Future saveHighscore(int score) async {
    if(score < highscore) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    highscore = score;
    prefs.setInt('highscore', score);
  }

  Future<Uint8List> getAssetData() async {
    var asset = await rootBundle.load("assets/music/music.wav");
    return asset.buffer.asUint8List();
  }

  Future<String> _loadFile() async {
    String path = "";
    final bytes = await getAssetData();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/audio.mp3');

    await file.writeAsBytes(bytes);
    if (file.existsSync()) {
      return file.path;
    } else {
      return path;
    }
  }

  void _play() async {
    if (Platform.isIOS) {
      String path = await _loadFile();
      _playiOSAudio(path);
    } else {
      Uint8List bytes = await getAssetData();
      _playAndroidAudio(bytes);
    }
  }

  void _playAndroidAudio(bytes) async {
    await audioPlayer.playBytes(bytes);
  }

  void _playiOSAudio(path) async {
    await audioPlayer.play(path, isLocal: true, volume: 0.3);
  }

  void _die() {
    setState(() {
      worldController.stop();
      dino.die();
      audioPlayer.stop();
    });
  }

  void _start() {
    _play();
    dino.run();
    worldController.forward();
    setState(() {});
  }

  void _restart() {
    runDistance = 0;
    runVelocity = 50;

    lastUpdateCall = Duration();
    cacti = [Cactus(worldLocation: Offset(200, 0))];
    ground = [
      Ground(worldLocation: Offset(0, 0)),
      Ground(worldLocation: Offset(groundSprite.imageWidth / 10, 0))
    ];
    clouds = [
      Cloud(worldLocation: Offset(100, 20)),
      Cloud(worldLocation: Offset(200, 10)),
      Cloud(worldLocation: Offset(350, -10)),
    ];

    planes = [
      Plane(worldLocation: Offset(150, 50)),
      Plane(worldLocation: Offset(300, 80)),
    ];

    og = [
      OG(worldLocation: Offset(2000, 0)),
    ];
    _start();
  }

  _update() {
    dino.update(lastUpdateCall, worldController.lastElapsedDuration);

    double elapsedTimeSeconds =
        (worldController.lastElapsedDuration - lastUpdateCall).inMilliseconds /
            1000;

    runDistance += runVelocity * elapsedTimeSeconds;

    Size screenSize = MediaQuery.of(context).size;

    Rect dinoRect = dino.getRect(screenSize, runDistance);
    for (Cactus cactus in cacti) {
      Rect obstacleRect = cactus.getRect(screenSize, runDistance);
      if (dinoRect.overlaps(obstacleRect)) {
        _die();
        saveHighscore(runDistance.toInt());
      }

      if (obstacleRect.right < 0) {
        setState(() {
          cacti.remove(cactus);
          cacti.add(Cactus(
              worldLocation:
                  Offset(runDistance + Random().nextInt(100) + 50, 0)));
        });
      }
    }

    for (Ground groundlet in ground) {
      if (groundlet.getRect(screenSize, runDistance).right < 0) {
        setState(() {
          ground.remove(groundlet);
          ground.add(Ground(
              worldLocation: Offset(
                  ground.last.worldLocation.dx + groundSprite.imageWidth / 10,
                  0)));
        });
      }
    }

    for (OG ogs in og) {
      if (ogs.getRect(screenSize, runDistance).right < 0) {
        setState(() {
          og.remove(ogs);
          og.add(OG(
              worldLocation:
                  Offset(runDistance + Random().nextInt(100) + 2500, 0)));
        });
      }
    }

    for (Cloud cloud in clouds) {
      if (cloud.getRect(screenSize, runDistance).right < 0) {
        setState(() {
          clouds.remove(cloud);
          clouds.add(Cloud(
              worldLocation: Offset(
                  clouds.last.worldLocation.dx + Random().nextInt(100) + 50,
                  Random().nextInt(40) - 20.0)));
        });
      }
    }

    for (Plane plane in planes) {
      if (plane.getRect(screenSize, runDistance).right < 0) {
        setState(() {
          planes.remove(plane);
          planes.add(Plane(
              worldLocation: Offset(
                  planes.last.worldLocation.dx + Random().nextInt(100) + 250,
                  Random().nextInt(40) + 50.0)));
        });
      }
    }

    lastUpdateCall = worldController.lastElapsedDuration;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    List<Widget> children = [];

    for (GameObject object in [
      ...clouds,
      ...planes,
      ...og,
      ...ground,
      ...cacti,
      dino
    ]) {
      children.add(AnimatedBuilder(
          animation: worldController,
          builder: (context, _) {
            Rect objectRect = object.getRect(screenSize, runDistance);
            return Positioned(
              left: objectRect.left,
              top: objectRect.top,
              width: objectRect.width,
              height: objectRect.height,
              child: object.render(),
            );
          }));
    }

    children.add(AnimatedBuilder(
        animation: worldController,
        builder: (context, _) {
          return Positioned(
            left: 10,
            top: 10,
            width: 300,
            height: 40,
            child: Text(
              "HI ${highscore.toString().padLeft(6, '0')} ${runDistance.toInt().toString().padLeft(6, '0')}",
              style: TextStyle(
                fontFamily: 'Raleway',
              ),
            ),
          );
        }));

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(widget.title),
          actions: [TextButton(onPressed: _launch, child: Text("JOIN"))],
        ),
        body: SafeArea(
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  dino.jump();
                },
                child: Column(
                  children: [
                    Flexible(
                      flex: 3,
                      child: Stack(
                        alignment: Alignment.center,
                        children: children,
                      ),
                    ),
                    Flexible(
                        flex: 2,
                        child: Container(
                          child: dino.isDead()
                              ? _restartWidget(runDistance)
                              : dino.isReady()
                                  ? _startWidget()
                                  : _runningWidget(),
                        ))
                  ],
                ))));
  }

  void _launch() async {
    String _url = "http://www.hapebeast.com";
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';
  }

  Widget _runningWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height:25),
          Text(
            "Tap to jump",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          _presented()
        ],
      ),
    );
  }

  Widget _startWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Step into the game fellow HAPE!",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5,
          ),
          Text("Join the gang on our amazing trip!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 5,
          ),
          Text("Enjoy the ride a let your fellow hapes be part of your score.",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 15,
          ),
          Center(
              child: TextButton(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(Size(200, 50)),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  onPressed: _start,
                  child: Text("Ride along HAPES!",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)))),
          Spacer(),
          _presented()
        ],
      ),
    );
  }

  Widget _restartWidget(distance) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 10,
          ),
          runDistance > highscore
              ? Text("New Highscore!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
              : Text(""),
          Text(
            "${runDistance.toInt().toString().padLeft(6, '0')}",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "Back on the road HAPE. You can do it!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 15,
          ),
          Center(
              child: TextButton(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all<Size>(Size(200, 50)),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  onPressed: _restart,
                  child: Text("HAPE again!",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)))),
          Spacer(),
          _presented()
        ],
      ),
    );
  }

  Widget _presented() {
    return Center(
        child: Text(
      "proudly presented by attex and magischermalakini",
      style: TextStyle(color: Colors.grey),
    ));
  }
}
