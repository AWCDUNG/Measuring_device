import 'package:flutter/material.dart';

class TimePeriodSelector extends StatefulWidget {
  final Function(String) onPeriodSelected;
  
  const TimePeriodSelector({
    Key? key,
    required this.onPeriodSelected,
  }) : super(key: key);
  
  @override
  _TimePeriodSelectorState createState() => _TimePeriodSelectorState();
}

class _TimePeriodSelectorState extends State<TimePeriodSelector> {
  String selectedPeriod = '1 giờ';
  final List<String> periods = ['1 giờ', '24 giờ', '7 ngày', '30 ngày'];
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Khoảng thời gian',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: periods.map((period) {
            bool isSelected = period == selectedPeriod;
            return Padding(
              padding: EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPeriod = period;
                  });
                  widget.onPeriodSelected(period);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[600] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}