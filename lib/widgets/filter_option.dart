import 'package:flutter/material.dart';

class FilterOption extends StatelessWidget {
  final String status;
  final int statusCount;
  final Function(String) onTap;

  const FilterOption({
    required this.status,
    required this.onTap,
    required this.statusCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor = Colors.black;
    Color? backgroundColortwo = Colors.black;
    if (status == 'all') {
      backgroundColor = Colors.brown;
      backgroundColortwo = Colors.brown[100];
    } else if (status == 'running') {
      backgroundColor = Colors.green;
      backgroundColortwo = Colors.green[200];
    } else if (status == 'stopped') {
      backgroundColor = Colors.red.shade700;         // Bright alert
      backgroundColortwo = Colors.red.shade100;
    } else if (status == 'idle') {
      backgroundColor = Colors.orangeAccent;
      backgroundColortwo = Colors.orangeAccent[100];
    } else if (status == 'offline') {
      backgroundColor = Colors.blue;
      backgroundColortwo = Colors.blue[100];
    } else if (status == 'nodata') {
      backgroundColor = Colors.grey;
      backgroundColortwo = Colors.grey[300];
    } else if (status == 'expired') {
      backgroundColor = const Color(0xFF5E2129);     // Dark maroon
      backgroundColortwo = const Color(0xFFEAD1D3);
    }

    return Card(
      margin: const EdgeInsets.all(0),
      child: InkWell(
        onTap: () => onTap(status),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: backgroundColortwo!,
                    width: 5.0,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Center(
                    child: Icon(
                      Icons.directions_car,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              statusCount.toString(),
              style:  TextStyle(fontSize: 11,fontWeight: FontWeight.w600),
            ),
            Text(
              status,
              style:  TextStyle(fontSize: 10,fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 5,)
          ],
        ),
      ),
    );
  }
}
