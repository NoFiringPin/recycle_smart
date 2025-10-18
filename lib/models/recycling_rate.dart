class RecyclingRate {
  final String materialType;
  final double rate;

  RecyclingRate({required this.materialType, required this.rate});

  factory RecyclingRate.fromJson(Map<String, dynamic> json) {
    return RecyclingRate(
      materialType: json['materialType'],
      rate: (json['minimumPerPoundRate'] as num).toDouble(),
    );
  }
}

