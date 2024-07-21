import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier, ValueListenable;
import 'package:functional_listener/functional_listener.dart';

/// `ListNotifier` is a List that behaves similarly to `ValueNotifier` when its
/// data changes.
/// It does not compare the elements during bulk operations.
///
/// If [notificationMode] is set to `normal`, `ListNotifier` will compare the new
/// value with the existing value.
///
/// For example, in the case of `list[5]=4`, `ListNotifier` checks if the content
/// at index 5 is equal to 4.
/// It will only call `notifyListeners` if the values are not equal, thus
/// avoiding unnecessary notifications.
///
/// If [notificationMode] is set to `always` which is the default, `ListNotifier`
/// will always notify listeners when the list changes.
/// For example, in the case of `list[5]=4`, `ListNotifier` will always notify
/// listeners, regardless of the values being equal.
///
/// If [notificationMode] is set to `manual`, `ListNotifier` will not notify
/// listeners when the list changes.
/// For example, in the case of `list[5]=4`, `ListNotifier` will not notify
/// listeners.
/// You can manually notify listeners by calling `notifyListeners`.
///
/// `ListNotifier` supports a single level of transactions to allow atomic
/// changes. This means you can make multiple changes to the list and have them
/// all be treated as a single operation, which can be useful for performance
/// reasons.
///
/// There are certain functions that will always notify listeners without
/// comparing the existing value unless [notificationMode] is set to [manual].
/// These functions include:
/// - [setAll] Replaces multiple elements in the list with new values.
/// - [setRange] Replaces a range of elements in the list with new values.
/// - [shuffle] Randomly rearranges the elements of the list.
/// - [sort] Sorts the elements of the list in order.
class ListNotifier<T> extends DelegatingList<T>
    with ChangeNotifier
    implements ValueListenable<List<T>> {
  /// Creates a new listenable List
  /// [data] optional list that should be used as initial value
  /// if  [notifierMode]  is [normal] `ListNotifier` will compare if a value
  /// passed is equal to the existing value.
  /// Like `list[5]=4` if the content at index 4 is equal to 4 and only call
  /// `notifyListeners` if they are not equal. To prevent users from wondering
  /// why their UI doesn't update if they haven't overridden the equality
  /// operator the default is [always].
  /// [customEquality] can be used to set your own criteria for comparing when
  /// choosing [normal] as [notifierMode].
  ListNotifier({
    List<T>? data,
    CustomNotifierMode notificationMode = CustomNotifierMode.always,
    this.customEquality,
  })  : _notificationMode = notificationMode,
        super(data ?? []);

  final CustomNotifierMode _notificationMode;
  final bool Function(T x, T y)? customEquality;

  /// if this is `true` no listener will be notified if the list changes.
  bool _inTransaction = false;
  bool _hasChanged = false;

  /// Starts a transaction that allows to make multiple changes to the List
  /// with only one notification at the end.
  void startTransAction() {
    assert(!_inTransaction, 'Only one transaction at a time in ListNotifier');
    _inTransaction = true;
  }

  /// Ends a transaction and notifies all listeners if [notify] is `true`.
  void endTransAction({bool notify = true}) {
    assert(_inTransaction, 'No active transaction in ListNotifier');
    _inTransaction = false;
    _notify(endOfTransaction: true);
  }

  /// swaps elements on [index1] with [index2] and notifies listeners if the
  /// values are different.
  /// If [customEquality] is set it will be used to compare the values.
  /// If [customEquality] is NOT set the `==` operator will be used.
  void swap(int index1, int index2) {
    final temp1 = this[index1];
    final temp2 = this[index2];
    if (customEquality?.call(temp1, temp2) ?? temp1 == temp2) {
      return;
    }
    // we use super here to avoid triggering the notify function
    super[index1] = temp2;
    super[index2] = temp1;
    _hasChanged = true;
    _notify();
  }

  void _notify({bool endOfTransaction = false}) {
    if (_inTransaction && !endOfTransaction) {
      return;
    }
    switch (_notificationMode) {
      case CustomNotifierMode.normal:
        if (_hasChanged) {
          notifyListeners();
        }
        break;
      case CustomNotifierMode.always:
        notifyListeners();
        break;
      case CustomNotifierMode.manual:
        break;
    }
    _hasChanged = false;
  }

  /// If needed you can notify all listeners manually
  @override
  void notifyListeners() => super.notifyListeners();

  /// returns an unmodifiable view on the lists data.
  @override
  List<T> get value => UnmodifiableListView<T>(this);

  /// from here all functions are equal to `List<T>` with the addition that all
  /// modifying functions will call `notifyListener` if not in a transaction.

  @override
  set length(int value) {
    _hasChanged = length != value;
    super.length = value;
    _notify();
  }

  @override
  T operator [](int index) => super[index];

  @override
  void operator []=(int index, T value) {
    final areEqual =
        customEquality?.call(super[index], value) ?? super[index] == value;
    super[index] = value;

    _hasChanged = !areEqual;
    _notify();
  }

  @override
  void add(T value) {
    super.add(value);
    _hasChanged = true;
    _notify();
  }

  @override
  void addAll(Iterable<T> iterable) {
    super.addAll(iterable);
    _hasChanged = true;
    _notify();
  }

  @override
  void clear() {
    _hasChanged = isNotEmpty;
    super.clear();
    _notify();
  }

  @override
  void fillRange(int start, int end, [T? fillValue]) {
    if (null is! T && fillValue == null) {
      throw ArgumentError.value(fillValue, 'fillValue', 'must not be null');
    }
    if (_notificationMode == CustomNotifierMode.normal) {
      /// we only need to check if the value is equal if we are in normal mode
      if (fillValue == null) {
        _hasChanged = sublist(start, end).any((element) => element != null);
      } else {
        _hasChanged = sublist(start, end).any((element) =>
            customEquality?.call(element, fillValue) ?? element != fillValue);
      }
    }
    super.fillRange(start, end, fillValue);
    _notify();
  }

  @override
  void insert(int index, T element) {
    super.insert(index, element);
    _hasChanged = true;
    _notify();
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    super.insertAll(index, iterable);
    _hasChanged = true;
    _notify();
  }

  @override
  bool remove(Object? value) {
    final wasRemoved = super.remove(value);
    _hasChanged = wasRemoved;
    _notify();
    return wasRemoved;
  }

  @override
  T removeAt(int index) {
    final val = super.removeAt(index);
    _notify();
    _hasChanged = true;
    return val;
  }

  @override
  T removeLast() {
    final val = super.removeLast();
    _notify();
    _hasChanged = true;
    return val;
  }

  @override
  void removeRange(int start, int end) {
    super.removeRange(start, end);
    _hasChanged = true;
    _notify();
  }

  @override
  void removeWhere(bool Function(T) test) {
    super.removeWhere((element) {
      final result = test(element);
      if (result) {
        _hasChanged = true;
      }
      return result;
    });
    _notify();
  }

  @override
  void replaceRange(int start, int end, Iterable<T> iterable) {
    if (_notificationMode == CustomNotifierMode.normal) {
      /// we only need to check if the value is equal if we are in normal mode
      _hasChanged = IterableEquality<T>().equals(sublist(start, end), iterable);
    }
    super.replaceRange(start, end, iterable);
    _notify();
  }

  @override
  void retainWhere(bool Function(T) test) {
    super.retainWhere((element) {
      final result = test(element);
      if (!result) {
        _hasChanged = true;
      }
      return result;
    });
    _notify();
  }

  @override
  void setAll(int index, Iterable<T> iterable) {
    super.setAll(index, iterable);

    /// This function will always notify listeners unless [notificationMode] is
    /// set to [manual]
    _hasChanged = true;
    _notify();
  }

  @override
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount = 0]) {
    super.setRange(start, end, iterable, skipCount);

    /// This function will always notify listeners unless [notificationMode] is
    /// set to [manual]
    _hasChanged = true;
    _notify();
  }

  @override
  void shuffle([math.Random? random]) {
    super.shuffle(random);

    /// This function will always notify listeners unless [notificationMode] is
    /// set to [manual]
    _hasChanged = true;
    _notify();
  }

  @override
  void sort([int Function(T, T)? compare]) {
    super.sort(compare);

    /// This function will always notify listeners unless [notificationMode] is
    /// set to [manual]
    _hasChanged = true;
    _notify();
  }
}
