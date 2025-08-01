import 'dart:developer';
import 'dart:io';
import 'package:admin/models/api_response.dart';
import 'package:admin/utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/data/data_provider.dart';
import '../../../models/category.dart';
import '../../../services/http_services.dart';

class CategoryProvider extends ChangeNotifier {
  final HttpService service = HttpService();
  final DataProvider _dataProvider;

  final addCategoryFormKey = GlobalKey<FormState>();
  final TextEditingController categoryNameCtrl = TextEditingController();

  Category? categoryForUpdate;
  File? selectedImage;
  XFile? imgXFile;
  bool showName = true;

  CategoryProvider(this._dataProvider);

  // Setter for showName toggle
  void setShowName(bool value) {
    showName = value;
    notifyListeners();
  }

  Future<void> addCategory() async {
  try {
    // البيانات النصية
    Map<String, dynamic> formDataMap = {
      'name': categoryNameCtrl.text,
      'image': selectedImage != null ? 'has_image' : 'no_url',
      'show_name': showName.toString(),
    };

    // الصور (إن وُجدت)
    List<Map<String, XFile?>> imgXFiles = [];
    if (imgXFile != null) {
      imgXFiles.add({'image': imgXFile}); // المفتاح يجب أن يكون ما ينتظره الـ backend
    }

    // استدعاء الدالة العامة
    await service.uploadcategoriy(
      fields: formDataMap,
      imgXFiles: imgXFiles,
    );

    // يمكنك هنا بعد النجاح عرض رسالة أو إعادة تحميل البيانات
    clearFields();
    _dataProvider.getAllCategories();
  } catch (e) {
    print("❌ Exception in addCategory: $e");
    SnackBarHelper.showErrorSnackBar('حدث خطأ أثناء إضافة الفئة: $e');
  }
}


  Future<void> updateCategory() async {
    try {
      Map<String, dynamic> formDataMap = {
        'name': categoryNameCtrl.text,
        'image': categoryForUpdate?.image ?? '',
        'show_name': showName,
      };

      final FormData form =
          await createFormData(imgXFile: imgXFile, formData: formDataMap);
      final response = await service.updateItem(
        endpointUrl: 'categories',
        itemId: categoryForUpdate?.sId ?? '',
        itemData: form,
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);

        if (apiResponse.success == true) {
          clearFields();
          SnackBarHelper.showSuccessSnackBar(apiResponse.message);
          log('Category updated');
          _dataProvider.getAllCategories();
        } else {
          SnackBarHelper.showErrorSnackBar(
              'Failed to update category: ${apiResponse.message}');
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error: ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      SnackBarHelper.showErrorSnackBar('An error occurred: $e');
      rethrow;
    }
  }

  Future<void> submitCategory() async {
    if (categoryForUpdate != null) {
      await updateCategory();
    } else {
      await addCategory();
    }
  }

  Future<void> deleteCategory(Category category) async {
    try {
      final response = await service.deleteItem(
        endpointUrl: 'categories',
        itemId: category.sId ?? '',
      );

      if (response.isOk) {
        ApiResponse apiResponse = ApiResponse.fromJson(response.body, null);
        if (apiResponse.success == true) {
          SnackBarHelper.showSuccessSnackBar('Category deleted successfully!');
          _dataProvider.getAllCategories();
        }
      } else {
        SnackBarHelper.showErrorSnackBar(
            'Error: ${response.body?['message'] ?? response.statusText}');
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      imgXFile = image;
      notifyListeners();
    }
  }

  Future<FormData> createFormData({
    required XFile? imgXFile,
    required Map<String, dynamic> formData,
  }) async {
    if (imgXFile != null) {
      MultipartFile multipartFile;
      if (kIsWeb) {
        String fileName = imgXFile.name;
        Uint8List byteImg = await imgXFile.readAsBytes();
        multipartFile = MultipartFile(byteImg, filename: fileName);
      } else {
        String fileName = imgXFile.path.split('/').last;
        multipartFile = MultipartFile(imgXFile.path, filename: fileName);
      }
      formData['img'] = multipartFile;
    }
    return FormData(formData);
  }

  void setDataForUpdateCategory(Category? category) {
    if (category != null) {
      clearFields();
      categoryForUpdate = category;
      categoryNameCtrl.text = category.name ?? '';
    showName = category.showName ?? true;
    } else {
      clearFields();
    }
  }

  void clearFields() {
    categoryNameCtrl.clear();
    selectedImage = null;
    imgXFile = null;
    categoryForUpdate = null;
    showName = true;
    notifyListeners();
  }
}
