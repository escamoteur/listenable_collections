import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class MapNotifier<K, V> extends DelegatingMap<K, V>
    with ChangeNotifier
    implements ValueListenable<Map<K, V>> {
  MapNotifier({
    Map<K, V>? data,
    bool notifyIfEqual = false,
    this.customEquality,
  })  : _notifyIfEqual = notifyIfEqual,
        super(data ?? {});

  final bool _notifyIfEqual;
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

    if (_shouldNotify(initialMapValue)) {
      notifyListeners();
    }
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

    if (_shouldNotify(initialMapValue)) {
      notifyListeners();
    }
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

    if (_shouldNotify(initialMapValue)) {
      notifyListeners();
    }
    return value;
  }

  @override
  V? remove(Object? key) {
    final initialMapValue = {...this};
    final value = super.remove(key);

    if (_shouldNotify(initialMapValue)) {
      notifyListeners();
    }

    return value;
  }

  @override
  void removeWhere(bool Function(K, V) test) {
    final initialMapValue = {...this};

    super.removeWhere(test);

    if (_shouldNotify(initialMapValue)) {
      notifyListeners();
    }
  }

  @override
  V update(K key, V Function(V) update, {V Function()? ifAbsent}) {
    final initialMapValue = {...this};
    final value = super.update(key, update, ifAbsent: ifAbsent);

    if (_shouldNotify(initialMapValue)) {
      notifyListeners();
    }

    return value;
  }

  @override
  void updateAll(V Function(K, V) update) {
    final initialMapValue = {...this};

    super.updateAll(update);

    if (_shouldNotify(initialMapValue)) {
      notifyListeners();
    }
  }
}
