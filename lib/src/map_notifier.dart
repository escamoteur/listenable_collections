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
    super[key] = value;
    _notify();
  }

  @override
  void addAll(Map<K, V> other) {
    super.addAll(other);
    _notify();
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    super.addEntries(entries);
    _notify();
  }

  @override
  void clear() {
    super.clear();
    _notify();
  }

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    V v = super.putIfAbsent(key, ifAbsent);
    _notify();
    return v;
  }

  @override
  V remove(Object key) {
    final initialLength = this.value.length;
    V v = super.remove(key);

    if(this.value.length != initialLength)
      _notify();

    return v;
  }

  @override
  void removeWhere(bool Function(K, V) test) {
    final initialLength = this.value.length;
    super.removeWhere(test);

    /// only notify if an element was removed
    if(this.value.length == initialLength)
      _notify();
  }
  
  @override
  Iterable<V> get values => super.values;

  @override
  V update(K key, V Function(V) update, {V Function() ifAbsent}) {
    V v = super.update(key, update, ifAbsent: ifAbsent);
    _notify();
    return v;
  }

  @override
  void updateAll(V Function(K, V) update) {
    super.updateAll(update);
    _notify();
  }
}
