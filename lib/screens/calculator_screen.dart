import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/data_service.dart';
import '../models/recycling_rate.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final DataService _dataService = DataService();
  late Future<List<RecyclingRate>> _ratesFuture;

  // A map to hold controllers for both pounds and ounces for each material
  final Map<String, ({TextEditingController lbs, TextEditingController oz})> _controllers = {};

  // A map to hold the actual rate values
  final Map<String, double> _ratesMap = {};

  double _totalValue = 0.0;

  @override
  void initState() {
    super.initState();
    _ratesFuture = _dataService.loadRecyclingRates();
  }

  void _calculateTotal() {
    double total = 0.0;
    _controllers.forEach((materialType, controllers) {
      final double lbs = double.tryParse(controllers.lbs.text) ?? 0.0;
      final double oz = double.tryParse(controllers.oz.text) ?? 0.0;
      final double totalWeight = lbs + (oz / 16.0); // Convert ounces to pounds
      final double rate = _ratesMap[materialType] ?? 0.0;
      total += totalWeight * rate;
    });
    setState(() {
      _totalValue = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Refund Calculator',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
        centerTitle: false,
      ),
      body: FutureBuilder<List<RecyclingRate>>(
        future: _ratesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading rates: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recycling rates found.'));
          }

          final rates = snapshot.data!;
          // Initialize controllers and rates map only once
          if (_controllers.isEmpty) {
            for (var rate in rates) {
              _controllers[rate.materialType] = (lbs: TextEditingController(), oz: TextEditingController());
              _ratesMap[rate.materialType] = rate.rate;
            }
          }

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: rates.length,
                      itemBuilder: (context, index) {
                        final rate = rates[index];
                        return _buildMaterialInputCard(rate);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTotalValueCard(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _calculateTotal,
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Text('Calculate Total'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMaterialInputCard(RecyclingRate rate) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rate.materialType,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '@ \$${rate.rate.toStringAsFixed(2)} per pound',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField(_controllers[rate.materialType]!.lbs, 'Lbs')),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(_controllers[rate.materialType]!.oz, 'Oz')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
    );
  }

  Widget _buildTotalValueCard() {
    return Card(
      elevation: 4.0,
      color: Colors.green[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Estimated Refund',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text(
              '\$${_totalValue.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllers.forEach((_, controllers) {
      controllers.lbs.dispose();
      controllers.oz.dispose();
    });
    super.dispose();
  }
}

