import 'package:flutter_test/flutter_test.dart';

import '../lib/src/list_notifier.dart';

void main() {
  group("Tests for the ListNotifier's methods", () {
    ListNotifier list;
    List result = [];

    setUp(() {
      list = ListNotifier(data: [1, 2, 3]);
      result.clear();
    });

    void buildListener() {
      list.addListener(() {
        result.addAll(list.value);
      });
    }

    test("Elements get swapped correctly", () {
      buildListener();

      list.swap(0, 2);

      expect(result, [3, 2, 1]);
    });

    test("Listeners get updated if a value gets added", () {
      buildListener();

      list.add(4);

      expect(result[3], 4);
    });

    test("Listeners get notified if an iterable is added", () {
      buildListener();

      list.addAll([4, 5]);

      expect(result, [1, 2, 3, 4, 5]);
    });

    test("Listeners get notified if the list is cleared", () {
      buildListener();

      list.clear();

      expect(result, []);
    });

    test("Listeners get notified on fillRange", () {
      buildListener();

      list.fillRange(0, list.length, 1);

      expect(result, [1, 1, 1]);
    });

    test("Listeners get notified on value insertion", () {
      buildListener();

      list.insert(1, 1);

      expect(result, [1, 1, 2, 3]);
    });

    test("Listeners get notified on iterable insertion", () {
      buildListener();

      list.insertAll(1, [1, 2]);

      expect(result, [1, 1, 2, 2, 3]);
    });

    test("Listeners get notified on value removal", () {
      buildListener();

      final itemIsRemoved = list.remove(2);

      expect(result, [1, 3]);
      expect(itemIsRemoved, true);
    });

    test("Listeners get notified on index removal", () {
      buildListener();

      final removedItem = list.removeAt(1);

      expect(result, [1, 3]);
      expect(removedItem, 2);
    });

    test("Listeners get notified on last element removal", () {
      buildListener();

      final itemRemoved = list.removeLast();

      expect(result, [1, 2]);
      expect(itemRemoved, 3);
    });

    test("Listeners get notified on range removal", () {
      buildListener();

      list.removeRange(0, 2);

      expect(result, [3]);
    });

    test("Listeners get notified on removeWhere", () {
      buildListener();

      list.removeWhere((element) => element == 1);

      expect(list.value, [2, 3]);
    });

    test("Listeners get notified on replaceRange", () {
      buildListener();

      list.replaceRange(0, 2, [3, 3]);

      expect(result, [3, 3, 3]);
    });

    test("Listeners get notified on retainWhere", () {
      buildListener();

      list.retainWhere((element) => element == 1);

      expect(list.value, [1]);
    });

    test("Listeners get notified on setAll", () {
      buildListener();

      list.setAll(2, [2]);

      expect(list.value, [1, 2, 2]);
    });

    test("Listeners get notified on setRange", () {
      buildListener();

      list.setRange(2, list.length, [2]);

      expect(result, [1, 2, 2]);
    });

    test("Listeners get notified on shuffle", () {
      buildListener();

      list.shuffle();

      expect(result != [1, 2, 3], true);
    });

    test("Listeners get notified on sort", () {
      buildListener();

      list.sort((value1, value2) => -(value1.compareTo(value2)));

      expect(result, [3, 2, 1]);
    });
  });

  group("Tests for the ListNotifier's equality", () {
    List result;

    setUp(() {
      result = null;
    });

    test("The listener isn't notified if the value is equal", () {
      final ListNotifier list = ListNotifier(
        data: [1, 2, 3],
        notifyIfEqual: false,
      );

      list.addListener(() {
        result = [...list.value];
      });

      list[0] = 1;

      expect(result, null);
    });

    test("customEuqality works correctly", () {
      final ListNotifier list = ListNotifier(
        data: [1, 2, 3],
        notifyIfEqual: false,
        customEquality: (index, value) => value >= 3,
      );

      list.addListener(() {
        result = [...list.value];
      });

      list[2] = 3;

      expect(result, null);

      list[0] = 1;

      // if customEquality wasn't implemented this would not call
      // the listeners, it doea because 1 < 3, as defined in
      // custom equality.
      expect(result, [1, 2, 3]);
    });
  });
}
