import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../routes.dart';
import '../widgets/custom_button.dart';
import 'package:artlens/widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/fake_search_bar.dart'; // Importar el nuevo widget

class HomeView extends StatefulWidget {
  static final HomeView _instance = HomeView._internal();

  HomeView._internal();

  factory HomeView() {
    return _instance;
  }

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  bool _hasConnection = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _hasConnection = connectivityResult[0] != ConnectivityResult.none;
    });

    Connectivity().onConnectivityChanged.listen((connectivityResult) {
      setState(() {
        _hasConnection = connectivityResult[0] != ConnectivityResult.none;
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        // No need to navigate if already on Home
      } else if (index == 1) {
        Navigator.pushNamed(
          context,
          Routes.camera,
        );
      } else if (index == 2) {
        Navigator.pushNamed(
          context,
          Routes.trending,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_hasConnection) {
      // Mostrar pantalla de error cuando no hay conexión
      return Scaffold(
        appBar: CustomAppBar(title: "No Connection", showProfileIcon: false, showBackArrow: false),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 100, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                "No Internet Connection",
                style: theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.error),
              ),
              const SizedBox(height: 8),
              Text(
                "Please check your connection and try again.",
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Pantalla principal cuando hay conexión
    return Scaffold(
      appBar: CustomAppBar(title: "HOME", showProfileIcon: true, showBackArrow: false),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RawScrollbar(
            thumbVisibility: true,
            thickness: 6.0,
            radius: const Radius.circular(15),
            thumbColor: theme.colorScheme.secondary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              physics: constraints.maxHeight < 600
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Welcome to ArtLens!",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: FakeSearchBar(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Museums in your city",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        label: "View all museums",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.museums,
                          );
                        },
                      ),
                      CustomButton(
                        label: "View Map",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.map,
                          );
                        },
                      ),
                      CustomButton(
                        label: "View Artists",
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.artists,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
