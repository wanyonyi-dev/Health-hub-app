import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userId});
  final String userId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _menuController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _menuController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: Theme.of(context).copyWith(
          primaryColor: const Color(0xFF2C3E50),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2C3E50),
            secondary: const Color(0xFF3498DB),
            tertiary: const Color(0xFF2ECC71),
          ),
        ),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.grey[100],
          drawer: _buildDrawer(context),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildModernAppBar(context),
              _buildWelcomeMessage(context),
              _buildQuickActions(context),
              _buildMainServices(context),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context),
          floatingActionButton: _buildEmergencyFAB(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2C3E50),
              const Color(0xFF3498DB).withOpacity(0.9),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(LucideIcons.user, color: const Color(0xFF2C3E50), size: 40),
              ),
              accountName: const Text(
                'patient',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: const Text(
                'patient@example.com',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            _buildDrawerItem(LucideIcons.settings, 'Settings', () {
              Navigator.pushNamed(context, '/settings');
            }),
            _buildDrawerItem(LucideIcons.edit3, 'Edit Profile', () {
              _navigateToEditProfile(context);
            }),
            _buildDrawerItem(LucideIcons.helpCircle, 'Help & Support', () {
              Navigator.pushNamed(context, '/support');
            }),
            _buildDrawerItem(LucideIcons.shield, 'Privacy Policy', () {
              Navigator.pushNamed(context, '/privacy');
            }),
            const Divider(color: Colors.white30),
            _buildDrawerItem(LucideIcons.logOut, 'Sign Out', () {
              _showSignOutDialog(context);
            }, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red[300] : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red[300] : Colors.white,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF2C3E50),
      leading: IconButton(
        icon: const Icon(LucideIcons.menu),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Wellness Hub',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: 1.2,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2C3E50),
                const Color(0xFF3498DB).withOpacity(0.9),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -50,
                bottom: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.bell, color: Colors.white, size: 24),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        IconButton(
          icon: const Icon(LucideIcons.user, color: Colors.white, size: 24),
          onPressed: () => _navigateToProfile(context),
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'How are you feeling today?',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final quickActions = [
      QuickAction('Emergency', LucideIcons.alertCircle, '/emergencyContacts', const Color(0xFFE74C3C)),
      QuickAction('Talk Now', LucideIcons.video, '/accessTherapists', const Color(0xFF27AE60)),
      QuickAction('Book', LucideIcons.calendar, '/appointmentBooking', const Color(0xFF3498DB)),
      QuickAction('Mood', LucideIcons.smile, '/moodLogging', const Color(0xFFF39C12)),
      QuickAction('Journal', LucideIcons.bookOpen, '/journal', const Color(0xFF9B59B6)),
      QuickAction('Breathe', LucideIcons.wind, '/breathing', const Color(0xFF16A085)),
    ];

    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.chevronRight, size: 18),
                  label: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: quickActions.length,
                itemBuilder: (context, index) {
                  final action = quickActions[index];
                  return FadeTransition(
                    opacity: Tween<double>(begin: 0, end: 1).animate(
                      CurvedAnimation(
                        parent: _cardController,
                        curve: Interval(
                          index * 0.1,
                          0.6 + index * 0.1,
                          curve: Curves.easeOut,
                        ),
                      ),
                    ),
                    child: _buildQuickActionCard(
                      context,
                      action.title,
                      action.icon,
                      action.route,
                      action.color,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
      BuildContext context,
      String title,
      IconData icon,
      String route,
      Color color,
      ) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.9), color],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainServices(BuildContext context) {
    final services = [
      ServiceCard('Meditation', LucideIcons.brain, '/guidedMeditation', const Color(0xFF9B59B6)),
      ServiceCard('Hospitals', LucideIcons.building2, '/locateHospital', const Color(0xFF16A085)),
      ServiceCard('Calendar', LucideIcons.calendarDays, '/calendar', const Color(0xFF3498DB)),
      ServiceCard('Legal Help', LucideIcons.scale, '/legalSupport', const Color(0xFF795548)),
    ];

    return SliverPadding(
      padding: const EdgeInsets.all(20.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _cardController,
                  curve: Interval(
                    0.4 + index * 0.1,
                    0.8 + index * 0.1,
                    curve: Curves.easeOut,
                  ),
                ),
              ),
              child: _buildServiceCard(
                context,
                services[index].title,
                services[index].icon,
                services[index].route,
                services[index].color,
              ),
            );
          },
          childCount: services.length,
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon, String route, Color color) {
    return Card(
        elevation: 8,
        shadowColor: color.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
    borderRadius: BorderRadius.circular(24),
    child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.withOpacity(0.9), color],
      ),
      borderRadius: BorderRadius.circular(24),
    ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
        ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            switch (index) {
              case 1:
                Navigator.pushNamed(context, '/schedule');
                break;
              case 2:
                Navigator.pushNamed(context, '/chat');
                break;
              case 3:
                Navigator.pushNamed(context, '/settings');
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2C3E50),
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              activeIcon: Icon(LucideIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.calendar),
              activeIcon: Icon(LucideIcons.calendar),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.messageCircle),
              activeIcon: Icon(LucideIcons.messageCircle),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.settings),
              activeIcon: Icon(LucideIcons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyFAB() {
    return ScaleTransition(
      scale: _fadeAnimation,
      child: FloatingActionButton.extended(
        onPressed: () => _showEmergencyDialog(context),
        backgroundColor: const Color(0xFFE74C3C),
        elevation: 4,
        highlightElevation: 8,
        icon: const Icon(LucideIcons.alertCircle, color: Colors.white, size: 24),
        label: const Text(
          'Emergency',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(LucideIcons.alertCircle, color: const Color(0xFFE74C3C), size: 28),
              const SizedBox(width: 12),
              const Text(
                'Emergency Services',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Do you need immediate assistance?',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 12),
              Text(
                'Our emergency team is available 24/7.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(LucideIcons.phoneCall, size: 20),
              label: const Text(
                'Call Emergency',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/emergencyContacts');
              },
            ),
          ],
        );
      },
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(LucideIcons.logOut, color: const Color(0xFFE74C3C), size: 28),
              const SizedBox(width: 12),
              const Text('Sign Out'),
            ],
          ),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Sign Out'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<ProfileScreen>(
        builder: (context) => ProfileScreen(
          appBar: AppBar(
            title: const Text(
              'Profile',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF2C3E50),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.edit3),
                onPressed: () => _navigateToEditProfile(context),
              ),
            ],
          ),
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF2C3E50),
                    child: Icon(LucideIcons.user, size: 60, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Patient',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    // Add your edit profile navigation logic here
    Navigator.pushNamed(context, '/editProfile');
  }
}

// Data Models
class QuickAction {
  final String title;
  final IconData icon;
  final String route;
  final Color color;

  QuickAction(this.title, this.icon, this.route, this.color);
}

class ServiceCard {
  final String title;
  final IconData icon;
  final String route;
  final Color color;

  ServiceCard(this.title, this.icon, this.route, this.color);
}