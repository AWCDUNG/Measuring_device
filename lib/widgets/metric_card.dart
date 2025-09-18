import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String unit;
  final Color? backgroundColor;

  const MetricCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.unit,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallScreen = screenWidth < 320;
    
    // Responsive sizes
    final cardPadding = isVerySmallScreen ? 8.0 : (isSmallScreen ? 10.0 : 12.0);
    final iconContainerSize = isVerySmallScreen ? 32.0 : (isSmallScreen ? 36.0 : 40.0);
    final iconSize = isVerySmallScreen ? 16.0 : (isSmallScreen ? 18.0 : 20.0);
    final titleFontSize = isVerySmallScreen ? 11.0 : (isSmallScreen ? 12.0 : 13.0);
    final valueFontSize = isVerySmallScreen ? 18.0 : (isSmallScreen ? 22.0 : 24.0);
    final unitFontSize = isVerySmallScreen ? 10.0 : (isSmallScreen ? 11.0 : 12.0);
    
    // Responsive spacing
    final verticalSpacing = isSmallScreen ? 6.0 : 8.0;
    final smallSpacing = isSmallScreen ? 4.0 : 6.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon container - Compact design
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
          ),
          
          SizedBox(height: verticalSpacing),
          
          // Title - Single line with ellipsis
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: smallSpacing),
          
          // Value and Unit - Optimized layout
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      height: 1.0,
                    ),
                  ),
                  SizedBox(width: 2),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Text(
                      unit,
                      style: TextStyle(
                        fontSize: unitFontSize,
                        color: Colors.grey[600],
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}