import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

/// A Map that behaves like `ValueNotifier` if its data changes.
/// By default, [notifyIfEqual] is set to false. In this state, listeners
/// are not notified if a value is passed that is equal to the value
/// currently stored in that key. If set to true, listeners would be notified
/// of any values that are passed, even when equal.
/// For example, if notify if equal is false, the code below will not notify
/// listeners:
/// '''
///   final mapNotifier = MapNotifier(data: {'one': 1});
///   mapNotifier['one'] = 1
/// '''
class MapNotifier<K, V> extends DelegatingMap<K, V>
    with ChangeNotifier
    implements ValueListenable<Map<K, V>> {
  ///
  /// Creates a Map Notifier. The optional field [data] can be used to specify
  /// an initial value. It defaults to an empty Map. By default, [notifyIfEqual]
  /// is set to false. In this state, listeners
  /// are not notified if a value is passed that is equal to the value
  /// currently stored in that key. If set to true, listeners would be notified
  /// of any values that are passed, even when equal.
  /// For example, if notify if equal is false, the code below will not notify
  /// listeners:
  /// '''
  ///   final mapNotifier = MapNotifier(data: {'one': 1});
  ///   mapNotifier['one'] = 1
  /// '''
  MapNotifier({
    Map<K, V>? data,
    bool notifyIfEqual = false,
    this.customEquality,
  })  : _notifyIfEqual = notifyIfEqual,
        super(data ?? {});

  /// Determines whether to notify listeners if an equal value is passed to
  /// a key.
  /// For example, if notify if equal is false, the code below will not notify
  /// listeners:
  /// '''
  ///   final mapNotifier = MapNotifier(data: {'one': 1});
  ///   mapNotifier['one'] = 1
  /// '''
  final bool _notifyIfEqual;

  /// [customEquality] can be used to set your own criteria for comparing
  /// values, which might be important if [notifyIfEqual] is false. The function
  /// should return a bool that represents if, when compared, two values are
  /// equal. If null, the default values equality [==] is used.
  final bool Function(V? x, V? y)? customEquality;

  @override
  Map<K, V> get value => UnmodifiableMapView(this);

  @override
  operator []=(K key, V value) {
    final areEqual = customEquality == null
        ? super[key] == value
        : customEquality!(super[key], value);
    super[key] = value;

    if (!areEqual || (areEqual && _notifyIfEqual)) {
      notifyListeners();
    }
  }

  @override
  void addAll(Map<K, V> other) {
    final initialMapValue = {...this};
    super.addAll(other);

    _notifyIfNeeded(initialMapValue);
  }

  /// A method to compare between two maps, this Map Notifier and any other
  /// map that has been passed to it
  bool _areEqual(Map<K, V> other) {
    if (this.length != other.length) {
      return false;
    }

    for (final key in keys) {
      final areValuesEqual = customEquality?.call(this[key], other[key]) ??
          this[key] == other[key];
      if (!areValuesEqual) {
        return false;
      }
    }

    return true;
  }

  void _notifyIfNeeded(Map<K, V> other) {
    if (_shouldNotify(other)) {
      notifyListeners();
    }
  }

  bool _shouldNotify(Map<K, V> other) {
    if (_notifyIfEqual) {
      return true;
    }

    return !_areEqual(other);
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    final initialMapValue = {...this};
    super.addEntries(entries);

    _notifyIfNeeded(initialMapValue);
  }

  @override
  void clear() {
    final shouldNotify = isNotEmpty || _notifyIfEqual;
    super.clear();

    if (shouldNotify) {
      notifyListeners();
    }
  }

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    final initialMapValue = {...this};
    final value = super.putIfAbsent(key, ifAbsent);

    _notifyIfNeeded(initialMapValue);
    return value;
  }

  @override
  V? remove(Object? key) {
    final initialMapValue = {...this};
    final value = super.remove(key);

    _notifyIfNeeded(initialMapValue);

    return value;
  }

  @override
  void removeWhere(bool Function(K, V) test) {
    final initialMapValue = {...this};

    super.removeWhere(test);

    _notifyIfNeeded(initialMapValue);
  }

  @override
  V update(K key, V Function(V) update, {V Function()? ifAbsent}) {
    final initialMapValue = {...this};
    final value = super.update(key, update, ifAbsent: ifAbsent);

    _notifyIfNeeded(initialMapValue);

    return value;
  }

  @override
  void updateAll(V Function(K, V) update) {
    final initialMapValue = {...this};

    super.updateAll(update);

    _notifyIfNeeded(initialMapValue);
  }
}
