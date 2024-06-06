import 'package:flutter_test/flutter_test.dart';
import 'package:functional_listener/functional_listener.dart';

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
      /// Define new value to mapNotifier
      mapNotifier['one'] = 1;

      /// Get the value of mapNotifier key 'zero'
      expect(result['zero'], 0);

      /// Get the value of mapNotifier key 'one'
      expect(result['one'], 1);
    });

    test('Listener is notified on add all', () {
      /// The initial value of mapNotifier is {'zero': 0}
      mapNotifier.addAll(newValues);

      /// When we add newValues to mapNotifier, the same keys will be replaced with new values
      /// and the new keys will be added to mapNotifier
      expect(result, newValues);
    });

    test('Listener is notified on add entries', () {
      mapNotifier.addEntries(newValues.entries);
      expect(result, newValues);
    });

    test('Listener is notified on clear', () {
      mapNotifier.addAll(newValues);
      expect(result, newValues);

      /// Delete all the keys and values in mapNotifier
      mapNotifier.clear();

      /// Check if mapNotifier is empty
      expect(result.isEmpty, isTrue);
    });

    test('Listener is notified on putIfAbsent', () {
      for (final entry in newValues.entries)

        /// If the key does not exist in mapNotifier, add the key and value to mapNotifier
        /// If the key already exists in mapNotifier, do nothing
        mapNotifier.putIfAbsent(entry.key, () => entry.value);

      expect(result, newValues);
    });

    test('Listener is notified when a key is removed', () {
      final key = 'one';
      mapNotifier[key] = 1;
      expect(result[key], 1);

      /// Remove the key and value from mapNotifier
      mapNotifier.remove(key);
      expect(result[key], isNull);
    });

    test('Listener is notified when removeWhere is called', () {
      mapNotifier.addAll(newValues);

      /// Remove all the keys and values in mapNotifier where the condition is true
      mapNotifier.removeWhere((_, v) => v > 0);
      expect(result, {'zero': 0});
    });

    test('Listener is notified when update is called', () {
      mapNotifier.update('zero', (_) => 10);

      /// Update the value of key 'zero' to 10
      expect(result, {'zero': 10});
    });

    test('Listener is notified when updateAll is called', () {
      mapNotifier.addAll(newValues);

      /// Update all the values in mapNotifier to 1
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
        mapNotifier = MapNotifier(
          // notifyIfEqual: false,
          notificationMode: CustomNotifierMode.normal,
        );
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

        /// The listener is called only once because the value is equal
        expect(listenerCallCount, 1);
      });

      test('Listener is not notified if addAll results in equal value', () {
        mapNotifier.addAll(newValues);
        mapNotifier.addAll(newValues);

        /// The listener is called only once because the value is equal
        expect(listenerCallCount, 1);
      });

      test('Listener is not notified if addEntries results in equal value', () {
        mapNotifier.addEntries(newValues.entries);
        mapNotifier.addEntries(newValues.entries);

        /// The listener is called only once because the value is equal
        expect(listenerCallCount, 1);
      });

      test('Calling clear on an empty map does not notify listeners', () {
        mapNotifier.clear();

        /// The listener is not called because the map is empty
        expect(listenerCallCount, 0);
      });

      test('Listener is not notified if the value already existed', () {
        /// The key exist in mapNotifier, so the value is not added
        mapNotifier.putIfAbsent('zero', () => 0);
        mapNotifier.putIfAbsent('zero', () => 0);
        mapNotifier.putIfAbsent('zero', () => 1);

        expect(listenerCallCount, 1);
      });

      test('Listener is not notified if no value is removed', () {
        mapNotifier.addAll(newValues);

        /// first call when addAll is called
        expect(listenerCallCount, 1);
        mapNotifier.remove('zero');

        /// second call when remove is called
        expect(listenerCallCount, 2);
        mapNotifier.remove('zero');

        /// The count is still 2 because the value is already removed
        expect(listenerCallCount, 2);
      });

      test(
        'Listener is not notified if removeWhere does not remove any values',
        () {
          mapNotifier.addAll(newValues);

          /// first call when addAll is called
          expect(listenerCallCount, 1);
          mapNotifier.removeWhere((key, _) => key == 'ten');

          /// The count is still 1 because the value is not excited in mapNotifier
          expect(listenerCallCount, 1);
        },
      );

      test(
          'Listener is not notified when update is called and updates to the '
          'already existing value', () {
        /// The key exist in mapNotifier, so the value is not added
        mapNotifier.update('zero', (_) => 10, ifAbsent: () => 10);

        /// The listener isn't called because the value is already updated
        expect(listenerCallCount, 0);
        mapNotifier.update('zero', (_) => 10, ifAbsent: () => 10);
        expect(listenerCallCount, 0);
      });

      test(
          'Listener is not notified when updateAll is called and updates to '
          'already existing value', () {
        mapNotifier.addAll(newValues);

        /// The listener is called only once because the mapNotifier is updated
        expect(listenerCallCount, 1);
        mapNotifier.updateAll((p0, p1) => 1);

        /// The listener is not called because the values of mapNotifier are updated
        expect(listenerCallCount, 1);
        mapNotifier.updateAll((p0, p1) => 1);

        /// The listener is not called because the values of mapNotifier are already updated
        expect(listenerCallCount, 1);
      });
    });

    group('when notifyIfEqual is true', () {
      setUp(() {
        mapNotifier = MapNotifier(
            // notifyIfEqual: true,
            notificationMode: CustomNotifierMode.always);
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

          /// In every call, the listener is notified because the notificationMode is CustomNotifierMode.always
          expect(listenerCallCount, 2);
        },
      );

      test('Listener is notified on addAll values already exist', () {
        final newValues = {'zero': 0, 'one': 1};
        mapNotifier.addAll(newValues);
        mapNotifier.addAll(newValues);

        /// In every call, the listener is notified because the notificationMode is CustomNotifierMode.always
        expect(listenerCallCount, 2);
      });

      test('Listener is notified if addEntries results in equal value', () {
        mapNotifier.addEntries(newValues.entries);
        mapNotifier.addEntries(newValues.entries);

        /// In every call, the listener is notified because the notificationMode is CustomNotifierMode.always
        expect(listenerCallCount, 2);
      });

      test('Calling clear on an empty map notifies listeners', () {
        mapNotifier.clear();

        /// In every call, the listener is notified because the notificationMode is CustomNotifierMode.always
        expect(listenerCallCount, 1);
      });

      test('Listener is notified on putIfAbsent', () {
        mapNotifier.putIfAbsent('zero', () => 0);

        /// In every call, the listener is notified because the notificationMode is CustomNotifierMode.always
        expect(listenerCallCount, 1);
        mapNotifier.putIfAbsent('zero', () => 0);

        /// The listener is not notified because the value is already added
        expect(listenerCallCount, 1);
        mapNotifier.putIfAbsent('zero', () => 1);

        /// In every call, the listener is notified because the notificationMode is CustomNotifierMode.always
        expect(listenerCallCount, 1);
      });

      test('Listener is notified if no value is removed', () {
        mapNotifier.addAll(newValues);

        /// In every call, the listener is notified because the notificationMode is CustomNotifierMode.always
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

          /// In every call, the listener is notified because the notificationMode is CustomNotifierMode.always
          expect(listenerCallCount, 1);
          mapNotifier.removeWhere((key, _) => key == 'ten');

          /// In every call, the listener is notified because the notificationMode is CustomNotifierMode.always
          expect(listenerCallCount, 2);
        },
      );

      test('Listener is notified when update is called', () {
        mapNotifier.update('zero', (_) => 10, ifAbsent: () => 10);
        expect(listenerCallCount, 0);
        mapNotifier.update('zero', (_) => 10, ifAbsent: () => 10);
        expect(listenerCallCount, 1);
      });

      test(
          'Listener is notified when updateAll is called and updates to '
          'already existing value', () {
        mapNotifier.addAll(newValues);

        /// The first count is 1 because the mapNotifier is updated when addAll is called
        expect(listenerCallCount, 1);
        mapNotifier.updateAll((p0, p1) => 1);

        /// The second count is 2 because the mapNotifier is updated when updateAll is called
        expect(listenerCallCount, 2);
        mapNotifier.updateAll((p0, p1) => 1);

        /// The second count is 2 because the mapNotifier is updated when updateAll is called although the values are already updated
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
          expect(result, {'five': 5});
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
          // notifyIfEqual: true,
          notificationMode: CustomNotifierMode.always,
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
