import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'services/location_service.dart';
import 'services/permission_service.dart';
import 'viewmodels/location_viewmodel.dart';
import 'views/location_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final locationService = LocationService();
    final permissionService = PermissionService();

    return MultiProvider(
      providers: [
        // Provide location service to entire app
        Provider<LocationService>.value(value: locationService),
        // Provide permission service to entire app
        Provider<PermissionService>.value(value: permissionService),
        // Location ViewModel with all business logic
        ChangeNotifierProvider(
          create: (_) => LocationViewModel(
            locationService: locationService,
            permissionService: permissionService,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const LocationScreen(),
      ),
    );
  }
}
