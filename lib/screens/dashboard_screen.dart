import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/data_service.dart';
import '../models/material_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<MaterialData>> _materialDataFuture;
  final DataService _dataService = DataService();
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _materialDataFuture = _dataService.loadMaterialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RecycleSmart Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
        centerTitle: false,
      ),
      body: FutureBuilder<List<MaterialData>>(
        future: _materialDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available.'));
          }

          final materials = snapshot.data!;
          return _buildContent(materials);
        },
      ),
    );
  }

  Widget _buildContent(List<MaterialData> materials) {
    double totalValue = materials.fold(0.0, (sum, item) => sum + item.value);
    double totalWeight = materials.fold(0.0, (sum, item) => sum + item.weightLbs);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Material Breakdown'),
            _buildMaterialBreakdownCard(materials),
            const SizedBox(height: 24),
            _buildEstimatedValueCard(totalValue, totalWeight),
            const SizedBox(height: 24),
            _buildSectionTitle('Material Details'),
            _buildMaterialDetailsList(materials),
            const SizedBox(height: 24),
            _buildEnvironmentalImpactCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialBreakdownCard(List<MaterialData> materials) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex =
                              pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: _buildPieChartSections(materials),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: _buildLegend(materials),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(List<MaterialData> materials) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: materials.map((material) {
        return _buildLegendItem(material.color, '${material.name} (${material.percentage.toStringAsFixed(0)}%)');
      }).toList(),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(text, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(List<MaterialData> materials) {
    return List.generate(materials.length, (i) {
      final isTouched = (i == touchedIndex);
      final double radius = isTouched ? 60.0 : 50.0;
      final double fontSize = isTouched ? 18.0 : 14.0;
      final material = materials[i];

      Widget badgeWidget = _Badge(
        title: material.name,
        size: isTouched ? 40 : 0,
        borderColor: material.color,
      );

      return PieChartSectionData(
        color: material.color,
        value: material.percentage,
        title: '${material.percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2)],
        ),
        badgeWidget: badgeWidget,
        badgePositionPercentageOffset: .98,
        showTitle: true,
      );
    });
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF36A373),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Project Analysis', style: TextStyle(color: Colors.white, fontSize: 14)),
              const Spacer(),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.lightGreenAccent, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('Live', style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('84%', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
          const Text('Sorting Score', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Great Job! Keep Improving', style: TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEstimatedValueCard(double totalValue, double totalWeight) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: const Color(0xFFE8F5E9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text('From ${totalWeight.toStringAsFixed(1)} lbs of recyclables', style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
            Text('\$${totalValue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialDetailsList(List<MaterialData> materials) {
    final valuableMaterials = materials.where((m) => m.name != "Trash").toList();

    return Column(
      children: valuableMaterials.map((material) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildMaterialDetailItem(
            material.name,
            '${material.weightLbs.toStringAsFixed(1)} lbs',
            '\$${material.value.toStringAsFixed(2)}',
            material.color,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMaterialDetailItem(String name, String weight, String value, Color color) {
    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 16),
            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(weight, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text(value, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalImpactCard() {
    return Card(
      elevation: 2.0,
      color: const Color(0xFFE3F2FD),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text('Environmental Impact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ImpactStat(value: '32 lbs', label: 'CO₂ Saved'),
                _ImpactStat(value: '156 gal', label: 'Water Saved'),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ImpactStat(value: '0.8 kWh', label: 'Energy Saved'),
                _ImpactStat(value: '2.1 trees', label: 'Equivalent'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class _Badge extends StatelessWidget {
  final String title;
  final double size;
  final Color borderColor;

  const _Badge({
    required this.title,
    required this.size,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size * 0.25,
            fontWeight: FontWeight.bold,
            color: borderColor,
          ),
        ),
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  final String value;
  final String label;
  const _ImpactStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

