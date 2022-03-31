import 'package:flutter_test/flutter_test.dart';
import '../lib/src/map_notifier.dart';

void main() {
  group('Tests for MapNotifier methods', () {
    late MapNotifier<String, int> mapNotifier;
    Map<String, int> result = {};
    final newValues = {'zero': 0, 'one': 1, 'two': 2, 'three': 3};

    setUp(() {
      mapNotifier = MapNotifier(data: {'zero': 0});
      mapNotifier.addListener(() {
        result = {...mapNotifier};
      });
    });

    tearDown(() {
      mapNotifier.dispose();
    });

    test('Notifies when a new value is added', () {
      mapNotifier['one'] = 1;
      expect(result['zero'], 0);
      expect(result['one'], 1);
    });

    test('Listener is notified on add all', () {
      mapNotifier.addAll(newValues);
      expect(result, newValues);
    });

    test('Listener is notified on add entries', () {
      mapNotifier.addEntries(newValues.entries);
      expect(result, newValues);
    });

    test('Listener is notified on clear', () {
      mapNotifier.addAll(newValues);
      expect(result, newValues);
      mapNotifier.clear();
      expect(result.isEmpty, isTrue);
    });

    test('Listener is notified on putIfAbsent', () {
      for (final entry in newValues.entries) {
        mapNotifier.putIfAbsent(entry.key, () => entry.value);
      }
      expect(result, newValues);
    });

    test('Listener is notified when a key is removed', () {
      final key = 'one';
      mapNotifier[key] = 1;
      expect(result[key], 1);
      mapNotifier.remove(key);
      expect(result[key], isNull);
    });

    test('Listener is notified when removeWhere is called', () {
      mapNotifier.addAll(newValues);
      mapNotifier.removeWhere((_, v) => v > 0);
      expect(result, {'zero': 0});
    });

    test('Listener is notified when update is called', () {
      mapNotifier.update('zero', (_) => 10);
      expect(result, {'zero': 10});
    });

    test('Listener is notified when updateAll is called', () {
      mapNotifier.addAll(newValues);
      mapNotifier.updateAll((p0, p1) => 1);
      expect(result, {'zero': 1, 'one': 1, 'two': 1, 'three': 1});
    });
  });

  group('Tests for notifyIfEqual', () {
    late MapNotifier<String, int> mapNotifier;
    late int listenerCallCount;
    final newValues = {'zero': 0, 'one': 1};

    group('when notifyIfEqual is false', () {
      setUp(() {
        mapNotifier = MapNotifier(notifyIfEqual: false);
        listenerCallCount = 0;
        mapNotifier.addListener(() {
          listenerCallCount++;
        });
      });

      tearDown(() {
        mapNotifier.dispose();
      });

      test('Listener is not notified if value is equal', () {
        mapNotifier['zero'] = 0;
        mapNotifier['zero'] = 0;
        expect(listenerCallCount, 1);
      });

      test('Listener is not notified if addAll results in equal value', () {
        mapNotifier.addAll(newValues);
        mapNotifier.addAll(newValues);

        expect(listenerCallCount, 1);
      });

      test('Listener is not notified if addEntries results in equal value', () {
        mapNotifier.addEntries(newValues.entries);
        mapNotifier.addEntries(newValues.entries);
        expect(listenerCallCount, 1);
      });

      test('Calling clear on an empty map does not notify listeners', () {
        mapNotifier.clear();
        expect(listenerCallCount, 0);
      });

      test('Listener is not notified if the value already existed', () {
        mapNotifier.putIfAbsent('zero', () => 0);
        mapNotifier.putIfAbsent('zero', () => 0);
        mapNotifier.putIfAbsent('zero', () => 1);

        expect(listenerCallCount, 1);
      });

      test('Listener is not notified if no value is removed', () {
        mapNotifier.addAll(newValues);
        expect(listenerCallCount, 1);
        mapNotifier.remove('zero');
        expect(listenerCallCount, 2);
        mapNotifier.remove('zero');
        expect(listenerCallCount, 2);
      });

      test(
        'Listener is not notified if removeWhere does not remove any values',
        () {
          mapNotifier.addAll(newValues);
          expect(listenerCallCount, 1);
          mapNotifier.removeWhere((key, _) => key == 'ten');
          expect(listenerCallCount, 1);
        },
      );

      test(
          'Listener is not notified when update is called and updates to the '
          'already existing value', () {
        mapNotifier.update('zero', (_) => 10, ifAbsent: () => 10);
        expect(listenerCallCount, 1);
        mapNotifier.update('zero', (_) => 10, ifAbsent: () => 10);
        expect(listenerCallCount, 1);
      });

      test(
          'Listener is not notified when updateAll is called and updates to '
          'already existing value', () {
        mapNotifier.addAll(newValues);
        expect(listenerCallCount, 1);
        mapNotifier.updateAll((p0, p1) => 1);
        expect(listenerCallCount, 2);
        mapNotifier.updateAll((p0, p1) => 1);
        expect(listenerCallCount, 2);
      });
    });

    group('when notifyIfEqual is true', () {
      setUp(() {
        mapNotifier = MapNotifier(notifyIfEqual: true);
        listenerCallCount = 0;
        mapNotifier.addListener(() {
          listenerCallCount++;
        });
      });

      tearDown(() {
        mapNotifier.dispose();
      });

      test(
        'Listener is notified if added value is equal',
        () {
          mapNotifier['zero'] = 0;
          mapNotifier['zero'] = 0;
          expect(listenerCallCount, 2);
        },
      );

      test('Listener is notified on addAll values already exist', () {
        final newValues = {'zero': 0, 'one': 1};
        mapNotifier.addAll(newValues);
        mapNotifier.addAll(newValues);

        expect(listenerCallCount, 2);
      });

      test('Listener is notified if addEntries results in equal value', () {
        mapNotifier.addEntries(newValues.entries);
        mapNotifier.addEntries(newValues.entries);
        expect(listenerCallCount, 2);
      });

      test('Calling clear on an empty map notifies listeners', () {
        mapNotifier.clear();
        expect(listenerCallCount, 1);
      });

      test('Listener is notified on putIfAbsent', () {
        mapNotifier.putIfAbsent('zero', () => 0);
        expect(listenerCallCount, 1);
        mapNotifier.putIfAbsent('zero', () => 0);
        expect(listenerCallCount, 2);
        mapNotifier.putIfAbsent('zero', () => 1);
        expect(listenerCallCount, 3);
      });

      test('Listener is notified if no value is removed', () {
        mapNotifier.addAll(newValues);
        expect(listenerCallCount, 1);
        mapNotifier.remove('zero');
        expect(listenerCallCount, 2);
        mapNotifier.remove('zero');
        expect(listenerCallCount, 3);
      });

      test(
        'Listener is notified if removeWhere does not remove any values',
        () {
          mapNotifier.addAll(newValues);
          expect(listenerCallCount, 1);
          mapNotifier.removeWhere((key, _) => key == 'ten');
          expect(listenerCallCount, 2);
        },
      );

      test('Listener is notified when update is called', () {
        mapNotifier.update('zero', (_) => 10, ifAbsent: () => 10);
        expect(listenerCallCount, 1);
        mapNotifier.update('zero', (_) => 10, ifAbsent: () => 10);
        expect(listenerCallCount, 2);
      });

      test(
          'Listener is notified when updateAll is called and updates to '
          'already existing value', () {
        mapNotifier.addAll(newValues);
        expect(listenerCallCount, 1);
        mapNotifier.updateAll((p0, p1) => 1);
        expect(listenerCallCount, 2);
        mapNotifier.updateAll((p0, p1) => 1);
        expect(listenerCallCount, 3);
      });
    });
  });

  group('Custom equality tests', () {
    final customEquality = (int? x, int? y) => (x ?? 0) > 3 || (y ?? 0) > 3;

    group('When notifyIfEqual is false', () {
      late MapNotifier<String, int> mapNotifier;
      late Map<String, int> result;

      setUp(() {
        mapNotifier = MapNotifier(customEquality: customEquality);
        result = {};
        mapNotifier.addListener(() {
          result = {...mapNotifier};
        });
      });

      tearDown(() {
        mapNotifier.dispose();
      });

      test(
        'Listener is not notified if customEquality returns true (are equal)',
        () {
          mapNotifier['five'] = 5;
          expect(result, isEmpty);
        },
      );

      test(
        'Listener is notified if customEquality returns false (are not equal)',
        () {
          mapNotifier['one'] = 1;
          expect(result['one'], 1);
        },
      );
    });

    group('When notifyIfEqual is true', () {
      late MapNotifier<String, int> mapNotifier;
      late Map<String, int> result;

      setUp(() {
        mapNotifier = MapNotifier(
          customEquality: customEquality,
          notifyIfEqual: true,
        );
        result = {};
        mapNotifier.addListener(() {
          result = {...mapNotifier};
        });
      });

      tearDown(() {
        mapNotifier.dispose();
      });

      test(
        'Listener is notified if customEquality returns true (are equal)',
        () {
          mapNotifier['five'] = 5;
          expect(result['five'], 5);
        },
      );

      test(
        'Listener is notified if customEquality returns false (are not equal)',
        () {
          mapNotifier['one'] = 1;
          expect(result['one'], 1);
        },
      );
    });
  });
}
