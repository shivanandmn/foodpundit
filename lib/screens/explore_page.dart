import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/ui_constants.dart';
import 'profile_page.dart';
import '../widgets/shimmer_loading.dart';
import 'package:provider/provider.dart';
import 'package:foodpundit/providers/app_auth_provider.dart';
import '../widgets/profile_completion_card.dart'; // Import the ProfileCompletionCard widget
import 'package:foodpundit/models/user_details.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  UserDetails? _userDetails;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: UIConstants.durationXL,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    _userDetails = await authProvider.fetchUserDetails();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildHeader(context),
              _buildProfileCompletion(context),
              _buildExploreList(context),
              // _buildFooter(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, ${_userDetails?.displayName ?? 'User!'}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface
                          .withOpacity(UIConstants.opacityHigh),
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: UIConstants.spacingXS),
              Text(
                'Ready to discover what\'s in your food packet today?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface
                          .withOpacity(UIConstants.opacityMedium),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCompletion(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final userDetails = authProvider.userDetails;

    // If we don't have user details yet, show loading
    if (userDetails == null) {
      return const SliverToBoxAdapter(
        child: ShimmerLoading(),
      );
    }

    // Don't show the card if profile is 100% complete
    if (userDetails.profileCompletionPercentage >= 100) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingM),
        child: ProfileCompletionCard(
          userDetails: userDetails,
          onEditProfile: () async {
            // Only fetch if we don't have the details or they're stale
            final refreshedDetails = await authProvider.fetchUserDetails();
            if (context.mounted && refreshedDetails != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    userDetails: refreshedDetails,
                  ),
                ),
              );
            }
          },
          showEditButton: true,
        ),
      ),
    );
  }

  Widget _buildExploreList(BuildContext context) {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: ShimmerLoading(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(UIConstants.spacingM),
      sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(
            bottom: UIConstants.spacingM,
          ),
          child: _buildExploreCard(context),
        ),
        childCount: 2,
      )),
    );
  }

  Widget _buildExploreCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: UIConstants.cardElevation,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // TODO: Navigate to detail
        },
        child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Image.network(
                  'https://picsum.photos/800/450',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image_not_supported_outlined,
                    color: colorScheme.onSurface
                        .withOpacity(UIConstants.opacityHigh),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingXXL),
        child: Text(
          ' 2024 Food Pundit. All rights reserved.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    colorScheme.onSurface.withOpacity(UIConstants.opacityHigh),
              ),
        ),
      ),
    );
  }
}
