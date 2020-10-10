import 'package:flutter_test/flutter_test.dart';
import 'package:listenable_collections/listenable_collections.dart';

void main() {
  ListNotifier list;

  setUp(() {
    list = ListNotifier(data: [1, 2, 3]);
  });
  test("Listeners get notified on swap", () async {
    dynamic result;
    list.addListener(() {
      result = list.value;
    });

    list.swap(0, 2);

    expect(result, [3, 2, 1]);
  });
}
