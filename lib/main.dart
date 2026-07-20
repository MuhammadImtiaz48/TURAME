import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rambaa/controllers/message_controller.dart';
import 'package:rambaa/firebase_options.dart';
import 'package:rambaa/routes/app_pages.dart';
import 'package:rambaa/routes/app_routes.dart';
import 'package:rambaa/utils/app_translation.dart';

import 'constants/app_theme.dart';
import 'controllers/language_controller.dart';
import 'controllers/auth_controllers/auth_controller.dart';
import 'controllers/provider_controller/provider_controller.dart';
import 'controllers/provider_controller/provider_dashboard_controller.dart';
import 'controllers/provider_controller/provider_profile_controller.dart';
import 'controllers/caregiver_controllers/caregiver_controller.dart';
import 'controllers/caregiver_controllers/caregiver_dashboard_controller.dart';
import 'controllers/patient_controllers/patient_profile_controller.dart';
import 'controllers/appointment_controller.dart';
import 'controllers/health_controller.dart';
import 'controllers/payment_controller.dart';
import 'controllers/health_alert_controller.dart';
import 'services/call_service.dart';
import 'services/stripe_service.dart';
import 'services/zego_service.dart';
import 'services/notification_service.dart';
import 'services/apple_health_service.dart';
import 'services/wearable_health_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(LanguageController());
  Get.put(AuthController());

  Get.put<ProviderController>(ProviderController(), permanent: true);
  Get.lazyPut<ProviderDashboardController>(
    () => ProviderDashboardController(),
    fenix: true,
  );
  Get.lazyPut<ProviderProfileController>(
    () => ProviderProfileController(),
    fenix: true,
  );
  Get.lazyPut<CaregiverController>(
    () => CaregiverController(),
    fenix: true,
  );
  Get.lazyPut<CaregiverDashboardController>(
    () => CaregiverDashboardController(),
    fenix: true,
  );
  Get.lazyPut<PatientProfileController>(
    () => PatientProfileController(),
    fenix: true,
  );
  Get.lazyPut<AppointmentController>(
    () => AppointmentController(),
    fenix: true,
  );
  Get.lazyPut<HealthController>(() => HealthController(), fenix: true);
  Get.lazyPut<PaymentController>(() => PaymentController(), fenix: true);
  Get.lazyPut<HealthAlertController>(() => HealthAlertController());
  Get.lazyPut<MessagesController>(() => MessagesController(), fenix: true);
  Get.put<ZegoService>(ZegoService(), permanent: true);
  Get.put<CallService>(CallService(), permanent: true);
  Get.put<StripeService>(StripeService(), permanent: true);
  Get.put<WearableHealthService>(WearableHealthService(), permanent: true);
  Get.put<AppleHealthService>(AppleHealthService(), permanent: true);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Stripe Payment Sheet requires publishable key before first use.
  await StripeService.to.init();
  await WearableHealthService.to.init();
  await AppleHealthService.to.init();

  runApp(const MyApp());

  NotificationService.instance.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          title: 'TURAME',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: AppRoutes.welcome,

          getPages: AppPages.pages,
        );
      },
    );
  }
}
