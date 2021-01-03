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
      expect(mapNotifier.length, 1);
    });

    test('Listeners get updated if MapNotifier is cleared', (){
      buildListener();
      mapNotifier.clear();
      expect(result, {});
    });
  });
}
