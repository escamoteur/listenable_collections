import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../lib/src/map_notifier.dart';

void main() {
  group('Tests for Map Notifiers methods', () {
    MapNotifier mapNotifier;
    Map result = {};

    setUp(() {
      mapNotifier = MapNotifier(data: {'one':'1', 'two': '2'});
      result.clear();
    });

    void buildListener() {
      mapNotifier.addListener(() {
        result.addAll(mapNotifier.value);
        print(result);
      });
    }

    test('Listeners get updated if a new key value pair is added', () {
      buildListener();
      mapNotifier['three'] = '3';
      expect(result['three'], '3');
    });

    test('Listeners get updated if a key value pair is removed', () {
      buildListener();
      mapNotifier.remove('two');
      expect(result.length, 1);
    });

    test('Listeners get updated if MapNotifier is cleared', (){
      buildListener();
      mapNotifier.clear();
      expect(result, {});
    });

    test('Listeners get updated after adding multiple entries', () {
      buildListener();
      mapNotifier.addEntries({'three': 3, 'four': 4}.entries);
      expect(result.length, 4);
    });

    test('Listeners get updated when putIfAbsent is called', () {
      buildListener();
      mapNotifier.putIfAbsent('five', () => 5);
      expect(result['five'], 5);
    });
  });
}
