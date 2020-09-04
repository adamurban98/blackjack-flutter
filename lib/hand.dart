import 'dart:math';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:get_it/get_it.dart';

enum Suit {
  DIAMOND,
  CLUB,
  HEART,
  SPADE,
}

class Card {
  Suit suit;
  int _type;
  String get type {
    if (_type == 13) {
      return "K";
    } else if (_type == 12) {
      return "Q";
    } else if (_type == 11) {
      return "J";
    } else if (_type == 1) {
      return "A";
    }
    return _type.toString();
  }

  int get value {
    if (_type == 1) {
      return 11;
    } else if (_type > 10) {
      return 10;
    } else {
      return _type;
    }
  }

  Card.random() {
    _type = GetIt.I.get<Random>().nextInt(13) + 1;
    suit = Suit.values[GetIt.I.get<Random>().nextInt(4)];
  }

  bool get isAce => _type == 1;
}

class Hand extends ChangeNotifier {
  List<Card> _cards = [];
  bool _done = false;

  List<Card> get cards => _cards;
  bool get done => _done || burnt;
  set done(value) {
    _done = value;
    notifyListeners();
  }

  bool get blackjack =>
      _cards.contains(11) && _cards.contains(10) && _cards.length == 2;

  int get length => _cards.length;

  bool get hard => sum == smallSum;

  int get sum => (largeSum <= 21) ? largeSum : smallSum;

  int get largeSum =>
      _cards.fold(0, (previousValue, card) => previousValue + card.value);

  int get smallSum => (containsAce) ? largeSum - 10 : largeSum;

  bool get containsAce => _cards.any((element) => element.isAce);

  bool get burnt => sum > 21;

  void add(Card card) {
    _cards.add(card);
    notifyListeners();
  }

  void draw() {
    add(Card.random());
  }

  int compareTo(Hand other) {
    // -1 other won
    // 0 equal
    // 1 you won
    // if (other.blackjack) {}
  }
}

class DealerHand extends Hand {
  DealerHand() {
    draw();
  }

  void play() async {
    while (sum < 17) {
      draw();
      await Future.delayed(Duration(milliseconds: 500));
    }
    done = true;
  }
}

class PlayerHand extends Hand {
  PlayerHand() {
    draw();
    draw();
  }
}
