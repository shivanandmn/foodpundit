import 'package:flutter/material.dart';

class NoInternetDialog extends StatelessWidget {
  final String connectionType;

  const NoInternetDialog({
    Key? key,
    required this.connectionType,
  }) : super(key: key);

  static Future<bool> show(BuildContext context, String connectionType) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) =>
              NoInternetDialog(connectionType: connectionType),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width * 0.85,
          maxHeight: size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.signal_wifi_off,
                      color: Colors.red,
                      size: isSmallScreen ? 24 : 28,
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Flexible(
                      child: Text(
                        'No Internet Connection',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textScaleFactor: textScaleFactor,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Current network status: $connectionType',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.black87,
                    ),
                    textScaleFactor: textScaleFactor,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                Text(
                  'Please check your:',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textScaleFactor: textScaleFactor,
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Padding(
                  padding: EdgeInsets.only(left: isSmallScreen ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCheckItem(
                        '• WiFi or mobile data connection',
                        isSmallScreen,
                        textScaleFactor,
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 8),
                      _buildCheckItem(
                        '• Airplane mode',
                        isSmallScreen,
                        textScaleFactor,
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 8),
                      _buildCheckItem(
                        '• Router or mobile signal',
                        isSmallScreen,
                        textScaleFactor,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          textScaleFactor: textScaleFactor,
                        ),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 8 : 16),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16 : 24,
                            vertical: isSmallScreen ? 8 : 12,
                          ),
                        ),
                        child: Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          textScaleFactor: textScaleFactor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(
      String text, bool isSmallScreen, double textScaleFactor) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isSmallScreen ? 14 : 16,
        color: Colors.black87,
      ),
      textScaleFactor: textScaleFactor,
    );
  }
}
