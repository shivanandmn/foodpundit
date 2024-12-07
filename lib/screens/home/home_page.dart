import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:foodpundit/screens/camera/camera_page.dart';
import 'package:foodpundit/screens/explore_page.dart';
import 'package:foodpundit/screens/history_page.dart';
import 'package:foodpundit/screens/profile_page.dart';
import 'package:foodpundit/screens/help_support_screen.dart';
import 'package:foodpundit/utils/responsive_builder.dart';
import 'package:foodpundit/utils/custom_page_transitions.dart';
import 'package:foodpundit/utils/network_utils.dart';
import 'package:foodpundit/widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:foodpundit/providers/app_auth_provider.dart';
import 'package:foodpundit/theme/app_colors.dart';
import 'package:camera/camera.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  late final List<Widget> _pages;
  final _auth = FirebaseAuth.instance;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    print('DEBUG: HomePage - Initializing');
    _initializeCamera();
    _selectedIndex = widget.initialIndex;

    // Check authentication state immediately
    final user = _auth.currentUser;
    if (user == null) {
      print('DEBUG: HomePage - No authenticated user, redirecting to sign in');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/signin');
      });
      return;
    }
    print('DEBUG: HomePage - User authenticated: ${user.email}');

    _pages = [
      const ExplorePage(),
      const HistoryPage(),
    ];
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      setState(() {
        _cameras = cameras;
      });
    } catch (e) {
      debugPrint('Error getting cameras: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      print('DEBUG: HomePage - User not authenticated in build');
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Food Pundit',
        actions: [
          Consumer<AppAuthProvider>(
            builder: (context, authProvider, _) {
              final userDetails = authProvider.userDetails;
              return IconButton(
                icon: userDetails?.photoURL != null
                    ? FutureBuilder<bool>(
                        future: NetworkUtils.hasInternetConnection(),
                        builder: (context, snapshot) {
                          final hasInternet = snapshot.data ?? false;

                          if (!hasInternet) {
                            return const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              radius: 16,
                              child: Icon(Icons.person_outline,
                                  color: Colors.white),
                            );
                          }

                          return CircleAvatar(
                            backgroundImage:
                                NetworkImage(userDetails!.photoURL!),
                            onBackgroundImageError: (exception, stackTrace) {
                              debugPrint(
                                  '❌ Error loading profile image: $exception');
                            },
                            radius: 16,
                          );
                        },
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.person_outline, color: Colors.white),
                        backgroundColor: AppColors.primary,
                        radius: 16,
                      ),
                onPressed: () async {
                  // Only fetch if we don't have the details or they're stale
                  final userDetails = await authProvider.fetchUserDetails();
                  if (context.mounted && userDetails != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          userDetails: userDetails,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: ResponsiveBuilder(
        builder: (context, sizingInfo) {
          if (sizingInfo.isTablet) {
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.selected,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(LineIcons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(LineIcons.history),
                      label: Text('History'),
                    ),
                  ],
                ),
                Expanded(child: _pages[_selectedIndex]),
              ],
            );
          }

          // Mobile layout
          return _pages[_selectedIndex];
        },
      ),
      floatingActionButton: ResponsiveBuilder(
        builder: (context, sizingInfo) {
          if (sizingInfo.isTablet) {
            return const SizedBox.shrink();
          }
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SizedBox(
              width: 58,
              height: 58,
              child: FloatingActionButton(
                onPressed: () async {
                  if (_cameras == null || _cameras!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No camera available')),
                    );
                    return;
                  }

                  final controller = CameraController(
                    _cameras!.first,
                    ResolutionPreset.high,
                    enableAudio: false,
                  );

                  // Get the position of the FAB
                  final RenderBox? renderBox =
                      context.findRenderObject() as RenderBox?;
                  final Offset fabPosition =
                      renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
                  final Size fabSize = renderBox?.size ?? Size.zero;

                  // Calculate the center of the FAB
                  final Offset centerOffset = Offset(
                    fabPosition.dx + (fabSize.width / 2),
                    fabPosition.dy + (fabSize.height / 2),
                  );

                  await Navigator.push(
                    context,
                    CircularRevealRoute(
                      page: CameraPage(
                        controller: controller,
                      ),
                      centerOffset: centerOffset,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.9),
                    ),
                  );

                  // Dispose the controller after returning from the camera page
                  controller.dispose();
                },
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: AppColors.primary,
                child:
                    const Icon(LineIcons.camera, size: 24, color: Colors.white),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: ResponsiveBuilder(
        builder: (context, sizingInfo) {
          if (sizingInfo.isTablet) {
            return const SizedBox.shrink();
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: NavigationBar(
                height: 65,
                elevation: 0,
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                backgroundColor: Colors.transparent,
                indicatorColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedIndex == 0
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LineIcons.home,
                        color: _selectedIndex == 0
                            ? AppColors.primary
                            : AppColors.getTextSecondary(context),
                        size: 24,
                      ),
                    ),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedIndex == 1
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LineIcons.history,
                        color: _selectedIndex == 1
                            ? AppColors.primary
                            : AppColors.getTextSecondary(context),
                        size: 24,
                      ),
                    ),
                    label: 'History',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
