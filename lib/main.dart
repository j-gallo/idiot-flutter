import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'dart:collection';
import 'package:playing_cards/playing_cards.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<PlayingCard> _deck = standardFiftyTwoCardDeck();
  List<PlayingCard> _hand = [];
  List<int> _selectedCards = [];
  bool _canUndo = false;

  @override
  initState() {
    _deck.shuffle();
  }

  PlayingCardViewStyle myCardStyles = PlayingCardViewStyle(
    suitStyles: {
      Suit.spades: SuitStyle(
        builder: (context) => const FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            "♠",
            style: TextStyle(fontSize: 500),
          ),
        ),
        style: TextStyle(color: Colors.grey[800]),
      ),
      Suit.hearts: SuitStyle(
        builder: (context) => const FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            "♥",
            style: TextStyle(fontSize: 500, color: Colors.red),
          ),
        ),
        style: const TextStyle(color: Colors.red),
      ),
      Suit.diamonds: SuitStyle(
        builder: (context) => const FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            "♦",
            style: TextStyle(fontSize: 500, color: Colors.red),
          ),
        ),
        style: const TextStyle(color: Colors.red),
      ),
      Suit.clubs: SuitStyle(
        builder: (context) => const FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            "♣",
            style: TextStyle(fontSize: 500),
          ),
        ),
        style: TextStyle(color: Colors.grey[800]),
      ),
      Suit.joker: SuitStyle(builder: (context) => Container()),
    },
  );

  void _toggleSelectedCard(int index) {
    setState(() {
      if (_selectedCards.contains(index)) {
        if (_selectedCards.length == 2) {
          _selectedCards = [];
        } else {
          _selectedCards.remove(index);
        }
      } else {
        if (_selectedCards.length == 2) {
          _selectedCards = [];
        }
        _selectedCards.add(index);
        if (_selectedCards.length == 2) {
          if (_selectedCards.contains(1) && _selectedCards.contains(2)) {
            if (_hand[_hand.length-1].suit == _hand[_hand.length-4].suit) {
              for (int i=0; i<2; i++) {
                _hand.removeAt(_hand.length-2);
              }
              _selectedCards = [];
              _canUndo = false;
            }
          }
          if (_selectedCards.contains(0) && _selectedCards.contains(3)) {
            if (_hand[_hand.length-1].value == _hand[_hand.length-4].value || true) {
              for (int i=0; i<4; i++) {
                _hand.removeLast();
              }
              _selectedCards = [];
              _canUndo = false;
            }
          }
        }
      };
    });
  }

  List<Widget> currentHandDisplay() {
    List<Widget> fan = [];
    int length = _hand.length - 1;
    for (int j = 0; j < 4; j++) {
      if (j >= _hand.length) {
        break;
      }
      Color backgroundColor = Colors.white;
      if (_selectedCards.contains(j)) {
        backgroundColor = Colors.black;
      }
      if (j < 3 || _hand.length <= 4) {
        fan.add(GestureDetector(
            onTap: () { _toggleSelectedCard(j); },
            child: PlayingCardView(card: _hand[length-j], style: PlayingCardViewStyle(surfaceTintColor: backgroundColor)),
        ));
      } else {
        fan.add(
          Container(
            width: 153,
            child: FlatCardFan(
              children: [
                PlayingCardView(card: _hand[length-j-1]),
                GestureDetector(
                  onTap: () { _toggleSelectedCard(j); },
                  child: PlayingCardView(card: _hand[length-j], style: PlayingCardViewStyle(surfaceTintColor: backgroundColor)),
                ),
              ],
            ),
          ),
        );
      }
    };
    return fan.reversed.toList();
  }

  void _shuffleDeck() {
    setState(() {
      _deck.shuffle();
    });
  }

  void _drawCard() {
    setState(() {
      if (_deck.length > 0) {
        _selectedCards = [];
        _hand.add(_deck.removeAt(_deck.length-1));
        _canUndo = true;
      }
    });
  }

  void _undo() {
    if (_canUndo) {
      setState(() {
        _deck.add(_hand.removeLast());
        _canUndo = false;
      });
    }
  }

  void _restart() {
    setState(() {
      _deck = standardFiftyTwoCardDeck();
      _deck.shuffle();
      _hand = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: _drawCard,
            child: Container(
              height: 200,
              child: Builder(
                builder: (BuildContext context) {
                  if (_deck.length > 0) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: PlayingCardView(card: PlayingCard(Suit.hearts, CardValue.ace), showBack: true),
                    );
                  }
                  return Align(
                    alignment: Alignment.topLeft,
                    child: AspectRatio(
                      aspectRatio: playingCardAspectRatio,
                      child: Card(
                        child: Text(""),
                      ),
                    ),
                  );
                }
              ),
            ),
          ),
          Container(
            height: 200,
            width: 300,
            child: FlatCardFan(children: currentHandDisplay()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 25.0, bottom: 5.0),
                child: Icon(Icons.question_mark),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 25.0, bottom: 5.0),
                child: Row(
                  children: [
                    Icon(Icons.menu),
                    Text(_deck.length.toString()),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 25.0, bottom: 5.0),
                child: Row(
                  children: [
                    Icon(Icons.front_hand),
                    Text(_hand.length.toString()),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 25.0, bottom: 5.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _undo,
                      child: Builder(
                        builder: (BuildContext context) {
                          if (_canUndo) {
                            return Icon(
                              Icons.arrow_back_ios,
                            );
                          }
                          return Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black26,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _restart,
            child: Icon(
              Icons.restart_alt,
            ),
          ),
        ],
      ),
    );
  }
}
