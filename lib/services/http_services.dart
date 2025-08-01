import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_connect.dart';
import 'package:http/http.dart' as http;

import '../utility/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class HttpService {
  final String baseUrl = MAIN_URL;

  Future<Response> getItems({required String endpointUrl}) async {
    try {
      return await GetConnect().get('$baseUrl/$endpointUrl');
    } catch (e) {
      return Response(
          body: json.encode({'error': e.toString()}), statusCode: 500);
    }
  }

  void printFormData(FormData formData) {
    print("📤 FormData fields:");
    formData.fields.forEach((field) {
      print('📝 ${field.key} = ${field.value}');
    });

    print("🖼️ FormData files:");
    formData.files.forEach((field) {
      print('📁 ${field.key} = filename: ${field.value.filename}');
    });
  }

  Future<http.Response?> uploadProduct({
  required Map<String, dynamic> fields,
  required List<Map<String, XFile?>> imgXFiles,
}) async {
  final uri = Uri.parse("https://printrella-backend.onrender.com/products");

  var request = http.MultipartRequest('POST', uri);

  print("📤 FormData fields:");
  fields.forEach((key, value) {
    request.fields[key] = value.toString();
    print("📝 $key = ${value.toString()}");
  });

  print("🖼️ FormData files:");
  for (var imgMap in imgXFiles) {
    for (var entry in imgMap.entries) {
      final fieldName = entry.key;
      final image = entry.value;

      if (image != null) {
        try {
          if (kIsWeb) {
            Uint8List bytes = await image.readAsBytes();
            var multipartFile = http.MultipartFile.fromBytes(
              fieldName,
              bytes,
              filename: image.name,
            );
            request.files.add(multipartFile);
            print("📁 $fieldName = filename: ${image.name} (from bytes)");
          } else {
            var multipartFile = await http.MultipartFile.fromPath(
              fieldName,
              image.path,
              filename: image.name,
            );
            request.files.add(multipartFile);
            print("📁 $fieldName = filename: ${image.name} (from path)");
          }
        } catch (e) {
          print("⚠️ Failed to add image '$fieldName': $e");
        }
      }
    }
  }

  try {
    print("🚀 Sending request to: $uri");
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print("✅ Success: ${response.body}");
    } else {
      print("❌ Error ${response.statusCode}: ${response.body}");
    }
    return response;
  } catch (e) {
    print("🔥 Exception occurred while sending: $e");
    return null; // ✅ هذه هي الطريقة الصحيحة
  }
}


  Future<http.Response?> uploadcategoriy({
    required Map<String, dynamic> fields,
    required List<Map<String, XFile?>> imgXFiles,
  }) async {
    final uri = Uri.parse("https://printrella-backend.onrender.com/categories");

    var request = http.MultipartRequest('POST', uri);

    print("📤 FormData fields:");
    fields.forEach((key, value) {
      request.fields[key] = value.toString();
      print("📝 $key = ${value.toString()}");
    });

    print("🖼️ FormData files:");
    for (var imgMap in imgXFiles) {
      for (var entry in imgMap.entries) {
        final fieldName = entry.key;
        final image = entry.value;

        if (image != null) {
          try {
            if (kIsWeb) {
              Uint8List bytes = await image.readAsBytes();
              var multipartFile = http.MultipartFile.fromBytes(
                fieldName,
                bytes,
                filename: image.name,
              );
              request.files.add(multipartFile);
              print("📁 $fieldName = filename: ${image.name} (from bytes)");
            } else {
              var multipartFile = await http.MultipartFile.fromPath(
                fieldName,
                image.path,
                filename: image.name,
              );
              request.files.add(multipartFile);
              print("📁 $fieldName = filename: ${image.name} (from path)");
            }
          } catch (e) {
            print("⚠️ Failed to add image '$fieldName': $e");
          }
        }
      }
    }

    try {
      print("🚀 Sending request to: $uri");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print("✅ Success: ${response.body}");
      } else {
        print("❌ Error ${response.statusCode}: ${response.body}");
      }
      return response;
    } catch (e) {
      print("🔥 Exception occurred while sending: $e");
      return null;
    }
  }

  Future<Response> addItem({
    required String endpointUrl,
    required dynamic itemData,
  }) async {
    try {
      print('🔄 Sending data to: $baseUrl/$endpointUrl');
      if (itemData is FormData) {
        printFormData(itemData);
      } else {
        print('📦 Payload (itemData): $itemData');
      }
      final response =
          await GetConnect().post('$baseUrl/$endpointUrl', itemData);

      print('✅ Response body: ${response.body}');
      print('📡 Status Code: ${response.statusCode}');

      return response;
    } catch (e, stackTrace) {
      print('❌ Error sending request: $e');
      print('🧵 StackTrace: $stackTrace');
      print('📦 Failed itemData: $itemData');

      return Response(
        body: {'message': e.toString()},
        statusCode: 500,
      );
    }
  }

  Future<Response> updateItem(
      {required String endpointUrl,
      required String itemId,
      required dynamic itemData}) async {
    try {
      return await GetConnect().put('$baseUrl/$endpointUrl/$itemId', itemData);
    } catch (e) {
      return Response(
          body: json.encode({'message': e.toString()}), statusCode: 500);
    }
  }

  Future<Response> deleteItem(
      {required String endpointUrl, required String itemId}) async {
    try {
      return await GetConnect().delete('$baseUrl/$endpointUrl/$itemId');
    } catch (e) {
      return Response(
          body: json.encode({'message': e.toString()}), statusCode: 500);
    }
  }
}
