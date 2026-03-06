import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/data/models/provider_service_model.dart';

void main() {
  group('ProviderServiceModel', () {
    test('fromJson should handle valid JSON with lists', () {
      final jsonStr = '''
      {
        "statusCode": 200,
        "success": true,
        "message": "Service fetched successfully",
        "data": {
          "providerId": {
            "_id": "p1",
            "name": "Provider One",
            "email": "provider@example.com",
            "profile": "profile.jpg",
            "id": "p1"
          },
          "title": "Service Title",
          "description": "Service Description",
          "category": {
            "_id": "c1",
            "name": "Photography",
            "image": "cat.jpg",
            "id": "c1"
          },
          "tags": ["tag1", "tag2"],
          "equipment": ["camera"],
          "price": 100,
          "currency": "USD",
          "pricingType": "fixed",
          "travelFeePerKm": 5.5,
          "allowOutsideRadius": true,
          "maxTravelFee": 50,
          "depositPercentage": 10.0,
          "duration": "1h",
          "gallery": [],
          "status": "active",
          "isVerified": true,
          "isActive": true,
          "_id": "s1",
          "pricingRules": [],
          "createdAt": "2024-03-07T00:00:00Z",
          "updatedAt": "2024-03-07T00:00:00Z",
          "__v": 0,
          "id": "s1"
        }
      }
      ''';

      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      final model = ProviderServiceModel.fromJson(jsonMap);

      expect(model.statusCode, 200);
      expect(model.data?.title, "Service Title");
      expect(model.data?.tags, ["tag1", "tag2"]);
      expect(model.data?.gallery, isEmpty);
      expect(model.data?.pricingRules, isEmpty);
      expect(model.data?.travelFeePerKm, 5.5);
      expect(model.data?.depositPercentage, 10.0);
    });

    test('fromJson should handle null lists safely', () {
      final jsonStr = '''
      {
        "statusCode": 200,
        "success": true,
        "data": {
          "tags": null,
          "equipment": null,
          "gallery": null,
          "pricingRules": null
        }
      }
      ''';

      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      final model = ProviderServiceModel.fromJson(jsonMap);

      expect(model.data?.tags, isNull);
      expect(model.data?.equipment, isNull);
      expect(model.data?.gallery, isNull);
      expect(model.data?.pricingRules, isNull);
    });

    test('toJson should work correctly', () {
      final model = ProviderServiceModel(
        statusCode: 200,
        success: true,
        data: Data(title: "Test", tags: ["t1"], gallery: []),
      );

      final jsonMap = model.toJson();
      expect(jsonMap['statusCode'], 200);
      expect(jsonMap['data']['title'], "Test");
      expect(jsonMap['data']['tags'], ["t1"]);
      expect(jsonMap['data']['gallery'], isEmpty);
    });
  });
}
