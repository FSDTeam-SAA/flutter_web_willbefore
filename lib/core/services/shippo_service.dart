import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutx_core/flutx_core.dart';

class AdminShippoService {
  static const String baseUrl = 'https://api.goshippo.com';
  static const String apiToken =
      'shippo_test_763c1b35dfa914e4695ebd890a960256bf0345d4';

  final headers = {
    'Authorization': 'ShippoToken $apiToken',
    'Content-Type': 'application/json',
  };

  // Re-use address creation (same as user)
  Future<Map<String, dynamic>?> createAddress({
    required String name,
    String? company,
    required String street1,
    String? street2,
    required String city,
    required String state,
    required String zip,
    required String country,
    String? phone,
    String? email,
    bool isResidential = true,
  }) async {
    final url = Uri.parse('$baseUrl/addresses/');
    final body = jsonEncode({
      'name': name,
      if (company != null) 'company': company,
      'street1': street1,
      if (street2 != null) 'street2': street2,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      'is_residential': isResidential,
      'validate': true,
    });

    try {
      final res = await http.post(url, headers: headers, body: body);
      if (res.statusCode == 201) {
        return jsonDecode(res.body);
      } else {
        DPrint.error('Address Error: ${res.statusCode} - ${res.body}');
        return null;
      }
    } catch (e) {
      DPrint.error('Address Exception: $e');
      return null;
    }
  }

  // Create Parcel
  Future<String?> createParcel({
    required double length,
    required double width,
    required double height,
    required String distanceUnit, // 'in', 'cm'
    required double weight,
    required String massUnit, // 'lb', 'oz', 'g', 'kg'
  }) async {
    final url = Uri.parse('$baseUrl/parcels/');
    final body = jsonEncode({
      'length': length.toString(),
      'width': width.toString(),
      'height': height.toString(),
      'distance_unit': distanceUnit,
      'weight': weight.toString(),
      'mass_unit': massUnit,
    });

    try {
      final res = await http.post(url, headers: headers, body: body);
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return data['object_id'];
      } else {
        DPrint.error('Parcel Error: ${res.body}');
        return null;
      }
    } catch (e) {
      DPrint.error('Parcel Exception: $e');
      return null;
    }
  }

  // Create Shipment
  Future<Map<String, dynamic>?> createShipment({
    required String addressFromId,
    required String addressToId,
    required List<String> parcelIds,
  }) async {
    final url = Uri.parse('$baseUrl/shipments/');
    final body = jsonEncode({
      'address_from': addressFromId,
      'address_to': addressToId,
      'parcels': parcelIds,
      'async': false,
    });

    try {
      final res = await http.post(url, headers: headers, body: body);
      if (res.statusCode == 201) {
        return jsonDecode(res.body);
      } else {
        DPrint.error('Shipment Error: ${res.body}');
        return null;
      }
    } catch (e) {
      DPrint.error('Shipment Exception: $e');
      return null;
    }
  }

  // Buy Label
  Future<Map<String, dynamic>?> buyLabel(String rateId) async {
    final url = Uri.parse('$baseUrl/transactions/');
    final body = jsonEncode({
      'rate': rateId,
      'label_file_type': 'PDF',
      'async': false,
    });

    try {
      final res = await http.post(url, headers: headers, body: body);
      if (res.statusCode == 201) {
        return jsonDecode(res.body);
      } else {
        DPrint.error('Transaction Error: ${res.body}');
        return null;
      }
    } catch (e) {
      DPrint.error('Transaction Exception: $e');
      return null;
    }
  }
}
