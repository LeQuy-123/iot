import 'package:flutter/material.dart';
import 'package:iot_app/firebase_messaging.dart';
import 'package:iot_app/model/asset.dart';
import 'package:iot_app/provider/log_provider.dart';
import 'package:iot_app/widget/custom_date_picker.dart';

class AssetListWidget extends StatefulWidget {
  final List<Asset> assets;

  const AssetListWidget({super.key, required this.assets});

  @override
  AssetListWidgetState createState() => AssetListWidgetState();
}

class AssetListWidgetState extends State<AssetListWidget> {
  List<bool> isAssetToggled = List.generate(3, (index) => false);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      itemCount: widget.assets.length,
      shrinkWrap: true,
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Divider(),
      ),
      itemBuilder: (context, index) {
        Asset asset = widget.assets[index];
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(asset.name),
                  Switch(
                    value: isAssetToggled[index],
                    onChanged: (value) async {
                      setState(() {
                        isAssetToggled[index] = value;
                      });
                      // Call your callback function with the asset ID
                      if (value) {
                        await FirebaseMessagingService()
                            .subscribeToTopic(asset.id.toString());
                        // Perform actions when the toggle is ON
                        Log.print('Asset ${asset.id} is toggled ON');
                      } else {
                        await FirebaseMessagingService()
                            .unsubscribeFromTopic(asset.id.toString());
                        // Perform actions when the toggle is OFF
                        Log.print('Asset ${asset.id} is toggled OFF');
                      }
                    },
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type: ${asset.type}'),
                  // const CustomDateTimePicker(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
