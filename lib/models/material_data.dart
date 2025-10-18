import 'package:flutter/material.dart';

class MaterialData {
  final String name;
  final double percentage;
  final double weightLbs;
  final Color color;
  final double value;

  MaterialData({
    required this.name,
    required this.percentage,
    required this.weightLbs,
    required this.color,
    required this.value,
  });

  factory MaterialData.fromJson(Map<String, dynamic> json, double rate) {
    return MaterialData(
      name: json['name'],
      percentage: (json['percentage'] as num).toDouble(),
      weightLbs: (json['weightLbs'] as num).toDouble(),
      color: _colorFromHex(json['color']),
      value: (json['weightLbs'] as num).toDouble() * rate,
    );
  }

  static Color _colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

