import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:foodpundit/services/network_service.dart';
import 'package:provider/provider.dart';

class NetworkAwareImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const NetworkAwareImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, networkService, child) {
        if (!networkService.hasConnection) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.signal_wifi_off, color: Colors.grey),
            ),
          );
        }

        return CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit ?? BoxFit.cover,
          placeholder: (context, url) =>
              placeholder ??
              Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          errorWidget: (context, url, error) =>
              errorWidget ??
              Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.error_outline, color: Colors.red),
                ),
              ),
        );
      },
    );
  }
}
