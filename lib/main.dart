import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proplilly/providers/auth_provider.dart';
import 'package:proplilly/providers/user_provider.dart';
import 'package:proplilly/providers/property_provider.dart';
import 'package:proplilly/providers/admin_provider.dart';
import 'package:proplilly/providers/coordinator_provider.dart';
import 'package:proplilly/providers/subscription_provider.dart';
import 'package:proplilly/providers/remote_config.dart';
import 'package:proplilly/utils/router.dart';
import 'package:proplilly/utils/preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme/app_theme.dart';
import 'theme/auth_theme.dart';


@pragma('vm:enrty-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async{
  await Firebase.initializeApp();
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Prefs.init();
  runApp(const MyApp());
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  RemoteConfigServices remoteConfigServices = RemoteConfigServices();
  await remoteConfigServices.setupRemoteConfig();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

Future<void> requestNotificationPermission() async{
  var status = await Permission.notification.status;
  if(status.isDenied){
    status = await Permission.notification.request();
  }
  else if(status.isPermanentlyDenied){
     openAppSettings();
  }
}

 Future<void> setupFcm() async{
  String? token = await FirebaseMessaging.instance.getToken();
  log("Token---$token}");

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {

  },);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          openUrl(message);
  },);

  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if(initialMessage != null){
    openUrl(initialMessage);
  }

  FirebaseMessaging.instance.subscribeToTopic("proplilly_android");
 }

 Future<void> openUrl(RemoteMessage message) async{
  final url = message.data['notification_url'];
  final Uri finalUrl = Uri.parse(url);
  if(url.isNotEmpty){
    launchUrl(finalUrl,mode:LaunchMode.externalApplication);
  }
 }

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => CoordinatorProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: MaterialApp.router(
        title: 'PropLilly',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
            primary: AppColors.primary,
            secondary: AppColors.primaryLight,
          ),
          scaffoldBackgroundColor: AppColors.scaffoldLight,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: AppColors.primary.withOpacity(0.15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
