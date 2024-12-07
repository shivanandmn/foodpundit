import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/ui_constants.dart';

class UserAvatar extends StatelessWidget {
  final String? photoURL;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.photoURL,
    this.radius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget avatar;
    if (photoURL != null && photoURL!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.surfaceVariant,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: photoURL!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (context, url) => CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
            errorWidget: (context, url, error) => Icon(
              Icons.person_outline,
              size: radius * 1.2,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    } else {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.surfaceVariant,
        child: Icon(
          Icons.person_outline,
          size: radius * 1.2,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: avatar,
    );
  }
}
