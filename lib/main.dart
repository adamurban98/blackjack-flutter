import 'dart:html';
import 'dart:math';

import 'package:blackjack/hand.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

void main() {
  GetIt.I.registerLazySingleton(() => Random(0));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'BlackJack'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

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
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Game()],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class HandVisualizer extends StatelessWidget {
  Hand hand;

  HandVisualizer(this.hand);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("sum: ${hand.sum}" +
            (!hand.hard ? '(' + hand.smallSum.toString() + ')' : '') +
            ' hard: ${hand.hard} large: ${hand.largeSum} small:${hand.smallSum} sum:${hand.sum}'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              hand.cards.map((e) => Text('${e.type} ${e.suit} ')).toList(),
        ),
      ],
    );
  }
}

int draw() {
  return GetIt.I.get<Random>().nextInt(14);
}

enum GameState { PLAYER, PLAYER_WON, DEALER_WON, EQUAL }

class Game extends StatefulWidget {
  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: PlayerHand()),
        ChangeNotifierProvider.value(value: DealerHand()),
        ProxyProvider2<PlayerHand, DealerHand, GameState>(
            update: (BuildContext context, ph, dh, _) {
          if (ph.burnt) {
            return GameState.DEALER_WON;
          } else if (!ph.done || !dh.done) {
            return GameState.PLAYER;
          } else if (dh.burnt && !ph.burnt) {
            return GameState.PLAYER_WON;
          } else if (ph.blackjack && dh.blackjack) {
            return GameState.EQUAL;
          } else if (ph.blackjack && !dh.blackjack) {
            return GameState.PLAYER_WON;
          } else if (!ph.blackjack && dh.blackjack) {
            return GameState.DEALER_WON;
          } else if ((21 - ph.sum) < (21 - dh.sum)) {
            return GameState.PLAYER_WON;
          } else if ((21 - ph.sum) == (21 - dh.sum)) {
            return GameState.EQUAL;
          } else {
            return GameState.DEALER_WON;
          }
        })
      ],
      child: Column(children: [
        Text('Dealer hand'),
        Consumer<DealerHand>(
            builder: (context, hand, _) => HandVisualizer(hand)),
        Text('Player hand'),
        Consumer<PlayerHand>(
            builder: (context, hand, _) => HandVisualizer(hand)),
        Consumer<GameState>(builder: (_, gs, __) {
          if (gs == GameState.EQUAL) {
            return Text('REMIZA');
          } else if (gs == GameState.PLAYER_WON) {
            return Text('Player won!');
          } else if (gs == GameState.DEALER_WON) {
            return Text('Dealer won!');
          } else {
            return Container();
          }
        }),
        Consumer3<PlayerHand, DealerHand, GameState>(
          builder: (BuildContext context, ph, dh, gs, _) {
            var buttons = <Widget>[];

            if (gs == GameState.PLAYER) {
              buttons.addAll([
                RaisedButton.icon(
                  onPressed: ph.length == 2
                      ? () async {
                          ph.draw();
                          ph.done = true;
                          await Future.delayed(Duration(milliseconds: 500));
                          dh.play();
                        }
                      : null,
                  icon: Icon(Icons.arrow_upward),
                  label: Text('DOUBLE'),
                ),
                RaisedButton.icon(
                  onPressed: () {
                    ph.draw();
                  },
                  icon: Icon(Icons.play_arrow),
                  label: Text('HIT'),
                ),
                RaisedButton.icon(
                  onPressed: () {
                    ph.done = true;
                    dh.play();
                  },
                  icon: Icon(Icons.stop),
                  label: Text('STAND'),
                ),
              ]);
            } else {
              print('there');
              buttons.add(RaisedButton.icon(
                onPressed: () => setState(() {}),
                icon: Icon(Icons.replay),
                label: Text('Restart'),
              ));
            }
            print(buttons);
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: buttons
                  .map((e) => SizedBox(
                        width: 200.0,
                        child: e,
                      ))
                  .toList(),
            );
          },
        ),
      ]),
    );
  }
}
