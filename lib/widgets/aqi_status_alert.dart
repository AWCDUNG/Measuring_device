// widgets/aqi_status_alert.dart
import 'package:flutter/material.dart';

class AQIStatusAlert extends StatelessWidget {
  final double aqi;

  const AQIStatusAlert({
    Key? key,
    required this.aqi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getAQIStatusInfo(aqi);
    
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusInfo['backgroundColor'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusInfo['borderColor'],
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusInfo['borderColor'].withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với icon và trạng thái
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusInfo['iconColor'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  statusInfo['icon'],
                  color: statusInfo['iconColor'],
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chất lượng không khí',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      statusInfo['status'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusInfo['textColor'],
                      ),
                    ),
                  ],
                ),
              ),
              // AQI số
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusInfo['iconColor'],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'AQI ${aqi.toInt()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Thông báo và lời khuyên
          Text(
            statusInfo['message'],
            style: TextStyle(
              fontSize: 14,
              color: statusInfo['textColor'],
              height: 1.4,
            ),
          ),
          
          if (statusInfo['advice'] != null) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusInfo['iconColor'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusInfo['iconColor'].withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: statusInfo['iconColor'],
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusInfo['advice'],
                      style: TextStyle(
                        fontSize: 13,
                        color: statusInfo['textColor'],
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Health impact indicator
          if (aqi > 100) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.health_and_safety_outlined,
                  color: statusInfo['iconColor'],
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  _getHealthImpact(aqi),
                  style: TextStyle(
                    fontSize: 12,
                    color: statusInfo['textColor'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Map<String, dynamic> _getAQIStatusInfo(double aqi) {
    if (aqi <= 50) {
      return {
        'status': 'Tốt',
        'icon': Icons.sentiment_very_satisfied,
        'iconColor': Colors.green[600],
        'backgroundColor': Colors.green[50],
        'borderColor': Colors.green[200],
        'textColor': Colors.green[800],
        'message': 'Chất lượng không khí được coi là đạt tiêu chuẩn và ô nhiễm không khí ít hoặc không có nguy cơ.',
        'advice': 'Thời điểm tuyệt vời để hoạt động ngoài trời!'
      };
    } else if (aqi <= 100) {
      return {
        'status': 'Trung bình',
        'icon': Icons.sentiment_satisfied,
        'iconColor': Colors.yellow[700],
        'backgroundColor': Colors.yellow[50],
        'borderColor': Colors.yellow[300],
        'textColor': Colors.yellow[800],
        'message': 'Chất lượng không khí có thể chấp nhận được đối với hầu hết mọi người, tuy nhiên có thể có lo ngại về sức khỏe cho một số ít người.',
        'advice': 'Người nhạy cảm nên hạn chế hoạt động ngoài trời lâu.'
      };
    } else if (aqi <= 150) {
      return {
        'status': 'Kém',
        'icon': Icons.sentiment_neutral,
        'iconColor': Colors.orange[600],
        'backgroundColor': Colors.orange[50],
        'borderColor': Colors.orange[300],
        'textColor': Colors.orange[800],
        'message': 'Các thành viên của nhóm nhạy cảm có thể gặp các vấn đề về sức khỏe. Công chúng nói chung ít có khả năng bị ảnh hưởng.',
        'advice': 'Trẻ em, người già và người có bệnh hô hấp nên hạn chế ra ngoài.'
      };
    } else if (aqi <= 200) {
      return {
        'status': 'Có hại',
        'icon': Icons.sentiment_dissatisfied,
        'iconColor': Colors.red[600],
        'backgroundColor': Colors.red[50],
        'borderColor': Colors.red[300],
        'textColor': Colors.red[800],
        'message': 'Mọi người có thể bắt đầu gặp các vấn đề về sức khỏe; các thành viên của nhóm nhạy cảm có thể gặp các vấn đề sức khỏe nghiêm trọng hơn.',
        'advice': 'Hạn chế hoạt động ngoài trời, đeo khẩu trang khi ra ngoài.'
      };
    } else if (aqi <= 300) {
      return {
        'status': 'Rất có hại',
        'icon': Icons.sentiment_very_dissatisfied,
        'iconColor': Colors.purple[600],
        'backgroundColor': Colors.purple[50],
        'borderColor': Colors.purple[300],
        'textColor': Colors.purple[800],
        'message': 'Cảnh báo sức khỏe của tình trạng khẩn cấp. Toàn bộ dân số có nhiều khả năng bị ảnh hưởng.',
        'advice': 'Tránh hoạt động ngoài trời, đóng cửa sổ, sử dụng máy lọc không khí.'
      };
    } else {
      return {
        'status': 'Nguy hiểm',
        'icon': Icons.dangerous,
        'iconColor': Colors.brown[700],
        'backgroundColor': Colors.brown[50],
        'borderColor': Colors.brown[400],
        'textColor': Colors.brown[800],
        'message': 'Cảnh báo sức khỏe: mọi người có thể gặp tác động sức khỏe nghiêm trọng hơn.',
        'advice': 'Tuyệt đối không ra ngoài, sử dụng máy lọc không khí, liên hệ y tế nếu có triệu chứng.'
      };
    }
  }

  String _getHealthImpact(double aqi) {
    if (aqi <= 100) return 'Ít ảnh hưởng đến sức khỏe';
    if (aqi <= 150) return 'Ảnh hưởng nhẹ đến nhóm nhạy cảm';
    if (aqi <= 200) return 'Có thể ảnh hưởng đến sức khỏe';
    if (aqi <= 300) return 'Ảnh hưởng nghiêm trọng đến sức khỏe';
    return 'Ảnh hưởng rất nghiêm trọng đến sức khỏe';
  }
}