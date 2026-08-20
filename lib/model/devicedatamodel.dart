class DeviceData {
  int? groupID;
  int? deviceIndexInGroup;
  dynamic deviceData;
  String? groupTitle;
  int? osmCubitIndex; // Added to store OsmaddressCubit index

  DeviceData({
    this.groupID,
    this.deviceIndexInGroup,
    this.deviceData,
    this.groupTitle,
    this.osmCubitIndex,
  });
}