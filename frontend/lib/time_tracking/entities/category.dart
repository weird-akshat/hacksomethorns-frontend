import 'package:flutter/material.dart';

class Category {
  String _userId;
  int _categoryId;
  String _name;
  Color _color;

  Category(this._userId, this._categoryId, this._name, this._color);

  String get userId => _userId;
  set userId(String value) {
    _userId = value;
  }

  int get categoryId => _categoryId;
  set categoryId(int value) {
    _categoryId = value;
  }

  String get name => _name;
  set name(String value) {
    _name = value;
  }

  Color get color => _color;
  set color(Color value) {
    _color = value;
  }
}
