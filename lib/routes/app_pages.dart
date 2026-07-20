import 'package:get/get.dart';
import 'package:rambaa/views/screens/auth/forgot_password_screen.dart';
import 'package:rambaa/views/screens/client/appointments/appointment_screen.dart';
import 'package:rambaa/views/screens/client/booking/booking_screen.dart';
import 'package:rambaa/views/screens/client/booking/booking_success_screen.dart';
import 'package:rambaa/views/screens/client/booking/booking_summary_screen.dart';
import 'package:rambaa/views/screens/client/booking/book_now_screen.dart';
import 'package:rambaa/views/screens/client/caregivers/caregiver_list_screen.dart';
import 'package:rambaa/views/screens/client/dashboard/patient_dashboard_screen.dart';
import 'package:rambaa/views/screens/client/messages/ai_chat_screen.dart';
import 'package:rambaa/controllers/payment_controller.dart';
import 'package:rambaa/views/screens/client/payments/invoice_screen.dart';
import 'package:rambaa/views/screens/client/payments/payment_screen.dart';
import 'package:rambaa/views/screens/client/payments/payment_success_screen.dart';
import 'package:rambaa/views/screens/client/providers/provider_list_screen.dart';
import 'package:rambaa/views/screens/client/providers/provider_profile_screen.dart';
import 'package:rambaa/views/screens/client/transactions/transaction_history_screen.dart';
import 'package:rambaa/views/screens/profile/notifications/notification_screen.dart';
import 'package:rambaa/views/screens/onboarding/intro_slider_screen.dart';
import 'package:rambaa/views/screens/auth/login_screen.dart';
import 'package:rambaa/views/screens/provider/provider_dashboard_screen.dart';
import 'package:rambaa/views/screens/provider/provider_profile/provider_edit_profile_screen.dart';
import 'package:rambaa/views/screens/client/patients_profile/patient_edit_profile_screen.dart';
import 'package:rambaa/views/screens/provider/provider_payments_screens/provider_earnings_history_screen.dart';
import 'package:rambaa/views/screens/provider/provider_patient_screens/provider_edit_patient_screen.dart';
import 'package:rambaa/views/screens/provider/provider_patient_screens/provider_patient_detail_screen.dart';
import 'package:rambaa/views/screens/provider/provider_payments_screens/provider_withdraw_screen.dart';
import 'package:rambaa/views/screens/shared/chat_screen.dart';
import '../views/screens/shared/video_call_screen.dart';
import '../views/screens/shared/audio_call_screen.dart';
import '../views/screens/shared/incoming_call_screen.dart';
import '../views/screens/shared/help_support_screen.dart';
import '../views/screens/shared/privacy_security_screen.dart';
import '../views/screens/profile/settings/settings_screen.dart';
import '../views/screens/auth/otp_screen.dart';
import '../views/screens/auth/role_selection_screen.dart';
import '../views/screens/auth/signup_screen.dart';
import '../views/screens/caregiver/caregiver_messages_screen.dart';
import '../views/screens/caregiver/clients/caregiver_client_detail_screen.dart';
import '../views/screens/caregiver/dashboard/caregiver_dashboard_screen.dart';
import '../views/screens/caregiver/profile/caregiver_edit_profile_screen.dart';
import '../views/screens/caregiver/earnings/caregiver_earnings_history_screen.dart';
import '../views/screens/caregiver/finance/caregiver_withdraw_screen.dart';
import '../views/screens/onboarding/language_screen.dart';
import '../views/screens/onboarding/splash_screen.dart';
import '../views/screens/onboarding/welcome_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.welcome, page: () => const WelcomeScreen()),
    GetPage(name: AppRoutes.language, page: () => const LanguageScreen()),
    GetPage(name: AppRoutes.intro, page: () => const IntroSliderScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.signup, page: () => const SignupScreen()),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(name: AppRoutes.otp, page: () => const OtpVerificationScreen()),
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionScreen(),
    ),
    //Patient
    GetPage(
      name: AppRoutes.patientDashboard,
      page: () => const PatientDashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.providerList,
      page: () => const ProviderListScreen(),
    ),
    GetPage(
      name: AppRoutes.caregiverList,
      page: () => const CaregiverListScreen(),
    ),
    GetPage(
      name: AppRoutes.bookingSummary,
      page: () => const BookingSummaryScreen(),
    ),
    GetPage(
      name: AppRoutes.bookingSuccess,
      page: () => const BookingSuccessScreen(),
    ),
    GetPage(
      name: AppRoutes.payment,
      page: () => const PaymentScreen(),
      binding: BindingsBuilder(() {
        if (Get.isRegistered<PaymentController>()) {
          Get.delete<PaymentController>(force: true);
        }
        Get.put(PaymentController());
      }),
    ),
    GetPage(
      name: AppRoutes.appointments,
      page: () => const AppointmentScreen(),
    ),
    GetPage(name: AppRoutes.booking, page: () => const BookingScreen()),
    GetPage(name: AppRoutes.bookAppointment, page: () => const BookNowScreen()),
    GetPage(
      name: AppRoutes.paymentSuccess,
      page: () => const PaymentSuccessScreen(),
    ),
    GetPage(name: AppRoutes.invoice, page: () => const InvoiceScreen()),
    GetPage(
      name: AppRoutes.transactionHistory,
      page: () => const TransactionHistoryScreen(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => ChatScreen(conversation: Get.arguments),
    ),
    GetPage(
      name: AppRoutes.aiChat,
      page: () => AiChatScreen(conversation: Get.arguments),
    ),
    GetPage(
      name: AppRoutes.notification,
      page: () => const NotificationsScreen(),
    ),
    GetPage(name: AppRoutes.caregiverDashboard,page: ()=> const CaregiverDashboardScreen()),
    GetPage(name: AppRoutes.caregiverMessages, page: () => const CaregiverMessagesScreen()),
    GetPage(name: AppRoutes.caregiverEditProfile, page: () => const CaregiverEditProfileScreen()),
    GetPage(name: AppRoutes.caregiverClientDetail, page: () => const CaregiverClientDetailScreen()),
    GetPage(name: AppRoutes.caregiverWithdraw, page: () => const CaregiverWithdrawScreen()),
    GetPage(name: AppRoutes.caregiverEarningsHistory, page: () => const CaregiverEarningsHistoryScreen()),
    GetPage(name: AppRoutes.providerDashboard,page: ()=> const ProviderDashboardScreen()),
    GetPage(name: AppRoutes.providerProfile, page: () => const ProviderProfileScreen()),
    GetPage(name: AppRoutes.providerEditProfile, page: () => const ProviderEditProfileScreen()),
    GetPage(name: AppRoutes.patientEditProfile, page: () => const PatientEditProfileScreen()),
    GetPage(name: AppRoutes.providerPatientDetail, page: () => const ProviderPatientDetailScreen()),
    GetPage(name: AppRoutes.providerEditPatient, page: () => const ProviderEditPatientScreen()),
    GetPage(name: AppRoutes.providerWithdraw, page: () => const ProviderWithdrawScreen()),
    GetPage(name: AppRoutes.providerEarningsHistory, page: () => const ProviderEarningsHistoryScreen()),
    GetPage(
      name: AppRoutes.videoCall,
      page: () {
        final a = (Get.arguments ?? <String, dynamic>{}) as Map<String, dynamic>;
        return VideoCallScreen(
          roomId: a['roomId'] ?? '',
          userId: a['userId'] ?? '',
          userName: a['userName'] ?? '',
          calleeName: a['calleeName'] as String?,
          remoteUserId: a['remoteUserId'] ?? '',
          isIncoming: a['isIncoming'] ?? false,
          appointmentId: a['appointmentId'] as String?,
        );
      },
    ),
    GetPage(
      name: AppRoutes.audioCall,
      page: () {
        final a = (Get.arguments ?? <String, dynamic>{}) as Map<String, dynamic>;
        return AudioCallScreen(
          roomId: a['roomId'] ?? '',
          userId: a['userId'] ?? '',
          userName: a['userName'] ?? '',
          calleeName: a['calleeName'] as String?,
          remoteUserId: a['remoteUserId'] ?? '',
          isIncoming: a['isIncoming'] ?? false,
          appointmentId: a['appointmentId'] as String?,
        );
      },
    ),
    GetPage(
      name: AppRoutes.incomingCall,
      page: () {
        final a = (Get.arguments ?? <String, dynamic>{}) as Map<String, dynamic>;
        return IncomingCallScreen(
          callId: a['callId'] ?? '',
          roomId: a['roomId'] ?? '',
          userId: a['userId'] ?? '',
          userName: a['userName'] ?? '',
          remoteUserId: a['remoteUserId'] ?? '',
          remoteUserName: a['remoteUserName'] ?? '',
          callType: a['callType'] ?? 'video',
        );
      },
    ),
    GetPage(name: AppRoutes.helpSupport, page: () => const HelpSupportScreen()),
    GetPage(
        name: AppRoutes.privacySecurity,
        page: () => const PrivacySecurityScreen()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
  ];
}
