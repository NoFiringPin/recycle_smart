import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/material_data.dart';
import '../models/recycling_rate.dart';

class DataService {
  Future<List<MaterialData>> loadMaterialData() async {
    final rates = await loadRecyclingRates();
    final Map<String, double> rateMap = { for (var r in rates) r.materialType : r.rate };

    final String jsonString = await rootBundle.loadString('assets/data/recycling_data.json');
    final List<dynamic> jsonList = json.decode(jsonString);

    return jsonList.map((json) {
      String materialName = json['name'];
      double rate = 0.0;

      // A simple mapping to assign a rate to the dashboard materials
      if (materialName.contains("Plastic")) {
        rate = rateMap['#1 PET (Polyethylene Terephthalate)'] ?? 1.47;
      } else if (materialName.contains("Paper")) {
        rate = rateMap['WDS-Paperboard Carton'] ?? 3.79;
      } else if (materialName.contains("Glass")) {
        rate = rateMap['Glass'] ?? 0.102;
      } else if (materialName.contains("Metal")) {
        rate = rateMap['Aluminum'] ?? 1.65;
      }

      return MaterialData.fromJson(json, rate);
    }).toList();
  }

  Future<List<RecyclingRate>> loadRecyclingRates() async {
    final String jsonString = await rootBundle.loadString('assets/data/recycling_rates.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => RecyclingRate.fromJson(json)).toList();
  }
}

