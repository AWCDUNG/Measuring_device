// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/air_quality_data.dart';

class ApiService {
  // Thay đổi thành URL API thực tế của bạn
  static const String baseUrl = 'http://118.70.240.188/php/get2.php';
  
  // Lấy dữ liệu mới nhất
  static Future<AirQualityData> getLatestData() async {
    try {
      print('Fetching data from: $baseUrl/get.php');
      
      final response = await http.get(
        Uri.parse('$baseUrl/get.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Kiểm tra cấu trúc JSON từ API của bạn
        if (jsonData['data'] != null && jsonData['data'].isNotEmpty) {
          // Lấy phần tử đầu tiên trong mảng data
          final firstDataPoint = jsonData['data'][0];
          print('Parsing data: $firstDataPoint');
          
          return AirQualityData.fromJson(firstDataPoint);
        } else {
          print('No data in response, using sample data');
          return AirQualityData.getSampleData();
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      // Trả về dữ liệu mẫu khi có lỗi
      print('Returning sample data due to error');
      return AirQualityData.getSampleData();
    }
  }
  
  // Lấy dữ liệu lịch sử (nếu API hỗ trợ)
  static Future<List<AirQualityData>> getHistoryData(int hours) async {
    try {
      // Thử với tham số hours
      final response = await http.get(
        Uri.parse('$baseUrl/get.php?hours=$hours'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['data'] != null) {
          List<AirQualityData> dataList = [];
          for (var item in jsonData['data']) {
            dataList.add(AirQualityData.fromJson(item));
          }
          return dataList;
        }
      }
      
      // Nếu không có dữ liệu lịch sử, trả về data hiện tại
      final currentData = await getLatestData();
      return [currentData];
      
    } catch (e) {
      print('History API Error: $e');
      // Trả về dữ liệu mẫu
      return [AirQualityData.getSampleData()];
    }
  }
  
  // Test kết nối API
  static Future<bool> testConnection() async {
    try {
      print('Testing connection to: $baseUrl/get.php');
      
      final response = await http.get(
        Uri.parse('$baseUrl/get.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 5));
      
      print('Test response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        bool hasData = jsonData['data'] != null && jsonData['data'].isNotEmpty;
        print('Connection test successful, has data: $hasData');
        return true;
      }
      
      return false;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
  
  // Method để test và hiển thị dữ liệu
  static Future<void> debugApi() async {
    try {
      print('=== API DEBUG START ===');
      
      bool isConnected = await testConnection();
      print('Connection status: $isConnected');
      
      if (isConnected) {
        AirQualityData data = await getLatestData();
        print('Data received:');
        print(data.getFormattedData());
      }
      
      print('=== API DEBUG END ===');
    } catch (e) {
      print('Debug error: $e');
    }
  }
}