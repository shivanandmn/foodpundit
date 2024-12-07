import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/ui_constants.dart';
import '../utils/network_utils.dart';
import '../widgets/shimmer_loading.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';
import '../features/product_details/presentation/pages/product_details_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoading = true;
  final _productService = ProductService();
  final _authService = AuthService();
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final hasInternet = await NetworkUtils.hasInternetConnection();
    if (!hasInternet) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.signal_wifi_off, color: Colors.white),
                const SizedBox(width: UIConstants.spacingS),
                const Text('No internet connection'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      await _productService.initCache();
      final userDetails = await _authService.fetchUserDetails();
      if (userDetails != null && userDetails.product_history.isNotEmpty) {
        final products = await _productService
            .getProductsFromHistory(userDetails.product_history);
        if (mounted) {
          setState(() {
            _products = products
              ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Error loading history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _isLoading
          ? const ShimmerLoading()
          : _products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 48,
                        color: colorScheme.onSurface
                            .withOpacity(UIConstants.opacityMedium),
                      ),
                      const SizedBox(height: UIConstants.spacingM),
                      Text(
                        'No scanned products yet',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface
                                      .withOpacity(UIConstants.opacityHigh),
                                ),
                      ),
                      const SizedBox(height: UIConstants.spacingXS),
                      Text(
                        'Take a photo of a food product\'s \nback-label to get started!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface
                                  .withOpacity(UIConstants.opacityMedium),
                            ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(UIConstants.spacingM),
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    color: colorScheme.primary,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _products.length,
                      itemBuilder: (context, index) =>
                          _buildHistoryCard(context, _products[index]),
                    ),
                  ),
                ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, Product product) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingM),
      elevation: UIConstants.cardElevation,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsPage(product: product),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.spacingM),
          child: Row(
            children: [
              Container(
                width: UIConstants.shimmerAvatarSize,
                height: UIConstants.shimmerAvatarSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(UIConstants.radiusM),
                  color: colorScheme.surfaceTint
                      .withOpacity(UIConstants.opacityLow),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(UIConstants.radiusM),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.image_not_supported_outlined,
                      color: colorScheme.onSurface
                          .withOpacity(UIConstants.opacityHigh),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: UIConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface
                                .withOpacity(UIConstants.opacityHigh),
                          ),
                    ),
                    const SizedBox(height: UIConstants.spacingXS),
                    Row(
                      children: [
                        if (product.vegNonVegStatus != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UIConstants.spacingXS,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius:
                                  BorderRadius.circular(UIConstants.radiusS),
                            ),
                            child: Text(
                              product.vegNonVegStatus!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                            ),
                          ),
                        if (product.vegNonVegStatus != null)
                          const SizedBox(width: UIConstants.spacingS),
                        Text(
                          _getTimeAgo(product.scannedAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface
                                        .withOpacity(UIConstants.opacityMedium),
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface
                    .withOpacity(UIConstants.opacityMedium),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
