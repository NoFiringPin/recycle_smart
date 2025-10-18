import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; // Required for checking the platform (iOS/Android)

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _zipCodeController = TextEditingController();

  Future<void> _launchMaps() async {
    final String zipCode = _zipCodeController.text;
    String query = 'recycling centers';

    // Add zip code to the query if it's provided
    if (zipCode.isNotEmpty) {
      query += ' near $zipCode';
    }

    final String encodedQuery = Uri.encodeComponent(query);
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');

    try {
      // Use LaunchMode.externalApplication to ensure it opens in the Google Maps app
      // instead of an in-app browser.
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      // If launching the URL fails, it's likely the app isn't installed.
      debugPrint('Could not launch map: $e');
      _launchAppStore();
    }
  }

  Future<void> _launchAppStore() async {
    // URLs for the Google Maps app on both stores
    const String googlePlayStoreUrl = 'https://play.google.com/store/apps/details?id=com.google.android.apps.maps';
    const String appleAppStoreUrl = 'https://apps.apple.com/us/app/google-maps/id585027354';

    // Determine the correct URL based on the platform
    final String storeUrl = Platform.isIOS ? appleAppStoreUrl : googlePlayStoreUrl;
    final Uri storeUri = Uri.parse(storeUrl);

    try {
      await launchUrl(storeUri);
    } catch (e) {
      // If the app store can't be opened, show an error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the app store.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _zipCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find Recycling Centers',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1.0,
        centerTitle: false,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 100,
                    color: Colors.green[700],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Find Local Centers',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enter your zip code below to find recycling centers in your area.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _zipCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Zip Code',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_pin),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _launchMaps,
                    icon: const Icon(Icons.location_on_outlined),
                    label: const Text('Open Maps'),
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
          ),
        ),
      ),
    );
  }
}

