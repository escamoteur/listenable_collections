import 'package:flutter_test/flutter_test.dart';

import '../lib/listenable_collections.dart';

void main() {
  ListNotifier list;

  setUp(() {
    list = ListNotifier(data: [1, 2, 3]);
  });


  test("Elements get swapped correctly", () {
    list.swap(0, 2);

    expect(list.value, [3, 2, 1]);
  });

  test("Listeners get updated if a value gets added", () {
    list.addListener(() {
      expect(list[3], 4);
    });

    list.add(4);
  });

  test("Listeners get notified if an iterable is added", () {
    list.addListener(() {
      expect(list.value, [1,2,3,4,5]);
    });

    list.addAll([4, 5]);
  });

  test("Listeners get notified if the list is cleared", () {
    list.addListener(() {
      expect(list.value, []);
    });
    
    list.clear();
  });

  test("Listeners get notified on fillRange", () {
    list.addListener(() {
      expect(list.value, [1, 1, 1]);
    });

    list.fillRange(0, list.length, 1);
  });

  test("Listeners get notified on value insertion", () {
    list.addListener(() {
      expect(list.value, [1, 1, 3]);
    });

    list.insert(1, 1);
  });

  test("Listeners get notified on iterable insertion", () {
    list.addListener(() {
      expect(list.value, [1, 1, 2, 3]);
    });

    list.insertAll(1, [1, 2]);
  });

  test("Listeners get notified on value removal", () {
    list.addListener(() {
      expect(list.value, [1, 3]);
    });

    final result = list.remove(2);
    expect(result, true);
  });

  test("Listeners get notified on index removal", () {
    list.addListener(() {
      expect(list.value, [1, 3]);
    });

    final itemRemoved = list.removeAt(1);
    expect(itemRemoved, 2);
  });

  test("Listeners get notified on last element removal", () {
    list.addListener(() {
      expect(list.value, [1, 2]);
    });

    final itemRemoved = list.removeLast();
    expect(itemRemoved, 3);
  });

  test("Listeners get notified on range removal", () {
    list.addListener(() {
      expect(list.value, [3]);
    });

    list.removeRange(0, 2);
  });

  test("Listeners get notified on removeWhere", () {
    list.addListener(() {
      expect(list.value, [2, 3]);
    });

    list.removeWhere((element) => element == 1);
  });

  test("Listeners get notified on replaceRange", () {
    list.addListener(() {
      expect(list.value, [3, 3, 3]);
    });

    list.replaceRange(0, 2, [3]);
  });

  test("Listeners get notified on retainWhere", () {
    list.addListener(() {
      expect(list.value, [1]);
    });

    list.retainWhere((element) => element == 1);
  });

  test("Listeners get notified on setAll", () {
    list.addListener(() {
      expect(list.value, [1, 2, 2]);
    });

    list.setAll(2, [2]);
  });

  test("Listeners get notified on setRange", () {
    list.addListener(() {
      expect(list.value, [1, 2, 2]);
    });

    list.setRange(2, list.length, [2]);
  });

  test("Listeners get notified on shuffle", () {
    list.addListener(() {
      expect(list.value != [1,2,3], true);
    });

    list.shuffle();
  });

  test("Listeners get notified on sort", () {
    list.addListener(() {
      expect(list.value, [3,2,1]);
    });

    list.sort((value1, value2) => - (value1.compareTo(value2)));
  });
}
