// models/air_quality_data.dart
class AirQualityData {
  final double aqi;
  final double pm10;
  final double humidity;
  final double coGas;
  final double pm25;
  final double temperature;
  final double windSpeed;
  final double windDirection;
  final double rainfall;
  final String? predict;
  final DateTime? timestamp;

  AirQualityData({
    required this.aqi,
    required this.pm10,
    required this.humidity,
    required this.coGas,
    required this.pm25,
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
    required this.rainfall,
    this.predict,
    this.timestamp,
  });

  // Factory constructor để parse từ JSON API của bạn
  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    return AirQualityData(
      // Map các trường từ API JSON của bạn
      aqi: _parseDouble(json['AQI']),           // "25"
      pm25: _parseDouble(json['PM25']),         // "6.11"
      pm10: _parseDouble(json['PM10']),         // "7.58"
      temperature: _parseDouble(json['Temp']),   // "41.5"
      humidity: _parseDouble(json['Humi']),      // "43.4"
      windSpeed: _parseDouble(json['Wind_speed']), // "0"
      rainfall: _parseDouble(json['Rain']),      // "0"
      coGas: _parseDouble(json['CO']),          // "943.22"
      windDirection: _parseDouble(json['Wind_direction']), // "45"
      predict: json['Predict']?.toString(),     // "None"
      timestamp: DateTime.now(), // Vì API không có timestamp, dùng thời gian hiện tại
    );
  }

  // Helper method để parse double an toàn
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Convert sang JSON để gửi lên API (sử dụng format của API)
  Map<String, dynamic> toJson() {
    return {
      'AQI': aqi.toString(),
      'PM25': pm25.toString(),
      'PM10': pm10.toString(),
      'Temp': temperature.toString(),
      'Humi': humidity.toString(),
      'Wind_speed': windSpeed.toString(),
      'Rain': rainfall.toString(),
      'CO': coGas.toString(),
      'Wind_direction': windDirection.toString(),
      'Predict': predict ?? 'None',
    };
  }

  // Convert sang JSON với format cũ (nếu cần dùng cho UI)
  Map<String, dynamic> toLocalJson() {
    return {
      'aqi': aqi,
      'pm10': pm10,
      'humidity': humidity,
      'coGas': coGas,
      'pm25': pm25,
      'temperature': temperature,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'rainfall': rainfall,
      'predict': predict,
    };
  }

  // Dữ liệu mẫu cho trường hợp không có kết nối
  static AirQualityData getSampleData() {
    return AirQualityData(
      aqi: 25,
      pm10: 7.58,
      humidity: 43.4,
      coGas: 943.22,
      pm25: 6.11,
      temperature: 41.5,
      windSpeed: 0,
      windDirection: 45,
      rainfall: 0,
      predict: 'None',
      timestamp: DateTime.now(),
    );
  }

  // Method để kiểm tra chất lượng không khí
  String getAirQualityStatus() {
    if (aqi <= 50) return 'Tốt';
    if (aqi <= 100) return 'Trung bình';
    if (aqi <= 150) return 'Kém';
    if (aqi <= 200) return 'Có hại';
    if (aqi <= 300) return 'Rất có hại';
    return 'Nguy hiểm';
  }

  // Method để lấy màu theo AQI
  int getAirQualityColor() {
    if (aqi <= 50) return 0xFF4CAF50; // Green
    if (aqi <= 100) return 0xFFFFEB3B; // Yellow
    if (aqi <= 150) return 0xFFFF9800; // Orange
    if (aqi <= 200) return 0xFFF44336; // Red
    if (aqi <= 300) return 0xFF9C27B0; // Purple
    return 0xFF795548; // Brown
  }

  // Method để lấy trạng thái PM2.5
  String getPM25Status() {
    if (pm25 <= 12) return 'Tốt';
    if (pm25 <= 35.4) return 'Trung bình';
    if (pm25 <= 55.4) return 'Kém cho nhóm nhạy cảm';
    if (pm25 <= 150.4) return 'Có hại';
    if (pm25 <= 250.4) return 'Rất có hại';
    return 'Nguy hiểm';
  }

  // Method để lấy trạng thái nhiệt độ
  String getTemperatureStatus() {
    if (temperature < 16) return 'Lạnh';
    if (temperature < 25) return 'Mát';
    if (temperature < 32) return 'Ấm';
    if (temperature < 38) return 'Nóng';
    return 'Rất nóng';
  }

  // Method để format hiển thị
  String getFormattedData() {
    return '''
AQI: ${aqi.toInt()} (${getAirQualityStatus()})
PM2.5: ${pm25.toStringAsFixed(1)} μg/m³
PM10: ${pm10.toStringAsFixed(1)} μg/m³
Nhiệt độ: ${temperature.toStringAsFixed(1)}°C
Độ ẩm: ${humidity.toStringAsFixed(1)}%
Tốc độ gió: ${windSpeed.toStringAsFixed(1)} m/s
Lượng mưa: ${rainfall.toStringAsFixed(1)} mm
CO: ${coGas.toStringAsFixed(2)} ppm
Dự đoán: ${predict ?? 'Không có'}
''';
  }
}