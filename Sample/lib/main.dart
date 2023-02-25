import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audio_streamer/audio_streamer.dart';

List<CameraDescription> cameras = [];
String _lastWords = "";

final _streamer = AudioStreamer();
bool _isRecordingAudio = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CameraController controller;
  List<int> list=List.generate(5, (index) => index);
  List<bool> values=List.generate(5, (index) => false);
  //音声認識
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  List<double> buffer = [];

  //タイトル名
  static const title = 'アプリのタイトル';
  //ラベル
  static const labelAurora = 'オーロラ';
  static const labelVoiceRec = '音声認識';
  static const labelSignLangRec = '手話認識';
  static const labelSignLangKeyboard = '手話表示';
  //タップ判定
  bool isAuroraChanged = false;
  bool isVoiceRecChanged = false;
  bool isSignLangRecChanged = false;
  bool isSignLangKeyboardChanged = false;
  //Index
  static const auroraIndex = 0;
  static const voiceRecIndex = 1;
  static const signLangRecIndex = 2;
  static const signLangKeyboardIndex = 3;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    _initSpeech();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      if (index == auroraIndex) {
        if (!isAuroraChanged) {
          _auroraEventOn();
          isAuroraChanged = true;
        } else {
          _auroraEventOff();
          isAuroraChanged = false;
        }
      }
      if (index == voiceRecIndex) {
        if (!isVoiceRecChanged) {
          _voiceRecEventOn();
          isVoiceRecChanged = true;
        } else {
          _voiceRecEventOff();
          isVoiceRecChanged = false;
        }
      }
      if (index == signLangRecIndex) {
        if (!isSignLangRecChanged) {
          _signLangRecEventOn();
          isSignLangRecChanged = true;
        } else {
          isSignLangRecChanged = false;
        }
      }
      if (index == signLangKeyboardIndex) {
        if (!isSignLangKeyboardChanged) {
          _signLangKeyboardEventOn();
          isSignLangKeyboardChanged = true;
        } else {
          isSignLangKeyboardChanged = false;
        }
      }
      _selectedIndex = index;
    });
  }

  //オーロラボタンイベント
  void _auroraEventOn() {
    //start();
  }
  void _auroraEventOff() {
    //stop();
  }
  //音声認識ボタンイベント
  void _voiceRecEventOn() {
    _startListening();
    debugPrint('startListening');
  }
  void _voiceRecEventOff() {
    _stopListening();
    debugPrint('stopListening');
  }
  //手話認識ボタンイベント
  void _signLangRecEventOn() {
  }
  void _signLangRecEventOff() {
  }
  //手話表示ボタンイベント
  void _signLangKeyboardEventOn() {
  }
  void _signLangKeyboardEventOff() {
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    _lastWords = "";
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
       _lastWords = result.recognizedWords;
      _startListening();
    });
  }

  //音声変換の検証分コメント
  //void onAudio(List<double> buffer) {
  //  setState(() {
  //    this.buffer = buffer;
  //  });
  //  debugPrint('buffer');
  //  debugPrint(buffer.toString());
  //}
  //void handleError(PlatformException error) {
  //  debugPrint('error');
  //  debugPrint(error.toString());
  //}

  //void start() async {
  //  try {
  //    await _streamer.start(onAudio, handleError);
  //    setState(() {
  //      _isRecordingAudio = true;
  //    });
  //  } catch (error) {
  //    debugPrint('catch-error');
  //    debugPrint(error.toString());
  //  }
  //}

  //void stop() async {
  //  debugPrint('stop');
  //  await _streamer.stop();
  //  bool stopped = await _streamer.stop();
  //  setState(() {
  //    _isRecordingAudio = stopped;
  //  });
  //}

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container(
      );
    }
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
        appBar: AppBar(
            title: const Text(title, style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.blue,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(isAuroraChanged ? Icons.mode_standby : Icons.circle_outlined), label: labelAurora),
            BottomNavigationBarItem(icon: Icon(isVoiceRecChanged ? Icons.mode_standby : Icons.circle_outlined), label: labelVoiceRec),
            BottomNavigationBarItem(icon: Icon(isSignLangRecChanged ? Icons.mode_standby : Icons.circle_outlined), label: labelSignLangRec),
            BottomNavigationBarItem(icon: Icon(isSignLangKeyboardChanged ? Icons.keyboard_alt_rounded : Icons.keyboard_alt_outlined), label: labelSignLangKeyboard),
          ],
          type: BottomNavigationBarType.fixed,
        ),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CameraPreview(controller),
              Opacity(
                opacity: 0.6,//透明度を調整
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      isAuroraChanged ? Container(
                        width: 250,
                        height: 600,
                        color: Colors.red.withOpacity(0.2),
                        alignment: const Alignment(0.0, 0.0),
                        child: const Text(
                            '',
                            //labelAurora,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.white
                            ),
                        ),
                      ) : Container(),
                      isVoiceRecChanged ? Container(
                        width: 250,
                        height: 100,
                        color: Colors.black,
                        alignment: const Alignment(0.0, 0.0),
                        child: Text(
                          _lastWords,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.white
                          ),
                        ),
                      ) : Container(),
                      isSignLangRecChanged ? Container() : Container(),
                      //isSignLangRecChanged ? Container(
                      //  width: 250,
                      //  height: 100,
                      //  color: Colors.green,
                      //  alignment: const Alignment(0.0, 0.0),
                      //  child: const Text(
                      //    labelSignLangRec,
                      //    style: TextStyle(
                      //        fontWeight: FontWeight.bold,
                      //        fontSize: 30,
                      //        color: Colors.white
                      //    ),
                      //  ),
                      //) : Container(),
                      isSignLangKeyboardChanged ? Container() : Container(),
                      //isSignLangKeyboardChanged ? Container(
                      //  width: 250,
                      //  height: 100,
                      //  color: Colors.orange,
                      //  alignment: const Alignment(0.0, 0.0),
                      //  child: const Text(
                      //    labelSignLangKeyboard,
                      //    style: TextStyle(
                      //        fontWeight: FontWeight.bold,
                      //        fontSize: 30,
                      //        color: Colors.white
                      //    ),
                      //  ),
                      //) : Container(),
                    ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//デフォルトソース
