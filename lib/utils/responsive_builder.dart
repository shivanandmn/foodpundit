import 'package:flutter/material.dart';

enum DeviceScreenType {
  mobile,
  tablet,
  desktop,
}

class SizingInformation {
  final DeviceScreenType deviceScreenType;
  final Size screenSize;
  final Size localWidgetSize;
  final Orientation orientation;

  SizingInformation({
    required this.deviceScreenType,
    required this.screenSize,
    required this.localWidgetSize,
    required this.orientation,
  });

  static SizingInformation of(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    
    // Get the sizing information from the nearest ResponsiveBuilder
    final responsive = context.findAncestorWidgetOfExactType<ResponsiveBuilder>();
    if (responsive == null) {
      return SizingInformation(
        deviceScreenType: _getDeviceType(size.width),
        screenSize: size,
        localWidgetSize: size,
        orientation: mediaQuery.orientation,
      );
    }
    
    final box = context.findRenderObject() as RenderBox?;
    final localWidgetSize = box?.size ?? size;
    
    return SizingInformation(
      deviceScreenType: _getDeviceType(size.width),
      screenSize: size,
      localWidgetSize: localWidgetSize,
      orientation: mediaQuery.orientation,
    );
  }

  static DeviceScreenType _getDeviceType(double width) {
    if (width >= 1200) return DeviceScreenType.desktop;
    if (width >= 600) return DeviceScreenType.tablet;
    return DeviceScreenType.mobile;
  }

  bool get isMobile => deviceScreenType == DeviceScreenType.mobile;
  bool get isTablet => deviceScreenType == DeviceScreenType.tablet;
  bool get isDesktop => deviceScreenType == DeviceScreenType.desktop;
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    SizingInformation sizingInformation,
  ) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery.of(context);
        var sizingInformation = SizingInformation(
          deviceScreenType: SizingInformation._getDeviceType(mediaQuery.size.width),
          screenSize: mediaQuery.size,
          localWidgetSize: Size(constraints.maxWidth, constraints.maxHeight),
          orientation: mediaQuery.orientation,
        );
        return builder(context, sizingInformation);
      },
    );
  }
}
