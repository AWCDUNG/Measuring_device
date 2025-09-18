// screens/air_quality_screen.dart - Fixed version with chart data management
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/air_quality_data.dart';
import '../widgets/metric_card.dart';
import '../widgets/aqi_status_alert.dart';
import '../widgets/aqi_realtime_chart.dart'; // Import the new chart widget
import '../services/api_service.dart';

class AirQualityScreen extends StatefulWidget {
  @override
  _AirQualityScreenState createState() => _AirQualityScreenState();
}

class _AirQualityScreenState extends State<AirQualityScreen> {
  AirQualityData? airQualityData;
  bool isLoading = true;
  bool isConnected = false;
  String? errorMessage;
  Timer? _refreshTimer;
  
  // Thêm list để lưu trữ dữ liệu biểu đồ
  List<Map<String, dynamic>> chartData = [];
  final int maxDataPoints = 20;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _fetchLatestData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Kiểm tra kết nối API
  Future<void> _checkConnection() async {
    try {
      bool connected = await ApiService.testConnection();
      setState(() {
        isConnected = connected;
      });
    } catch (e) {
      setState(() {
        isConnected = false;
      });
    }
  }

  // Lấy dữ liệu mới nhất
  Future<void> _fetchLatestData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      AirQualityData data = await ApiService.getLatestData();
      
      // Thêm dữ liệu mới vào chartData
      _addDataToChart(data);
      
