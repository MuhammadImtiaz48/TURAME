import 'package:get/get.dart';
import '../../models/support_ticket_model.dart';
import '../../services/firebase_service.dart';
import 'auth_controllers/auth_controller.dart';

class HelpSupportController extends GetxController {
  final AuthController _authCtrl = Get.find<AuthController>();

  final RxList<SupportTicketModel> tickets = <SupportTicketModel>[].obs;
  final Rx<SupportTicketModel?> selectedTicket = Rx<SupportTicketModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  Future<void> loadTickets() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final uid = _authCtrl.user.value?.id ?? '';
      if (uid.isEmpty) return;

      final data = await FirebaseService.getSupportTicketsByUser(uid);
      tickets.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> createTicket({
    required String subject,
    required String description,
    required SupportTicketCategory category,
    String priority = 'medium',
  }) async {
    try {
      final uid = _authCtrl.user.value?.id;
      if (uid == null || uid.isEmpty) return null;

      final ticket = SupportTicketModel(
        id: '',
        userId: uid,
        subject: subject,
        description: description,
        category: category,
        priority: priority,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final ticketId = await FirebaseService.createSupportTicket(ticket);
      final createdTicket = ticket.copyWith(id: ticketId);
      tickets.insert(0, createdTicket);
      return ticketId;
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    }
  }

  Future<SupportTicketModel?> getTicket(String ticketId) async {
    try {
      final ticket = await FirebaseService.getSupportTicketById(ticketId);
      if (ticket != null) {
        selectedTicket.value = ticket;
      }
      return ticket;
    } catch (e) {
      errorMessage.value = e.toString();
      return null;
    }
  }

  Future<bool> closeTicket(String ticketId) async {
    try {
      await FirebaseService.updateSupportTicketStatus(
        ticketId,
        SupportTicketStatus.closed,
      );

      final idx = tickets.indexWhere((t) => t.id == ticketId);
      if (idx >= 0) {
        tickets[idx] = tickets[idx].copyWith(
          status: SupportTicketStatus.closed,
          updatedAt: DateTime.now(),
        );
      }

      if (selectedTicket.value?.id == ticketId) {
        selectedTicket.value = selectedTicket.value?.copyWith(
          status: SupportTicketStatus.closed,
          updatedAt: DateTime.now(),
        );
      }

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> sendReply(String ticketId, String replyText) async {
    try {
      final response = SupportTicketResponse(
        text: replyText,
        senderRole: 'user',
        createdAt: DateTime.now(),
      );

      await FirebaseService.addSupportTicketResponse(ticketId, response);

      final idx = tickets.indexWhere((t) => t.id == ticketId);
      if (idx >= 0) {
        final currentResponses = List<SupportTicketResponse>.from(
          tickets[idx].responses,
        );
        currentResponses.add(response);
        tickets[idx] = tickets[idx].copyWith(
          responses: currentResponses,
          updatedAt: DateTime.now(),
          status: SupportTicketStatus.inProgress,
        );
      }

      if (selectedTicket.value?.id == ticketId) {
        final currentResponses = List<SupportTicketResponse>.from(
          selectedTicket.value!.responses,
        );
        currentResponses.add(response);
        selectedTicket.value = selectedTicket.value?.copyWith(
          responses: currentResponses,
          updatedAt: DateTime.now(),
          status: SupportTicketStatus.inProgress,
        );
      }

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    }
  }
}
