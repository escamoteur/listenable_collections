import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier, ValueListenable;
import 'package:listenable_collections/src/manual_notifier.dart';

/// A List that behaves like `ValueNotifier` if its data changes.
/// it does not compare the elements on bulk operations
/// If you set [dontNotifyIfEqual] to `true` it will compare if a value passed value
///  passed is equal to the existing value.
/// like `list[5]=4` if the content at index 4 is qual to 4 and only call
/// `notifyListeners` if they are not equal.
/// To allow atomic changes `ListNotifier` supports a single level of transactions
class ListNotifier<T> extends DelegatingList<T>
    implements ValueListenable<List<T>> {
  ///
  /// Creates a new listenable List
  /// [data] optional list that should be used as initial value
  /// if  [dontNotifyIfEqual]  is `true` `ListNotifier` will compare if a value
  ///  passed is equal to the existing value.
  /// like `list[5]=4` if the content at index 4 is qual to 4 and only call
  /// `notifyListeners` if they are not equal. To prevent users from wondering
  /// why their UI doesn't update if they haven't overritten the equality operator
  /// the default is `false`.
  /// Alternatively you can pass in a [customEquality] function that is then used instead
  /// of `==`
  ListNotifier(
      {List<T> data, bool dontNotifyIfEqual = false, this.customEquality})
      : _dontNotifyIfEqual = dontNotifyIfEqual,
        super(data ?? []);

  final bool _dontNotifyIfEqual;
  final bool Function(T x, T y) customEquality;

  /// as we can't inherit from two classes whe have to implement
  /// the `Listenable` interface. To not do that manually
  /// we forward all needed functions to `_notifier`
  final _notifier = ManualNotifier();

  /// if this is `true` no listener will be notified if the list changes.
  bool _inTransaction = false;

  /// Starts a transaction that allows to make multiple changes to the List
  /// with only one notification at the end.
  void startTransAction() {
    assert(!_inTransaction, 'Only one transaction at a time in ListNotifier');
    _inTransaction = true;
  }

  /// Ends a transaction
  void endTransAction() {
    assert(_inTransaction, 'No active transaction in ListNotifier');
    _inTransaction = false;
    _notify();
  }

  /// swaps elemente on [index1] with [index2]
  void swap(int index1, int index2) {
    startTransAction();
    final temp = this[index1];
    this[index1] = this[index2];
    this[index2] = temp;
    endTransAction();
  }

  void _notify() {
    if (!_inTransaction) {
      _notifier.notifyListeners();
    }
  }

  /// If needed you can notifiy all listeners manually
  void notifyListeners() => _notifier.notifyListeners();

  /// returns an unmodifiable view on the lists data.
  @override
  List<T> get value => UnmodifiableListView<T>(this);

  /// needed for the `ValueListenable` interface
  @override
  void addListener(void Function() listener) {
    _notifier.addListener(listener);
  }

  /// needed for the `ValueListenable` interface
  @override
  void removeListener(void Function() listener) {
    _notifier.removeListener(listener);
  }

  /// from here all functions are equal to `List<T>` with the addition that all
  /// modifying functions will call `notifyListener` if not in a transaction.

  @override
  set length(int value) {
    super.length = value;
    _notify();
  }

  @override
  T operator [](int index) => super[index];

  @override
  void operator []=(int index, T value) {
    final areEqual = customEquality != null
        ? customEquality(super[index], value)
        : super[index] == value;
    super[index] = value;

    if ((!_dontNotifyIfEqual && customEquality == null) || !areEqual) {
      _notify();
    }
  }

  @override
  void add(T value) {
    super.add(value);
    _notify();
  }

  @override
  void addAll(Iterable<T> iterable) {
    super.addAll(iterable);
    _notify();
  }

  @override
  void clear() {
    super.clear();
    _notify();
  }

  @override
  void fillRange(int start, int end, [T fillValue]) {
    super.fillRange(start, end, fillValue);
    _notify();
  }

  @override
  void insert(int index, T element) {
    super.insert(index, element);
    _notify();
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    super.insertAll(index, iterable);
    _notify();
  }

  @override
  bool remove(Object value) {
    final val = super.remove(value);
    _notify();
    return val;
  }

  @override
  T removeAt(int index) {
    final val = super.removeAt(index);
    _notify();
    return val;
  }

  @override
  T removeLast() {
    final val = super.removeLast();
    _notify();
    return val;
  }

  @override
  void removeRange(int start, int end) {
    super.removeRange(start, end);
    _notify();
  }

  @override
  void removeWhere(bool Function(T) test) {
    super.removeWhere(test);
    _notify();
  }

  @override
  void replaceRange(int start, int end, Iterable<T> iterable) {
    super.replaceRange(start, end, iterable);
    _notify();
  }

  @override
  void retainWhere(bool Function(T) test) {
    super.retainWhere(test);
    _notify();
  }

  @override
  void setAll(int index, Iterable<T> iterable) {
    super.setAll(index, iterable);
    _notify();
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    super.setRange(start, end, iterable, skipCount);
    _notify();
  }

  @override
  void shuffle([math.Random random]) {
    super.shuffle(random);
    _notify();
  }

  @override
  void sort([int Function(T, T) compare]) {
    super.sort(compare);
    _notify();
  }
}
