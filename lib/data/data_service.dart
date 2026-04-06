import 'dart:convert';
import 'package:flutter/services.dart';
import 'models/hotel.dart';
import 'models/rumah_sakit.dart';
import 'models/mall.dart';
import 'models/spbu.dart';

class DataService {
  static List<Hotel>? _hotels;
  static List<RumahSakit>? _rumahSakits;
  static List<Mall>? _malls;
  static List<Spbu>? _spbus;

  static Future<List<Hotel>> getHotels() async {
    if (_hotels != null) return _hotels!;
    final data = await rootBundle.loadString('assets/data/hotel.json');
    final list = json.decode(data) as List;
    _hotels = list.map((e) => Hotel.fromJson(e as Map<String, dynamic>)).toList();
    return _hotels!;
  }

  static Future<List<RumahSakit>> getRumahSakits() async {
    if (_rumahSakits != null) return _rumahSakits!;
    final data = await rootBundle.loadString('assets/data/rs.json');
    final list = json.decode(data) as List;
    _rumahSakits = list.map((e) => RumahSakit.fromJson(e as Map<String, dynamic>)).toList();
    return _rumahSakits!;
  }

  static Future<List<Mall>> getMalls() async {
    if (_malls != null) return _malls!;
    final data = await rootBundle.loadString('assets/data/mall.json');
    final list = json.decode(data) as List;
    _malls = list.map((e) => Mall.fromJson(e as Map<String, dynamic>)).toList();
    return _malls!;
  }

  static Future<List<Spbu>> getSpbus() async {
    if (_spbus != null) return _spbus!;
    final data = await rootBundle.loadString('assets/data/spbu.json');
    final list = json.decode(data) as List;
    _spbus = list.map((e) => Spbu.fromJson(e as Map<String, dynamic>)).toList();
    return _spbus!;
  }

  static Future<Map<String, dynamic>> getBogorBoundary() async {
    final data = await rootBundle.loadString('assets/data/bogor.json');
    return json.decode(data) as Map<String, dynamic>;
  }
}
