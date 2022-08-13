import 'dart:developer';
import 'dart:io';

import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:html/parser.dart' show parse;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:text_to_speech/text_to_speech.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late EpubController _epubController;
  // TextToSpeech tts = TextToSpeech();

  @override
  void initState() {
    super.initState();
    // oninit();
    _epubController = EpubController(
      // Load document
      document: EpubDocument.openAsset('assets/epub.epub'),
      // Set start point
      // epubCfi: 'epubcfi(/6/6[chapter-2]!/4/2/1612)',
    );
  }

  oninit() async {
    await flutterTts.stop();
    await flutterTts.setLanguage("en-US");

    await flutterTts.setSpeechRate(0.5);

    await flutterTts.setVolume(1.0);

    await flutterTts.setPitch(1.0);
    await flutterTts
        .setVoice({"name": "hi-in-x-hid-network", "locale": "hi-IN"});

    await flutterTts.isLanguageAvailable("en-US");
  }

  fileee() async {
    final byteData = await rootBundle.load("assets/epub/epub.epub");
    final file = File("${(await getTemporaryDirectory()).path}/aaa.epub");
    await file.writeAsBytes(
        byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        mode: FileMode.writeOnly);

    final a = await file.readAsStringSync();
    print(a);
  }

  FlutterTts flutterTts = FlutterTts();

  String spechtext = "";
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          // Show actual chapter name
          title: EpubViewActualChapter(
              controller: _epubController,
              builder: (chapterValue) => Text(
                    'Chapter: ' +
                        (chapterValue?.chapter?.Title
                                ?.replaceAll('\n', '')
                                .trim() ??
                            ''),
                    textAlign: TextAlign.start,
                  )),
        ),
        // Show table of contents
        drawer: Drawer(
          child: EpubViewTableOfContents(
            controller: _epubController,
          ),
        ),
        // Show epub document
        body: EpubView(
          controller: _epubController,
          onChapterChanged: (chaptervalue) async {
            // log(chaptervalue!.chapter!.HtmlContent.toString());

            var doc = parse(chaptervalue!.chapter!.HtmlContent.toString());
            final String parsedString =
                parse(doc.body!.text).documentElement!.text;

            // tts.pause();

            // tts.resume();
            spechtext = parsedString;
            // log(parsedString);
            log(spechtext.length.toString());
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // tts.stop();
// flutterTts.
            final s = await flutterTts.getVoices;
            // log(s.toString());
            int end;

            // log(spechtext.substring(0, 4000));
            // spechtext = spechtext.substring(0, 4000);
            // flutterTts.setProgressHandler(
            //     (String text, int startOffset, int endOffset, String word) {
            //   setState(() {
            //     end = endOffset;
            //     log(end.toString());
            //   });
            // });
            // spechtext = "eheheheheheheheheheheheheheheheheh";
            if (spechtext.length > 4000) {
              var count = spechtext.length;
              var max = 4000;
              var loopCount = count ~/ max;
              int x = 0;
              for (var i = 0; i <= loopCount; x++) {
                // log("message-----${spechtext.substring(i * max, (i + 1) * max)}");
                if (i != loopCount) {
                  final String text =
                      spechtext.substring(i * max, (i + 1) * max);
                  log("message=====${text.length}");
                  await flutterTts.speak(text);
                } else {
                  var end = (count - ((i * max)) + (i * max));
                  final String text = spechtext.substring(i * max, end);
                  log("message=====${text.length}");
                  await flutterTts.speak(text);
                }

                flutterTts.setCompletionHandler(() {
                  log("${DateTime.now()}");
                  i++;
                });
              }
              try {
                // final a = await flutterTts.speak(spechtext);

                // flutterTts.setCompletionHandler(() {});
                // await tts.speak(spechtext);
              } catch (e) {
                log(e.toString());
              }
            } else {
              log(spechtext.length.toString());
              try {
                log("${DateTime.now()}");
                final a = await flutterTts.speak(spechtext);

                flutterTts.setCompletionHandler(() {
                  log("${DateTime.now()}");
                });
                // await tts.speak(spechtext);
              } catch (e) {
                log(e.toString());
              }
            }
          },
          child: Icon(Icons.volume_up),
        ),
      );
}
