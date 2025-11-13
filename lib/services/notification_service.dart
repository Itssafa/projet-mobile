import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_model.dart';
import '../models/vaccination.dart';
import '../models/appointment.dart';
import '../models/feeding.dart';
import '../models/animal.dart';
import 'ai_prediction_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    // Ne pas initialiser sur web
    if (kIsWeb) {
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Gérer le tap sur la notification
    // Peut naviguer vers l'écran approprié
  }

  // Planifier une notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    bool showWhenAppClosed = true,
  }) async {
    // Ne pas planifier sur web
    if (kIsWeb) {
      return;
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Notifications',
          channelDescription: 'Notifications pour le suivi des animaux',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          // Permet d'afficher même quand l'app est fermée
          ongoing: false,
          autoCancel: true,
          // Notification persistante
          visibility: NotificationVisibility.public,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Planifier une notification de vaccination
  Future<NotificationModel?> scheduleVaccinationReminder(
    Vaccination vaccination,
    Animal animal,
  ) async {
    if (vaccination.nextVaccineDate == null || vaccination.isCompleted) {
      return null;
    }

    // Créer une DateTime avec l'heure spécifiée (par défaut 9h00 si pas d'heure)
    final vaccineDateTime = DateTime(
      vaccination.nextVaccineDate!.year,
      vaccination.nextVaccineDate!.month,
      vaccination.nextVaccineDate!.day,
      vaccination.nextVaccineDate!.hour > 0 ? vaccination.nextVaccineDate!.hour : 9,
      vaccination.nextVaccineDate!.minute > 0 ? vaccination.nextVaccineDate!.minute : 0,
    );

    NotificationModel? notification;

    // Notification 2 heures avant
    final twoHoursBefore = vaccineDateTime.subtract(const Duration(hours: 2));
    if (twoHoursBefore.isAfter(DateTime.now())) {
      final twoHoursNotification = NotificationModel(
        type: NotificationType.vaccination,
        animalId: vaccination.animalId,
        relatedId: vaccination.id,
        title: 'Rappel de vaccination dans 2 heures',
        message: '${animal.name} doit recevoir son vaccin ${vaccination.vaccineType} le ${_formatDateTime(vaccineDateTime)}.',
        scheduledDate: twoHoursBefore,
      );

      await scheduleNotification(
        id: (vaccination.id ?? 0) * 100 + 1,
        title: twoHoursNotification.title,
        body: twoHoursNotification.message,
        scheduledDate: twoHoursBefore,
      );

      notification = twoHoursNotification;
    }

    // Notification la veille (si plus de 2 heures avant)
    final reminderDate = vaccineDateTime.subtract(const Duration(days: 1));
    if (reminderDate.isAfter(DateTime.now()) && reminderDate.isAfter(twoHoursBefore)) {
      final dayBeforeNotification = NotificationModel(
        type: NotificationType.vaccination,
        animalId: vaccination.animalId,
        relatedId: vaccination.id,
        title: 'Rappel de vaccination demain',
        message: '${animal.name} doit recevoir son vaccin ${vaccination.vaccineType} demain le ${_formatDateTime(vaccineDateTime)}.',
        scheduledDate: reminderDate,
      );

      await scheduleNotification(
        id: (vaccination.id ?? 0) * 100 + 0,
        title: dayBeforeNotification.title,
        body: dayBeforeNotification.message,
        scheduledDate: reminderDate,
      );
    }

    // Notification le jour même à l'heure exacte
    if (vaccineDateTime.isAfter(DateTime.now())) {
      final dayNotification = NotificationModel(
        type: NotificationType.vaccination,
        animalId: vaccination.animalId,
        relatedId: vaccination.id,
        title: 'Vaccination maintenant',
        message: 'C\'est le moment du vaccin ${vaccination.vaccineType} pour ${animal.name} (${_formatDateTime(vaccineDateTime)}).',
        scheduledDate: vaccineDateTime,
      );

      await scheduleNotification(
        id: (vaccination.id ?? 0) * 100 + 2,
        title: dayNotification.title,
        body: dayNotification.message,
        scheduledDate: vaccineDateTime,
      );

      // Retourner la notification la plus proche
      if (notification == null || vaccineDateTime.isBefore(twoHoursBefore)) {
        notification = dayNotification;
      }
    }

    return notification;
  }

  // Planifier une notification de rendez-vous
  Future<NotificationModel?> scheduleAppointmentReminder(
    Appointment appointment,
    Animal animal,
  ) async {
    NotificationModel? notification;

    // Notification 2 heures avant
    final twoHoursBefore = appointment.dateTime.subtract(const Duration(hours: 2));
    if (twoHoursBefore.isAfter(DateTime.now())) {
      final twoHoursNotification = NotificationModel(
        type: NotificationType.appointment,
        animalId: appointment.animalId,
        relatedId: appointment.id,
        title: 'Rendez-vous dans 2 heures',
        message: 'Rendez-vous ${appointment.appointmentType} pour ${animal.name} prévu le ${_formatDateTime(appointment.dateTime)}.',
        scheduledDate: twoHoursBefore,
      );

      await scheduleNotification(
        id: (appointment.id ?? 0) * 100 + 1,
        title: twoHoursNotification.title,
        body: twoHoursNotification.message,
        scheduledDate: twoHoursBefore,
      );

      notification = twoHoursNotification;
    }

    // Notification la veille (si plus de 2 heures avant)
    final reminderDate = appointment.dateTime.subtract(const Duration(days: 1));
    if (reminderDate.isAfter(DateTime.now()) && reminderDate.isAfter(twoHoursBefore)) {
      final dayBeforeNotification = NotificationModel(
        type: NotificationType.appointment,
        animalId: appointment.animalId,
        relatedId: appointment.id,
        title: 'Rendez-vous médical demain',
        message: 'Rendez-vous ${appointment.appointmentType} pour ${animal.name} prévu demain le ${_formatDateTime(appointment.dateTime)}.',
        scheduledDate: reminderDate,
      );

      await scheduleNotification(
        id: (appointment.id ?? 0) * 100 + 0,
        title: dayBeforeNotification.title,
        body: dayBeforeNotification.message,
        scheduledDate: reminderDate,
      );
    }

    // Notification à l'heure exacte
    if (appointment.dateTime.isAfter(DateTime.now())) {
      final hourNotification = NotificationModel(
        type: NotificationType.appointment,
        animalId: appointment.animalId,
        relatedId: appointment.id,
        title: 'Rendez-vous maintenant',
        message: 'C\'est l\'heure du rendez-vous ${appointment.appointmentType} pour ${animal.name} (${_formatDateTime(appointment.dateTime)}).',
        scheduledDate: appointment.dateTime,
      );

      await scheduleNotification(
        id: (appointment.id ?? 0) * 100 + 2,
        title: hourNotification.title,
        body: hourNotification.message,
        scheduledDate: appointment.dateTime,
      );

      // Retourner la notification la plus proche
      if (notification == null || appointment.dateTime.isBefore(twoHoursBefore)) {
        notification = hourNotification;
      }
    }

    return notification;
  }

  // Planifier des notifications de repas
  Future<List<NotificationModel>> scheduleFeedingReminders(
    Feeding feeding,
    Animal animal,
  ) async {
    final List<NotificationModel> notifications = [];

    for (var mealTime in feeding.mealTimes) {
      final timeParts = mealTime.split(':');
      if (timeParts.length != 2) continue;

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);
      if (hour == null || minute == null) continue;

      // Planifier pour aujourd'hui et les 30 jours suivants
      for (int dayOffset = 0; dayOffset < 30; dayOffset++) {
        final mealDateTime = DateTime.now()
            .add(Duration(days: dayOffset))
            .copyWith(hour: hour, minute: minute, second: 0);

        if (mealDateTime.isAfter(DateTime.now())) {
          final mealName = hour < 12 ? 'petit-déjeuner' : hour < 18 ? 'déjeuner' : 'dîner';
          
          // Notification 2 heures avant le repas
          final twoHoursBefore = mealDateTime.subtract(const Duration(hours: 2));
          if (twoHoursBefore.isAfter(DateTime.now())) {
            final reminderNotification = NotificationModel(
              type: NotificationType.feeding,
              animalId: feeding.animalId,
              relatedId: feeding.id,
              title: 'Rappel de repas dans 2 heures',
              message: 'Rappel : $mealName de ${animal.name} (${feeding.foodType}) prévu à ${_formatTime(mealDateTime)}.',
              scheduledDate: twoHoursBefore,
            );

            notifications.add(reminderNotification);
            await scheduleNotification(
              id: (feeding.id ?? 0) * 10000 + dayOffset * 100 + hour * 60 + minute + 1,
              title: reminderNotification.title,
              body: reminderNotification.message,
              scheduledDate: twoHoursBefore,
            );
          }

          // Notification à l'heure exacte du repas
          final mealNotification = NotificationModel(
            type: NotificationType.feeding,
            animalId: feeding.animalId,
            relatedId: feeding.id,
            title: 'Heure du repas',
            message: 'C\'est l\'heure du $mealName de ${animal.name} (${feeding.foodType}) - ${_formatTime(mealDateTime)}.',
            scheduledDate: mealDateTime,
          );

          notifications.add(mealNotification);
          await scheduleNotification(
            id: (feeding.id ?? 0) * 10000 + dayOffset * 100 + hour * 60 + minute,
            title: mealNotification.title,
            body: mealNotification.message,
            scheduledDate: mealDateTime,
          );
        }
      }
    }

    return notifications;
  }

  // Planifier une alerte de stock avec prédiction IA
  Future<NotificationModel?> scheduleStockAlert(
    Feeding feeding,
    Animal animal,
  ) async {
    final daysUntilStockout = AIPredictionService.predictStockout(feeding);
    
    // Générer une alerte si le stock sera épuisé dans 3 jours ou moins
    if (daysUntilStockout <= 3) {
      final notification = NotificationModel(
        type: NotificationType.stockAlert,
        animalId: feeding.animalId,
        relatedId: feeding.id,
        title: 'Stock faible',
        message: 'Stock de ${feeding.foodType} pour ${animal.name} épuisé dans $daysUntilStockout ${daysUntilStockout == 1 ? 'jour' : 'jours'}. Prévoir réapprovisionnement.',
        scheduledDate: DateTime.now(),
      );

      await scheduleNotification(
        id: (feeding.id ?? 0) * 100 + 99,
        title: notification.title,
        body: notification.message,
        scheduledDate: DateTime.now(),
      );

      return notification;
    }

    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Formater date et heure complètes
  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} à ${_formatTime(date)}';
  }

  // Notification : Vaccin administré
  Future<NotificationModel> notifyVaccinationCompleted(
    Vaccination vaccination,
    Animal animal,
  ) async {
    final notification = NotificationModel(
      type: NotificationType.vaccination,
      animalId: vaccination.animalId,
      relatedId: vaccination.id,
      title: 'Vaccin administré',
      message: 'Vaccin administré pour ${animal.name} – mise à jour du carnet de santé effectuée.',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    await scheduleNotification(
      id: (vaccination.id ?? 0) * 100 + 3,
      title: notification.title,
      body: notification.message,
      scheduledDate: DateTime.now(),
    );

    return notification;
  }

  // Notification : Rendez-vous complété
  Future<NotificationModel> notifyAppointmentCompleted(
    Appointment appointment,
    Animal animal,
  ) async {
    final notification = NotificationModel(
      type: NotificationType.appointment,
      animalId: appointment.animalId,
      relatedId: appointment.id,
      title: 'Consultation terminée',
      message: '${animal.name} a été consulté. Résumé disponible dans l\'historique médical.',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    await scheduleNotification(
      id: (appointment.id ?? 0) * 100 + 3,
      title: notification.title,
      body: notification.message,
      scheduledDate: DateTime.now(),
    );

    return notification;
  }

  // Notification : Nouveau régime enregistré
  Future<NotificationModel> notifyFeedingUpdated(
    Feeding feeding,
    Animal animal,
    String oldFoodType,
  ) async {
    final notification = NotificationModel(
      type: NotificationType.feeding,
      animalId: feeding.animalId,
      relatedId: feeding.id,
      title: 'Nouveau régime enregistré',
      message: 'Nouveau régime enregistré pour ${animal.name}: ${feeding.foodType}.',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    // Envoyer notification immédiate
    if (kIsWeb) {
      return notification;
    }

    await _notifications.show(
      (feeding.id ?? 0) * 100 + 88,
      notification.title,
      notification.message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Notifications',
          channelDescription: 'Notifications pour le suivi des animaux',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    return notification;
  }

  // Notification : Animal créé
  Future<NotificationModel> notifyAnimalCreated(Animal animal) async {
    final notification = NotificationModel(
      type: NotificationType.vaccination, // Utiliser un type existant ou créer un nouveau
      animalId: animal.id,
      relatedId: animal.id,
      title: 'Nouvel animal ajouté',
      message: '${animal.name} (${animal.species}) a été ajouté au refuge.',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    // Envoyer notification immédiate
    if (kIsWeb) {
      return notification;
    }

    await _notifications.show(
      (animal.id ?? 0) * 100 + 50,
      notification.title,
      notification.message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Notifications',
          channelDescription: 'Notifications pour le suivi des animaux',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    return notification;
  }

  // Notification : Animal modifié
  Future<NotificationModel> notifyAnimalUpdated(Animal animal) async {
    final notification = NotificationModel(
      type: NotificationType.vaccination,
      animalId: animal.id,
      relatedId: animal.id,
      title: 'Animal modifié',
      message: 'Les informations de ${animal.name} ont été mises à jour.',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    // Envoyer notification immédiate
    if (kIsWeb) {
      return notification;
    }

    await _notifications.show(
      (animal.id ?? 0) * 100 + 51,
      notification.title,
      notification.message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Notifications',
          channelDescription: 'Notifications pour le suivi des animaux',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    return notification;
  }

  // Notification : Animal supprimé
  Future<NotificationModel> notifyAnimalDeleted(String animalName, String species) async {
    final notification = NotificationModel(
      type: NotificationType.vaccination,
      animalId: null,
      relatedId: null,
      title: 'Animal supprimé',
      message: '$animalName ($species) a été retiré du refuge.',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    // Envoyer notification immédiate
    if (kIsWeb) {
      return notification;
    }

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      notification.title,
      notification.message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Notifications',
          channelDescription: 'Notifications pour le suivi des animaux',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    return notification;
  }

  // Notification : Vaccination créée
  Future<NotificationModel> notifyVaccinationCreated(Vaccination vaccination, Animal animal) async {
    final notification = NotificationModel(
      type: NotificationType.vaccination,
      animalId: vaccination.animalId,
      relatedId: vaccination.id,
      title: 'Vaccination enregistrée',
      message: 'Nouvelle vaccination enregistrée pour ${animal.name}: ${vaccination.vaccineType}.',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    // Envoyer notification immédiate
    if (kIsWeb) {
      return notification;
    }

    await _notifications.show(
      (vaccination.id ?? 0) * 100 + 10,
      notification.title,
      notification.message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Notifications',
          channelDescription: 'Notifications pour le suivi des animaux',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    return notification;
  }

  // Notification : Vaccination modifiée
  Future<NotificationModel> notifyVaccinationUpdated(Vaccination vaccination, Animal animal) async {
    final notification = NotificationModel(
      type: NotificationType.vaccination,
      animalId: vaccination.animalId,
      relatedId: vaccination.id,
      title: 'Vaccination modifiée',
      message: 'La vaccination de ${animal.name} (${vaccination.vaccineType}) a été modifiée.',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    // Envoyer notification immédiate
    if (kIsWeb) {
      return notification;
    }

    await _notifications.show(
      (vaccination.id ?? 0) * 100 + 11,
      notification.title,
      notification.message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Notifications',
          channelDescription: 'Notifications pour le suivi des animaux',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    return notification;
  }

  // Notification : Vaccination supprimée
  Future<NotificationModel> notifyVaccinationDeleted(String animalName, String vaccineType) async {
    final notification = NotificationModel(
      type: NotificationType.vaccination,
      animalId: null,
      relatedId: null,
      title: 'Vaccination supprimée',
      message: 'La vaccination $vaccineType de $animalName a été supprimée.',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    // Envoyer notification immédiate
    if (kIsWeb) {
      return notification;
    }

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000 + 1,
      notification.title,
      notification.message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Notifications',
          channelDescription: 'Notifications pour le suivi des animaux',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    return notification;
  }

  // Notification : Rendez-vous créé
  Future<NotificationModel> notifyAppointmentCreated(Appointment appointment, Animal animal) async {
    final notification = NotificationModel(
      type: NotificationType.appointment,
      animalId: appointment.animalId,
      relatedId: appointment.id,
      title: 'Rendez-vous créé',
      message: 'Nouveau rendez-vous pour ${animal.name}: ${appointment.appointmentType} le ${_formatDate(appointment.dateTime)}.',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    // Envoyer notification immédiate
    if (kIsWeb) {
      return notification;
    }

    await _notifications.show(
      (appointment.id ?? 0) * 100 + 20,
      notification.title,
      notification.message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Notifications',
          channelDescription: 'Notifications pour le suivi des animaux',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    return notification;
  }

  // Notification : Rendez-vous modifié
  Future<NotificationModel> notifyAppointmentUpdated(Appointment appointment, Animal animal) async {
    final notification = NotificationModel(
      type: NotificationType.appointment,
      animalId: appointment.animalId,
      relatedId: appointment.id,
      title: 'Rendez-vous modifié',
      message: 'Le rendez-vous de ${animal.name} a été modifié: ${appointment.appointmentType} le ${_formatDate(appointment.dateTime)}.',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    // Envoyer notification immédiate
    if (kIsWeb) {
      return notification;
    }

    await _notifications.show(
      (appointment.id ?? 0) * 100 + 21,
      notification.title,
      notification.message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Notifications',
          channelDescription: 'Notifications pour le suivi des animaux',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    return notification;
  }

  // Notification : Rendez-vous supprimé
  Future<NotificationModel> notifyAppointmentDeleted(String animalName, String appointmentType, DateTime date) async {
    final notification = NotificationModel(
      type: NotificationType.appointment,
      animalId: null,
      relatedId: null,
      title: 'Rendez-vous supprimé',
      message: 'Le rendez-vous $appointmentType de $animalName prévu le ${_formatDate(date)} a été supprimé.',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    // Envoyer notification immédiate
    if (kIsWeb) {
      return notification;
    }

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000 + 2,
      notification.title,
      notification.message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Notifications',
          channelDescription: 'Notifications pour le suivi des animaux',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    return notification;
  }

  // Notification : Alimentation créée
  Future<NotificationModel> notifyFeedingCreated(Feeding feeding, Animal animal) async {
    final notification = NotificationModel(
      type: NotificationType.feeding,
      animalId: feeding.animalId,
      relatedId: feeding.id,
      title: 'Plan d\'alimentation créé',
      message: 'Nouveau plan d\'alimentation pour ${animal.name}: ${feeding.foodType} (${feeding.dailyQuantity.toStringAsFixed(0)} g/jour).',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    // Envoyer notification immédiate (pas de planification pour les événements instantanés)
    if (kIsWeb) {
      return notification;
    }

    await _notifications.show(
      (feeding.id ?? 0) * 100 + 30,
      notification.title,
      notification.message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Notifications',
          channelDescription: 'Notifications pour le suivi des animaux',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    return notification;
  }

  // Notification : Alimentation supprimée
  Future<NotificationModel> notifyFeedingDeleted(String animalName, String foodType) async {
    final notification = NotificationModel(
      type: NotificationType.feeding,
      animalId: null,
      relatedId: null,
      title: 'Plan d\'alimentation supprimé',
      message: 'Le plan d\'alimentation ($foodType) de $animalName a été supprimé.',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    // Envoyer notification immédiate
    if (kIsWeb) {
      return notification;
    }

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000 + 3,
      notification.title,
      notification.message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Notifications',
          channelDescription: 'Notifications pour le suivi des animaux',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    return notification;
  }

  // Notification : Recherche effectuée
  Future<NotificationModel> notifySearchPerformed(String searchTerm, int resultsCount) async {
    final notification = NotificationModel(
      type: NotificationType.feeding, // Type générique
      animalId: null,
      relatedId: null,
      title: 'Recherche effectuée',
      message: 'Recherche "$searchTerm": $resultsCount résultat${resultsCount > 1 ? 's' : ''} trouvé${resultsCount > 1 ? 's' : ''}.',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    await scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000 + 4,
      title: notification.title,
      body: notification.message,
      scheduledDate: DateTime.now(),
    );

    return notification;
  }

  // Notification : Stock réapprovisionné
  Future<NotificationModel> notifyStockRestocked(Feeding feeding, Animal animal, double addedQuantity) async {
    final notification = NotificationModel(
      type: NotificationType.stockAlert,
      animalId: feeding.animalId,
      relatedId: feeding.id,
      title: 'Stock réapprovisionné',
      message: 'Stock de ${feeding.foodType} pour ${animal.name} réapprovisionné: +${addedQuantity.toStringAsFixed(0)} g (Total: ${feeding.currentStock.toStringAsFixed(0)} g).',
      scheduledDate: DateTime.now(),
      status: NotificationStatus.sent,
      sentDate: DateTime.now(),
    );

    // Envoyer notification immédiate (pas de planification pour les événements instantanés)
    if (kIsWeb) {
      return notification;
    }

    await _notifications.show(
      (feeding.id ?? 0) * 100 + 40,
      notification.title,
      notification.message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_channel',
          'Pet Care Notifications',
          channelDescription: 'Notifications pour le suivi des animaux',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    return notification;
  }
}


