// widgets/aqi_realtime_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class AQIRealtimeChart extends StatefulWidget {
  final List<Map<String, dynamic>> chartData; // Nhận dữ liệu từ parent
  final int maxDataPoints;
  
  const AQIRealtimeChart({
    Key? key,
    required this.chartData, // Required parameter
    this.maxDataPoints = 20,
  }) : super(key: key);

  @override
  _AQIRealtimeChartState createState() => _AQIRealtimeChartState();
}

class _AQIRealtimeChartState extends State<AQIRealtimeChart> 
    with TickerProviderStateMixin {
  List<FlSpot> aqiData = [];
  List<DateTime> timestamps = [];
  double minY = 0;
  double maxY = 100;
  
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _updateChartData();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(AQIRealtimeChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chartData != widget.chartData) {
      _updateChartData();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateChartData() {
    aqiData.clear();
    timestamps.clear();
    
    for (int i = 0; i < widget.chartData.length; i++) {
      final data = widget.chartData[i];
      // Tăng khoảng cách giữa các điểm bằng cách nhân với hệ số
      aqiData.add(FlSpot((i * 2.0), data['aqi'].toDouble())); // Tăng khoảng cách x2
      timestamps.add(data['timestamp'] as DateTime);
    }
    
    _updateYAxisRange();
  }

  void _updateYAxisRange() {
    if (aqiData.isEmpty) return;
    
    double minValue = aqiData.map((e) => e.y).reduce(min);
    double maxValue = aqiData.map((e) => e.y).reduce(max);
    
    // Add some padding
    double padding = (maxValue - minValue) * 0.1;
    if (padding < 10) padding = 10;
    
    minY = (minValue - padding).clamp(0, double.infinity);
    maxY = maxValue + padding;
  }

  Color _getAQIColor(double aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.brown;
  }

  String _getAQIStatus(double aqi) {
    if (aqi <= 50) return 'Tốt';
    if (aqi <= 100) return 'Trung bình';
    if (aqi <= 150) return 'Kém';
    if (aqi <= 200) return 'Có hại';
    if (aqi <= 300) return 'Rất có hại';
    return 'Nguy hiểm';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        height: isSmallScreen ? 280 : 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biểu đồ AQI thời gian thực',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    if (aqiData.isNotEmpty)
                      Text(
                        'Hiện tại: ${aqiData.last.y.toInt()} (${_getAQIStatus(aqiData.last.y)})',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getAQIColor(aqiData.last.y),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.timeline,
                      color: Colors.blue,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Realtime',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Chart
            Expanded(
              child: aqiData.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Chưa có dữ liệu',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true, // Bật vertical lines để thấy rõ khoảng cách
                              drawHorizontalLine: true,
                              horizontalInterval: (maxY - minY) / 4,
                              verticalInterval: 2.0, // Khoảng cách vertical grid
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey[300]!,
                                  strokeWidth: 1,
                                );
                              },
                              getDrawingVerticalLine: (value) {
                                return FlLine(
                                  color: Colors.grey[200]!,
                                  strokeWidth: 0.5,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 2.0, // Hiển thị label với khoảng cách 2 đơn vị
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    int dataIndex = (value / 2).round(); // Chuyển đổi lại index thực
                                    if (dataIndex >= 0 && dataIndex < timestamps.length) {
                                      final time = timestamps[dataIndex];
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 4),
                                          child: Text(
                                            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return Container();
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: (maxY - minY) / 4,
                                  reservedSize: 35,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 10,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.grey[300]!, width: 1),
                            ),
                            minX: 0,
                            maxX: aqiData.isNotEmpty ? aqiData.last.x + 2 : widget.maxDataPoints * 2.0, // Điều chỉnh maxX
                            minY: minY,
                            maxY: maxY,
                            lineBarsData: [
                              LineChartBarData(
                                spots: aqiData.map((spot) {
                                  return FlSpot(spot.x, spot.y * _animation.value);
                                }).toList(),
                                isCurved: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.withOpacity(0.8),
                                    Colors.blue.withOpacity(0.3),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 5, // Tăng size của dot một chút
                                      color: _getAQIColor(spot.y),
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.withOpacity(0.2),
                                      Colors.blue.withOpacity(0.05),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchSpotThreshold: 20, // Tăng vùng touch để dễ chạm hơn
                              touchTooltipData: LineTouchTooltipData(
                                tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                                tooltipRoundedRadius: 8,
                                tooltipPadding: EdgeInsets.all(8),
                                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                  return touchedBarSpots.map((barSpot) {
                                    final dataIndex = (barSpot.x / 2).round(); // Chuyển đổi lại index thực
                                    final time = dataIndex < timestamps.length 
                                        ? timestamps[dataIndex] 
                                        : DateTime.now();
                                    
                                    return LineTooltipItem(
                                      'AQI: ${barSpot.y.toInt()}\n${_getAQIStatus(barSpot.y)}\n${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                      TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            // AQI Legend
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('Tốt', Colors.green, '0-50'),
                _buildLegendItem('TB', Colors.yellow, '51-100'),
                _buildLegendItem('Kém', Colors.orange, '101-150'),
                _buildLegendItem('Có hại', Colors.red, '151-200'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String range) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          range,
          style: TextStyle(
            fontSize: 8,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}