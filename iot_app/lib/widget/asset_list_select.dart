import 'package:flutter/material.dart';
import 'package:iot_app/model/asset.dart';
import 'package:iot_app/provider/log_provider.dart';

class AssetListSelectWidget extends StatefulWidget {
  final List<Asset> assets;

  const AssetListSelectWidget({super.key, required this.assets, required Null Function(String id) onSelectAssets});

  @override
  AssetListSelectWidgetState createState() => AssetListSelectWidgetState();
}

class AssetListSelectWidgetState extends State<AssetListSelectWidget> {
  Asset? selectedAsset;
  DateTime selectedDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Asset>(
      value: selectedAsset,
      onChanged: (Asset? newValue) {
        setState(() {
          selectedAsset = newValue;
        });
        // Call your callback function with the asset ID
        if (newValue != null) {
          // Perform actions when a new asset is selected
          Log.print('Selected Asset: ${newValue.id}');
        }
      },
      items: widget.assets.map((Asset asset) {
        return DropdownMenuItem<Asset>(
          value: asset,
          child: Text(asset.name),
        );
      }).toList(),
    );
  }
}
