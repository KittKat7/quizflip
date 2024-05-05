part of 'flashcard.dart';

class FilterStack {
  List<String> _stack;
  int get length => _stack.length;

  FilterStack({String? filterStr, List<String>? filterList}) : _stack = [] {
    if (filterList != null) {
      _stack = filterList;
    } else if (filterStr != null) {
      _stack = filterStr.split('/')..removeWhere((element) => element.isEmpty);
    } //if/elif
  } //Constructor

  bool startsWith(FilterStack stack) {
    if (length < stack.length) return false;
    for (int i = 0; i < stack.length; i++) {
      if (_stack[i] != stack._stack[i]) return false;
    } //for
    return true;
  } //startsWith

  void push(String layer) {
    _stack.add(layer);
  } //push

  String pop() {
    if (_stack.isEmpty) throw PoppedEmptyStackException();
    return _stack.removeLast();
  } //pop

  String peek() {
    if (_stack.isEmpty) return '';
    return _stack.last;
  } //peek

  @override
  String toString() {
    return '/${_stack.join('/')}/';
  }

  List<String> toList() {
    return List<String>.from(_stack);
  }
} //FilterStack

class PoppedEmptyStackException implements Exception {}
