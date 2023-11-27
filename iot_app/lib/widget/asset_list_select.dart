import 'package:flutter/material.dart';
import 'package:iot_app/model/asset.dart';
import 'package:iot_app/provider/log_provider.dart';

class AssetListSelectWidget extends StatefulWidget {
  final List<Asset> assets;
  final Null Function(String id) onSelectAssets;
  const AssetListSelectWidget({super.key, required this.assets, required this.onSelectAssets});

  @override
  AssetListSelectWidgetState createState() => AssetListSelectWidgetState();
}

class AssetListSelectWidgetState extends State<AssetListSelectWidget> {
  Asset? selectedAsset;

  @override
  Widget build(BuildContext context) {
    List<Asset> listAsset = widget.assets;

    return DropdownButton<Asset>(
      value: selectedAsset,
      onChanged: (Asset? newValue) {
        setState(() {
          selectedAsset = newValue;
        });
        // Call your callback function with the asset ID
        if (newValue != null) {
          // Perform actions when a new asset is selected
          widget.onSelectAssets(newValue.id);
          Log.print('Selected Asset: ${newValue.id}');
        }
      },
      items: listAsset.map((Asset asset) {
        return DropdownMenuItem<Asset>(
          value: asset,
          child: Text(asset.name),
        );
      }).toList(),
    );
  }
}
