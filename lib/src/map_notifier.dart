import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// A map that behaves like [ValueNotifier] if its data changes
/// It does not compare the elements on bulk operations

class MapNotifier<K, V> extends DelegatingMap<K, V> with ChangeNotifier 
    implements ValueListenable<Map<K, V>> {

  /// Creates a new listenable map.
  /// [data] Optional Map that can be passed as initial value
  /// if notifyIfEqual is false, MapNotifier will compare if a value
  /// passed is equal to the existing value
  /// Like `map['version'] = '2.0.7'` will only notify
  MapNotifier({Map<K, V> data, bool notifyIfEqual = true}) : super(data ?? {});

  void _notify() {
    super.notifyListeners();
  }

  /// if this is `true` no listener will be notified if the map changes.
  bool _inTransaction = false;

  /// Starts a transaction that allows to make multiple changes to the Map
  /// with only one notification at the end.
  void startTransAction() {
    assert(!_inTransaction, 'Only one transaction at a time in MapNotifier');
    _inTransaction = true;
  }

  /// Ends a transaction
  void endTransAction() {
    assert(_inTransaction, 'No active transaction in MapNotifier');
    _inTransaction = false;
    _notify();
  }

  /// Returns an unmodifiable view on the map's data
  @override
  Map<K, V> get value => UnmodifiableMapView(this);

  /// from here all functions are equal to `List<T>` with the addition that all
  /// modifying functions will call `notifyListener` if not in a transaction.

  @override
  V operator [](Object key) => super[key];

  @override
  void operator []=(K key, V value) {
    startTransAction();
    super[key] = value;
    endTransAction();
  }

  @override
  void addAll(Map<K, V> other) {
    startTransAction();
    super.addAll(other);
    endTransAction();
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    startTransAction();
    super.addEntries(entries);
    endTransAction();
  }

  @override
  void clear() {
    startTransAction();
    super.clear();
    endTransAction();
  }

  @override
  Map<K2, V2> cast<K2, V2>() => super.cast<K2, V2>();

  @override
  bool containsKey(Object key) => super.containsKey(key);

  @override
  bool containsValue(Object value) => super.containsValue(value);

  @override
  Iterable<MapEntry<K, V>> get entries => super.entries;

  @override
  void forEach(void Function(K, V) f) {
    super.forEach(f);
  }

  @override
  bool get isEmpty => super.isEmpty;

  @override
  bool get isNotEmpty => super.isNotEmpty;

  @override
  Iterable<K> get keys => super.keys;

  @override
  int get length => super.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K, V) transform) =>
      super.map(transform);

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    startTransAction();
    V v = super.putIfAbsent(key, ifAbsent);
    endTransAction();
    return v;
  }

  @override
  V remove(Object key) {
    startTransAction();
    V v = super.remove(key);
    endTransAction();
    return v;
  }

  @override
  void removeWhere(bool Function(K, V) test) {
    startTransAction();
    super.removeWhere(test);
    endTransAction();
  }
  
  @override
  Iterable<V> get values => super.values;

  @override
  String toString() => super.toString();

  @override
  V update(K key, V Function(V) update, {V Function() ifAbsent}) {
    startTransAction();
    V v = super.update(key, update, ifAbsent: ifAbsent);
    endTransAction();
    return v;
  }

  @override
  void updateAll(V Function(K, V) update) {
    startTransAction();
    super.updateAll(update);
    endTransAction();
  }
}
