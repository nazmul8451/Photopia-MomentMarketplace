import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photopia/core/network/Api_service/network_caller.dart';
import 'package:photopia/core/network/urls.dart';
import 'package:photopia/data/models/statistics_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class StatisticsController extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isExporting = false;
  bool get isExporting => _isExporting;

  StatisticsData? _statisticsData;
  StatisticsData? get statisticsData => _statisticsData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStatistics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await NetworkCaller.getRequest(
        url: Urls.statistics,
      );

      if (response.isSuccess && response.body != null) {
        final statsRes = StatisticsResponse.fromJson(response.body!);
        _statisticsData = statsRes.data;
      } else {
        _errorMessage = response.errorMessage ?? "Failed to fetch statistics";
        debugPrint("Failed to fetch statistics: $_errorMessage");
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error fetching statistics: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> exportStatistics() async {
    _isExporting = true;
    notifyListeners();

    try {
      // Use getRequestRaw because the API returns the file directly as binary
      final response = await NetworkCaller.getRequestRaw(
        url: Urls.statisticsExport,
      );

      if (response.isSuccess && response.bodyBytes != null) {
        // 1. Get documents directory (as per docs)
        final directory = await getApplicationDocumentsDirectory();
        
        // 2. Create a filename with .xlsx extension
        final fileName = "statistics-report-${DateTime.now().millisecondsSinceEpoch}.xlsx";
        final filePath = "${directory.path}/$fileName";
        
        // 3. Write binary data to file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes!);
        
        debugPrint("✅ Export successful! File saved at: $filePath");

        // 4. Open the file (using open_filex)
        final result = await OpenFilex.open(filePath);
        debugPrint("Open file result: ${result.message}");

        return filePath;
        
      } else {
        debugPrint("Export failed: ${response.errorMessage}");
        return null;
      }
    } catch (e) {
      debugPrint("Error exporting statistics: $e");
      return null;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }
}
