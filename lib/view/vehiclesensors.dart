import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class VehicleSensorsData extends StatelessWidget {
  final List<dynamic> vehicleSensorsData;
  final String vehicleName;

  const VehicleSensorsData({
    super.key,
    required this.vehicleSensorsData,
    required this.vehicleName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_outlined, size: 2.h, color: Color(0xFF212121)),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Vehicle Sensors', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp, color: Color(0xFF212121))),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              vehicleName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: vehicleSensorsData.length,
                      itemBuilder: (context, index) {
                        return _buildSensorItem(context, index);
                      },
                      separatorBuilder: (context, index) => const Divider(
                        height: 24,
                        thickness: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorItem(BuildContext context, int index) {
    final sensor = vehicleSensorsData[index];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            sensor.name?.toString() ?? 'Unknown', // Use dot notation
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            sensor.value?.toString() ?? 'N/A', // Use dot notation
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.right,
            softWrap: true,
            maxLines: 4,
          ),
        ),
      ],
    );
  }
}