      setState(() {
        airQualityData = data;
        isLoading = false;
        isConnected = true;
      });
      
    } catch (e) {
      // Nếu lỗi, sử dụng dữ liệu mẫu
      AirQualityData sampleData = AirQualityData.getSampleData();
      
      // Thêm dữ liệu mẫu vào chartData
      _addDataToChart(sampleData);
      
      setState(() {
        airQualityData = sampleData;
        isLoading = false;
        isConnected = false;
        errorMessage = e.toString();
      });
      
      print('Error fetching data: $e');
    }
  }

  // Thêm dữ liệu vào biểu đồ
  void _addDataToChart(AirQualityData data) {
    final newDataPoint = {
      'timestamp': data.timestamp ?? DateTime.now(),
      'aqi': data.aqi.toDouble(),
    };
    
    chartData.add(newDataPoint);
    
    // Giới hạn số điểm dữ liệu
    if (chartData.length > maxDataPoints) {
      chartData.removeAt(0);
    }
  }

  // Tự động refresh dữ liệu
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        _fetchLatestData();
      }
    });
  }

  // Refresh manual
  Future<void> _onRefresh() async {
    await _fetchLatestData();
  }

  // Tính toán số cột dựa trên kích thước màn hình
  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth < 360) return 2;  // Màn hình nhỏ
    if (screenWidth < 600) return 2;  // Màn hình trung bình
    return 3;                         // Màn hình lớn
  }

  // Tính toán aspect ratio dựa trên số cột
  double _getChildAspectRatio(int crossAxisCount, bool isSmallScreen) {
    if (crossAxisCount == 2) {
      return isSmallScreen ? 1.3 : 1.2;  // Card cho 2 cột
    }
    return isSmallScreen ? 1.0 : 0.9;     // Card cho 3 cột
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final padding = isSmallScreen ? 12.0 : 16.0;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chất lượng không khí',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 16 : 18,
              ),
            ),
            if (airQualityData?.timestamp != null)
              Text(
                'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(airQualityData!.timestamp!)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isSmallScreen ? 10 : 12,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: padding,
        actions: [
          // Hiển thị trạng thái kết nối - Tối ưu cho mobile
          Container(
            margin: EdgeInsets.only(right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isConnected ? Icons.wifi : Icons.wifi_off,
                  color: isConnected ? Colors.green : Colors.red,
                  size: isSmallScreen ? 16 : 18,
                ),
                Text(
                  isConnected ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: isConnected ? Colors.green : Colors.red,
                    fontSize: isSmallScreen ? 9 : 10,
                  ),
                ),
              ],
            ),
          ),
          // Nút refresh
          IconButton(
            icon: Icon(
              Icons.refresh, 
              color: Colors.grey[700],
              size: isSmallScreen ? 20 : 24,
            ),
            onPressed: isLoading ? null : _onRefresh,
            padding: EdgeInsets.all(8),
            constraints: BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hiển thị lỗi nếu có - Tối ưu cho mobile
              if (!isConnected && errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(padding),
                  margin: EdgeInsets.only(bottom: padding),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning, 
                        color: Colors.orange[700], 
                        size: isSmallScreen ? 16 : 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Không thể kết nối server. Hiển thị dữ liệu mẫu.',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Loading indicator - Tối ưu kích thước
              if (isLoading)
                Container(
                  height: screenHeight * 0.3,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: isSmallScreen ? 32 : 40,
                          height: isSmallScreen ? 32 : 40,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Đang tải dữ liệu...',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (airQualityData != null) ...[
                // AQI Status Alert
                AQIStatusAlert(aqi: airQualityData!.aqi),
                
                SizedBox(height: padding),
                
                // Real-time AQI Chart - FIXED: Truyền dữ liệu từ parent
                AQIRealtimeChart(
                  chartData: chartData, // Truyền dữ liệu từ parent
                  maxDataPoints: maxDataPoints,
                ),
                
                SizedBox(height: padding),
                
                // Title cho các chỉ số chi tiết
                Text(
                  'Các chỉ số chi tiết',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                
                SizedBox(height: padding * 0.75),
                
                // Data grid - Responsive layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
                    final childAspectRatio = _getChildAspectRatio(crossAxisCount, isSmallScreen);
                    
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: isSmallScreen ? 8 : 12,
                      mainAxisSpacing: isSmallScreen ? 12 : 16,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      childAspectRatio: childAspectRatio,
                      children: [
                        MetricCard(
                          icon: Icons.location_on,
                          iconColor: Colors.blue,
                          title: 'PM10',
                          value: airQualityData!.pm10.toStringAsFixed(1),
                          unit: 'μg/m³',
                        ),
                        MetricCard(
                          icon: Icons.location_on,
                          iconColor: Colors.grey,
                          title: 'PM2.5',
                          value: airQualityData!.pm25.toStringAsFixed(1),
                          unit: 'μg/m³',
                        ),
                        MetricCard(
                          icon: Icons.warning,
                          iconColor: Colors.pink,
                          title: 'CO Gas',
                          value: airQualityData!.coGas.toInt().toString(),
                          unit: 'μg/m³',
                        ),
                        MetricCard(
                          icon: Icons.thermostat,
                          iconColor: Colors.orange,
                          title: 'Nhiệt độ',
                          value: airQualityData!.temperature.toStringAsFixed(1),
                          unit: '°C',
                        ),
                        MetricCard(
                          icon: Icons.water_drop,
                          iconColor: Colors.teal,
                          title: 'Độ ẩm',
                          value: airQualityData!.humidity.toStringAsFixed(1),
                          unit: '%',
                        ),
                        MetricCard(
                          icon: Icons.air,
                          iconColor: Colors.lightBlue,
                          title: 'Tốc độ gió',
                          value: airQualityData!.windSpeed.toInt().toString(),
                          unit: 'm/s',
                        ),
                        MetricCard(
                          icon: Icons.navigation,
                          iconColor: Colors.pink[300]!,
                          title: 'Hướng gió',
                          value: airQualityData!.windDirection.toInt().toString(),
                          unit: '°',
                        ),
                        MetricCard(
                          icon: Icons.beach_access,
                          iconColor: Colors.cyan,
                          title: 'Lượng mưa',
                          value: airQualityData!.rainfall.toInt().toString(),
                          unit: 'mm',
                        ),
                      ],
                    );
                  },
                ),
              ],
              
              // Thêm padding bottom để tránh bị che bởi navigation bar
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }
}