//import 'package:flutter/material.dart';
//
//void main() {
//  runApp(const MyApp());
//}
//
//class MyApp extends StatelessWidget {
//  const MyApp({super.key});
//
//  // This widget is the root of your application.
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      title: 'Flutter Demo',
//      theme: ThemeData(
//        // This is the theme of your application.
//        //
//        // Try running your application with "flutter run". You'll see the
//        // application has a blue toolbar. Then, without quitting the app, try
//        // changing the primarySwatch below to Colors.green and then invoke
//        // "hot reload" (press "r" in the console where you ran "flutter run",
//        // or simply save your changes to "hot reload" in a Flutter IDE).
//        // Notice that the counter didn't reset back to zero; the application
//        // is not restarted.
//        primarySwatch: Colors.blue,
//      ),
//      home: const MyHomePage(title: 'Flutter Demo Home Page'),
//    );
//  }
//}
//
//class MyHomePage extends StatefulWidget {
//  const MyHomePage({super.key, required this.title});
//
//  // This widget is the home page of your application. It is stateful, meaning
//  // that it has a State object (defined below) that contains fields that affect
//  // how it looks.
//
//  // This class is the configuration for the state. It holds the values (in this
//  // case the title) provided by the parent (in this case the App widget) and
//  // used by the build method of the State. Fields in a Widget subclass are
//  // always marked "final".
//
//  final String title;
//
//  @override
//  State<MyHomePage> createState() => _MyHomePageState();
//}
//
//class _MyHomePageState extends State<MyHomePage> {
//  int _counter = 0;
//
//  void _incrementCounter() {
//    setState(() {
//      // This call to setState tells the Flutter framework that something has
//      // changed in this State, which causes it to rerun the build method below
//      // so that the display can reflect the updated values. If we changed
//      // _counter without calling setState(), then the build method would not be
//      // called again, and so nothing would appear to happen.
//      _counter++;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // This method is rerun every time setState is called, for instance as done
//    // by the _incrementCounter method above.
//    //
//    // The Flutter framework has been optimized to make rerunning build methods
//    // fast, so that you can just rebuild anything that needs updating rather
//    // than having to individually change instances of widgets.
//    return Scaffold(
//      appBar: AppBar(
//        // Here we take the value from the MyHomePage object that was created by
//        // the App.build method, and use it to set our appbar title.
//        title: Text(widget.title),
//      ),
//      body: Center(
//        // Center is a layout widget. It takes a single child and positions it
//        // in the middle of the parent.
//        child: Column(
//          // Column is also a layout widget. It takes a list of children and
//          // arranges them vertically. By default, it sizes itself to fit its
//          // children horizontally, and tries to be as tall as its parent.
//          //
//          // Invoke "debug painting" (press "p" in the console, choose the
//          // "Toggle Debug Paint" action from the Flutter Inspector in Android
//          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//          // to see the wireframe for each widget.
//          //
//          // Column has various properties to control how it sizes itself and
//          // how it positions its children. Here we use mainAxisAlignment to
//          // center the children vertically; the main axis here is the vertical
//          // axis because Columns are vertical (the cross axis would be
//          // horizontal).
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            const Text(
//              'You have pushed the button this many times:',
//            ),
//            Text(
//              '$_counter',
//              style: Theme.of(context).textTheme.headline4,
//            ),
//          ],
//        ),
//      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: _incrementCounter,
//        tooltip: 'Increment',
//        child: const Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
//    );
//  }
//}
