import 'package:flutter/foundation.dart';
import '../models/animal.dart';
import '../models/vaccination.dart';
import '../models/appointment.dart';
import '../models/feeding.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/ai_prediction_service.dart';

class AnimalProvider with ChangeNotifier {
  List<Animal> _animals = [];
  List<Vaccination> _vaccinations = [];
  List<Appointment> _appointments = [];
  List<Feeding> _feedings = [];
  List<NotificationModel> _notifications = [];
  int _nextAnimalId = 1;
  int _nextVaccinationId = 1;
  int _nextAppointmentId = 1;
  int _nextFeedingId = 1;
  int _nextNotificationId = 1;

  List<Animal> get animals => _animals;
  List<NotificationModel> get notifications => _notifications;

  Future<void> loadAnimals() async {
    // Données déjà en mémoire, pas besoin de charger
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    // Données déjà en mémoire, pas besoin de charger
    notifyListeners();
  }

  Future<int> addAnimal(Animal animal) async {
    final newAnimal = Animal(
      id: _nextAnimalId++,
      name: animal.name,
      species: animal.species,
      age: animal.age,
      weight: animal.weight,
      imagePath: animal.imagePath,
      imageBase64: animal.imageBase64,
      dateAdded: animal.dateAdded,
    );
    _animals.add(newAnimal);
    // Trier par date d'ajout (plus récent en premier) au lieu du nom
    _animals.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    
    // Notification : Animal créé
    final notification = await NotificationService.instance.notifyAnimalCreated(newAnimal);
    final notificationWithId = NotificationModel(
      id: _nextNotificationId++,
      type: notification.type,
      animalId: notification.animalId,
      relatedId: notification.relatedId,
      title: notification.title,
      message: notification.message,
      scheduledDate: notification.scheduledDate,
      status: notification.status,
      sentDate: notification.sentDate,
      readDate: notification.readDate,
    );
    _notifications.add(notificationWithId);
    
    notifyListeners();
    return newAnimal.id!;
  }

  Future<void> updateAnimal(Animal animal) async {
    final index = _animals.indexWhere((a) => a.id == animal.id);
    if (index != -1) {
      _animals[index] = Animal(
        id: animal.id,
        name: animal.name,
        species: animal.species,
        age: animal.age,
        weight: animal.weight,
        imagePath: animal.imagePath,
        imageBase64: animal.imageBase64,
        dateAdded: animal.dateAdded,
      );
      // Trier par date d'ajout (plus récent en premier)
      _animals.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      
      // Notification : Animal modifié
      final notification = await NotificationService.instance.notifyAnimalUpdated(animal);
      final notificationWithId = NotificationModel(
        id: _nextNotificationId++,
        type: notification.type,
        animalId: notification.animalId,
        relatedId: notification.relatedId,
        title: notification.title,
        message: notification.message,
        scheduledDate: notification.scheduledDate,
        status: notification.status,
        sentDate: notification.sentDate,
        readDate: notification.readDate,
      );
      _notifications.add(notificationWithId);
      
      notifyListeners();
    }
  }

  Future<void> deleteAnimal(int id) async {
    final animal = _animals.firstWhere((a) => a.id == id);
    final animalName = animal.name;
    final animalSpecies = animal.species;
    
    _animals.removeWhere((a) => a.id == id);
    _vaccinations.removeWhere((v) => v.animalId == id);
    _appointments.removeWhere((a) => a.animalId == id);
    _feedings.removeWhere((f) => f.animalId == id);
    _notifications.removeWhere((n) => n.animalId == id);
    
    // Notification : Animal supprimé
    final notification = await NotificationService.instance.notifyAnimalDeleted(animalName, animalSpecies);
    final notificationWithId = NotificationModel(
      id: _nextNotificationId++,
      type: notification.type,
      animalId: notification.animalId,
      relatedId: notification.relatedId,
      title: notification.title,
      message: notification.message,
      scheduledDate: notification.scheduledDate,
      status: notification.status,
      sentDate: notification.sentDate,
      readDate: notification.readDate,
    );
    _notifications.add(notificationWithId);
    
    notifyListeners();
  }

  Future<void> addVaccination(Vaccination vaccination) async {
    final newVaccination = Vaccination(
      id: _nextVaccinationId++,
      animalId: vaccination.animalId,
      lastVaccineDate: vaccination.lastVaccineDate,
      nextVaccineDate: vaccination.nextVaccineDate,
      vaccineType: vaccination.vaccineType,
      isCompleted: vaccination.isCompleted,
      notes: vaccination.notes,
    );
    _vaccinations.add(newVaccination);
    
    // Récupérer l'animal et planifier les notifications
    final animal = _animals.firstWhere((a) => a.id == vaccination.animalId);
    
    // Notification : Vaccination créée
    final createdNotification = await NotificationService.instance.notifyVaccinationCreated(newVaccination, animal);
    final createdNotificationWithId = NotificationModel(
      id: _nextNotificationId++,
      type: createdNotification.type,
      animalId: createdNotification.animalId,
      relatedId: createdNotification.relatedId,
      title: createdNotification.title,
      message: createdNotification.message,
      scheduledDate: createdNotification.scheduledDate,
      status: createdNotification.status,
      sentDate: createdNotification.sentDate,
      readDate: createdNotification.readDate,
    );
    _notifications.add(createdNotificationWithId);
    
    // Planifier les rappels de vaccination
    final reminderNotification = await NotificationService.instance.scheduleVaccinationReminder(
      newVaccination,
      animal,
    );
    if (reminderNotification != null) {
      final reminderNotificationWithId = NotificationModel(
        id: _nextNotificationId++,
        type: reminderNotification.type,
        animalId: reminderNotification.animalId,
        relatedId: reminderNotification.relatedId,
        title: reminderNotification.title,
        message: reminderNotification.message,
        scheduledDate: reminderNotification.scheduledDate,
        status: reminderNotification.status,
        sentDate: reminderNotification.sentDate,
        readDate: reminderNotification.readDate,
      );
      _notifications.add(reminderNotificationWithId);
    }
    
    notifyListeners();
  }

  Future<void> addAppointment(Appointment appointment) async {
    final newAppointment = Appointment(
      id: _nextAppointmentId++,
      animalId: appointment.animalId,
      dateTime: appointment.dateTime,
      appointmentType: appointment.appointmentType,
      status: appointment.status,
      veterinarianName: appointment.veterinarianName,
      notes: appointment.notes,
      reminderSent: appointment.reminderSent,
    );
    _appointments.add(newAppointment);
    
    // Récupérer l'animal et planifier les notifications
    final animal = _animals.firstWhere((a) => a.id == appointment.animalId);
    
    // Notification : Rendez-vous créé
    final createdNotification = await NotificationService.instance.notifyAppointmentCreated(newAppointment, animal);
    final createdNotificationWithId = NotificationModel(
      id: _nextNotificationId++,
      type: createdNotification.type,
      animalId: createdNotification.animalId,
      relatedId: createdNotification.relatedId,
      title: createdNotification.title,
      message: createdNotification.message,
      scheduledDate: createdNotification.scheduledDate,
      status: createdNotification.status,
      sentDate: createdNotification.sentDate,
      readDate: createdNotification.readDate,
    );
    _notifications.add(createdNotificationWithId);
    
    // Planifier les rappels de rendez-vous
    final reminderNotification = await NotificationService.instance.scheduleAppointmentReminder(
      newAppointment,
      animal,
    );
    if (reminderNotification != null) {
      final reminderNotificationWithId = NotificationModel(
        id: _nextNotificationId++,
        type: reminderNotification.type,
        animalId: reminderNotification.animalId,
        relatedId: reminderNotification.relatedId,
        title: reminderNotification.title,
        message: reminderNotification.message,
        scheduledDate: reminderNotification.scheduledDate,
        status: reminderNotification.status,
        sentDate: reminderNotification.sentDate,
        readDate: reminderNotification.readDate,
      );
      _notifications.add(reminderNotificationWithId);
    }
    
    notifyListeners();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    final index = _appointments.indexWhere((a) => a.id == appointment.id);
    if (index != -1) {
      final oldAppointment = _appointments[index];
      _appointments[index] = appointment;
      _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      // Notification : Rendez-vous modifié
      final animal = _animals.firstWhere((a) => a.id == appointment.animalId);
      final notification = await NotificationService.instance.notifyAppointmentUpdated(
        appointment,
        animal,
      );
      final notificationWithId = NotificationModel(
        id: _nextNotificationId++,
        type: notification.type,
        animalId: notification.animalId,
        relatedId: notification.relatedId,
        title: notification.title,
        message: notification.message,
        scheduledDate: notification.scheduledDate,
        status: notification.status,
        sentDate: notification.sentDate,
        readDate: notification.readDate,
      );
      _notifications.add(notificationWithId);
      
      // Replanifier les notifications si la date a changé
      if (oldAppointment.dateTime != appointment.dateTime) {
        // Supprimer les anciennes notifications
        _notifications.removeWhere((n) => n.relatedId == appointment.id);
        
        // Planifier les nouvelles notifications
        final reminderNotification = await NotificationService.instance.scheduleAppointmentReminder(
          appointment,
          animal,
        );
        if (reminderNotification != null) {
          final reminderNotificationWithId = NotificationModel(
            id: _nextNotificationId++,
            type: reminderNotification.type,
            animalId: reminderNotification.animalId,
            relatedId: reminderNotification.relatedId,
            title: reminderNotification.title,
            message: reminderNotification.message,
            scheduledDate: reminderNotification.scheduledDate,
            status: reminderNotification.status,
            sentDate: reminderNotification.sentDate,
            readDate: reminderNotification.readDate,
          );
          _notifications.add(reminderNotificationWithId);
        }
      }
      
      notifyListeners();
    }
  }

  Future<void> addFeeding(Feeding feeding) async {
    final newFeeding = Feeding(
      id: _nextFeedingId++,
      animalId: feeding.animalId,
      foodType: feeding.foodType,
      dailyQuantity: feeding.dailyQuantity,
      mealTimes: feeding.mealTimes,
      currentStock: feeding.currentStock,
      lastStockUpdate: feeding.lastStockUpdate,
    );
    _feedings.add(newFeeding);
    
    // Récupérer l'animal et planifier les notifications
    final animal = _animals.firstWhere((a) => a.id == feeding.animalId);
    
    // Notification : Alimentation créée
    final createdNotification = await NotificationService.instance.notifyFeedingCreated(newFeeding, animal);
    final createdNotificationWithId = NotificationModel(
      id: _nextNotificationId++,
      type: createdNotification.type,
      animalId: createdNotification.animalId,
      relatedId: createdNotification.relatedId,
      title: createdNotification.title,
      message: createdNotification.message,
      scheduledDate: createdNotification.scheduledDate,
      status: createdNotification.status,
      sentDate: createdNotification.sentDate,
      readDate: createdNotification.readDate,
    );
    _notifications.add(createdNotificationWithId);
    
    // Planifier les rappels de repas
    final feedingNotifications = await NotificationService.instance.scheduleFeedingReminders(
      newFeeding,
      animal,
    );
    for (var notification in feedingNotifications) {
      final notificationWithId = NotificationModel(
        id: _nextNotificationId++,
        type: notification.type,
        animalId: notification.animalId,
        relatedId: notification.relatedId,
        title: notification.title,
        message: notification.message,
        scheduledDate: notification.scheduledDate,
        status: notification.status,
        sentDate: notification.sentDate,
        readDate: notification.readDate,
      );
      _notifications.add(notificationWithId);
    }
    
    // Planifier l'alerte de stock avec prédiction IA
    final stockNotification = await NotificationService.instance.scheduleStockAlert(
      newFeeding,
      animal,
    );
    if (stockNotification != null) {
      final notificationWithId = NotificationModel(
        id: _nextNotificationId++,
        type: stockNotification.type,
        animalId: stockNotification.animalId,
        relatedId: stockNotification.relatedId,
        title: stockNotification.title,
        message: stockNotification.message,
        scheduledDate: stockNotification.scheduledDate,
        status: stockNotification.status,
        sentDate: stockNotification.sentDate,
        readDate: stockNotification.readDate,
      );
      _notifications.add(notificationWithId);
    }
    
    notifyListeners();
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = _notifications[index];
      _notifications[index] = NotificationModel(
      id: notification.id,
      type: notification.type,
      animalId: notification.animalId,
      relatedId: notification.relatedId,
      title: notification.title,
      message: notification.message,
      scheduledDate: notification.scheduledDate,
      status: NotificationStatus.read,
      sentDate: notification.sentDate,
      readDate: DateTime.now(),
    );
      notifyListeners();
    }
  }

  Future<void> markNotificationAsCompleted(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = _notifications[index];
      _notifications[index] = NotificationModel(
      id: notification.id,
      type: notification.type,
      animalId: notification.animalId,
      relatedId: notification.relatedId,
      title: notification.title,
      message: notification.message,
      scheduledDate: notification.scheduledDate,
      status: NotificationStatus.completed,
      sentDate: notification.sentDate,
      readDate: notification.readDate,
    );
      notifyListeners();
    }
  }


  // Méthodes pour récupérer les données liées
  List<Vaccination> getVaccinationsByAnimal(int animalId) {
    return _vaccinations.where((v) => v.animalId == animalId).toList()
      ..sort((a, b) => (b.nextVaccineDate ?? DateTime(0))
          .compareTo(a.nextVaccineDate ?? DateTime(0)));
  }

  List<Appointment> getAppointmentsByAnimal(int animalId) {
    return _appointments.where((a) => a.animalId == animalId).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Appointment> getAllAppointments() {
    return List.from(_appointments)..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  Feeding? getFeedingByAnimal(int animalId) {
    try {
      return _feedings.firstWhere((f) => f.animalId == animalId);
    } catch (e) {
      return null;
    }
  }

  // Marquer un vaccin comme complété
  Future<void> completeVaccination(int vaccinationId) async {
    final index = _vaccinations.indexWhere((v) => v.id == vaccinationId);
    if (index != -1) {
      final vaccination = _vaccinations[index];
      final updated = Vaccination(
        id: vaccination.id,
        animalId: vaccination.animalId,
        lastVaccineDate: vaccination.lastVaccineDate,
        nextVaccineDate: vaccination.nextVaccineDate,
        vaccineType: vaccination.vaccineType,
        isCompleted: true,
        notes: vaccination.notes,
      );
      _vaccinations[index] = updated;
      
      // Envoyer notification "Vaccin administré"
      final animal = _animals.firstWhere((a) => a.id == vaccination.animalId);
      final notification = await NotificationService.instance.notifyVaccinationCompleted(
        updated,
        animal,
      );
      final notificationWithId = NotificationModel(
        id: _nextNotificationId++,
        type: notification.type,
        animalId: notification.animalId,
        relatedId: notification.relatedId,
        title: notification.title,
        message: notification.message,
        scheduledDate: notification.scheduledDate,
        status: notification.status,
        sentDate: notification.sentDate,
        readDate: notification.readDate,
      );
      _notifications.add(notificationWithId);
      
      notifyListeners();
    }
  }

  // Marquer un rendez-vous comme complété
  Future<void> completeAppointment(int appointmentId) async {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      final appointment = _appointments[index];
      final updated = Appointment(
        id: appointment.id,
        animalId: appointment.animalId,
        dateTime: appointment.dateTime,
        appointmentType: appointment.appointmentType,
        status: AppointmentStatus.completed,
        veterinarianName: appointment.veterinarianName,
        notes: appointment.notes,
        reminderSent: appointment.reminderSent,
      );
      _appointments[index] = updated;
      
      // Envoyer notification "Rendez-vous complété"
      final animal = _animals.firstWhere((a) => a.id == appointment.animalId);
      final notification = await NotificationService.instance.notifyAppointmentCompleted(
        updated,
        animal,
      );
      final notificationWithId = NotificationModel(
        id: _nextNotificationId++,
        type: notification.type,
        animalId: notification.animalId,
        relatedId: notification.relatedId,
        title: notification.title,
        message: notification.message,
        scheduledDate: notification.scheduledDate,
        status: notification.status,
        sentDate: notification.sentDate,
        readDate: notification.readDate,
      );
      _notifications.add(notificationWithId);
      
      notifyListeners();
    }
  }

  // Mettre à jour un plan d'alimentation
  Future<void> updateFeeding(Feeding feeding) async {
    final index = _feedings.indexWhere((f) => f.id == feeding.id);
    if (index != -1) {
      final oldFeeding = _feedings[index];
      final oldFoodType = oldFeeding.foodType;
      
      _feedings[index] = feeding;
      
      // Envoyer notification "Nouveau régime enregistré" si le type a changé
      if (oldFoodType != feeding.foodType) {
        final animal = _animals.firstWhere((a) => a.id == feeding.animalId);
        final notification = await NotificationService.instance.notifyFeedingUpdated(
          feeding,
          animal,
          oldFoodType,
        );
        final notificationWithId = NotificationModel(
          id: _nextNotificationId++,
          type: notification.type,
          animalId: notification.animalId,
          relatedId: notification.relatedId,
          title: notification.title,
          message: notification.message,
          scheduledDate: notification.scheduledDate,
          status: notification.status,
          sentDate: notification.sentDate,
          readDate: notification.readDate,
        );
        _notifications.add(notificationWithId);
      }
      
      notifyListeners();
    }
  }

  // Réapprovisionner le stock
  Future<void> restockFeeding(int feedingId, double additionalStock) async {
    final index = _feedings.indexWhere((f) => f.id == feedingId);
    if (index != -1) {
      final feeding = _feedings[index];
      final updated = Feeding(
        id: feeding.id,
        animalId: feeding.animalId,
        foodType: feeding.foodType,
        dailyQuantity: feeding.dailyQuantity,
        mealTimes: feeding.mealTimes,
        currentStock: feeding.currentStock + additionalStock,
        lastStockUpdate: DateTime.now(),
      );
      _feedings[index] = updated;
      
      // Supprimer les notifications d'alerte de stock pour cet animal
      _notifications.removeWhere((n) => 
        n.type == NotificationType.stockAlert && 
        n.relatedId == feedingId
      );
      
      // Notification : Stock réapprovisionné
      final animal = _animals.firstWhere((a) => a.id == feeding.animalId);
      final notification = await NotificationService.instance.notifyStockRestocked(updated, animal, additionalStock);
      final notificationWithId = NotificationModel(
        id: _nextNotificationId++,
        type: notification.type,
        animalId: notification.animalId,
        relatedId: notification.relatedId,
        title: notification.title,
        message: notification.message,
        scheduledDate: notification.scheduledDate,
        status: notification.status,
        sentDate: notification.sentDate,
        readDate: notification.readDate,
      );
      _notifications.add(notificationWithId);
      
      notifyListeners();
    }
  }

  // Méthodes pour supprimer des éléments avec notifications
  Future<void> deleteVaccination(int vaccinationId) async {
    final vaccination = _vaccinations.firstWhere((v) => v.id == vaccinationId);
    final animal = _animals.firstWhere((a) => a.id == vaccination.animalId);
    
    _vaccinations.removeWhere((v) => v.id == vaccinationId);
    _notifications.removeWhere((n) => n.relatedId == vaccinationId);
    
    // Notification : Vaccination supprimée
    final notification = await NotificationService.instance.notifyVaccinationDeleted(animal.name, vaccination.vaccineType);
    final notificationWithId = NotificationModel(
      id: _nextNotificationId++,
      type: notification.type,
      animalId: notification.animalId,
      relatedId: notification.relatedId,
      title: notification.title,
      message: notification.message,
      scheduledDate: notification.scheduledDate,
      status: notification.status,
      sentDate: notification.sentDate,
      readDate: notification.readDate,
    );
    _notifications.add(notificationWithId);
    
    notifyListeners();
  }

  Future<void> deleteAppointment(int appointmentId) async {
    final appointment = _appointments.firstWhere((a) => a.id == appointmentId);
    final animal = _animals.firstWhere((a) => a.id == appointment.animalId);
    
    _appointments.removeWhere((a) => a.id == appointmentId);
    _notifications.removeWhere((n) => n.relatedId == appointmentId);
    
    // Notification : Rendez-vous supprimé
    final notification = await NotificationService.instance.notifyAppointmentDeleted(
      animal.name,
      appointment.appointmentType,
      appointment.dateTime,
    );
    final notificationWithId = NotificationModel(
      id: _nextNotificationId++,
      type: notification.type,
      animalId: notification.animalId,
      relatedId: notification.relatedId,
      title: notification.title,
      message: notification.message,
      scheduledDate: notification.scheduledDate,
      status: notification.status,
      sentDate: notification.sentDate,
      readDate: notification.readDate,
    );
    _notifications.add(notificationWithId);
    
    notifyListeners();
  }

  Future<void> deleteFeeding(int feedingId) async {
    final feeding = _feedings.firstWhere((f) => f.id == feedingId);
    final animal = _animals.firstWhere((a) => a.id == feeding.animalId);
    
    _feedings.removeWhere((f) => f.id == feedingId);
    _notifications.removeWhere((n) => n.relatedId == feedingId);
    
    // Notification : Alimentation supprimée
    final notification = await NotificationService.instance.notifyFeedingDeleted(animal.name, feeding.foodType);
    final notificationWithId = NotificationModel(
      id: _nextNotificationId++,
      type: notification.type,
      animalId: notification.animalId,
      relatedId: notification.relatedId,
      title: notification.title,
      message: notification.message,
      scheduledDate: notification.scheduledDate,
      status: notification.status,
      sentDate: notification.sentDate,
      readDate: notification.readDate,
    );
    _notifications.add(notificationWithId);
    
    notifyListeners();
  }

  // Notification de recherche
  Future<void> notifySearch(String searchTerm, int resultsCount) async {
    final notification = await NotificationService.instance.notifySearchPerformed(searchTerm, resultsCount);
    final notificationWithId = NotificationModel(
      id: _nextNotificationId++,
      type: notification.type,
      animalId: notification.animalId,
      relatedId: notification.relatedId,
      title: notification.title,
      message: notification.message,
      scheduledDate: notification.scheduledDate,
      status: notification.status,
      sentDate: notification.sentDate,
      readDate: notification.readDate,
    );
    _notifications.add(notificationWithId);
    notifyListeners();
  }

  // Historique rapide pour un animal
  Map<String, dynamic> getQuickHistory(int animalId) {
    final vaccinations = getVaccinationsByAnimal(animalId);
    final appointments = getAppointmentsByAnimal(animalId);
    final feeding = getFeedingByAnimal(animalId);
    
    final lastVaccination = vaccinations.isNotEmpty ? vaccinations.first : null;
    final lastAppointment = appointments.isNotEmpty ? appointments.first : null;
    final nextAppointment = appointments.where((a) => a.dateTime.isAfter(DateTime.now())).isNotEmpty
        ? appointments.where((a) => a.dateTime.isAfter(DateTime.now())).first
        : null;
    
    return {
      'lastVaccination': lastVaccination,
      'lastAppointment': lastAppointment,
      'nextAppointment': nextAppointment,
      'feeding': feeding,
      'stockDays': feeding != null ? AIPredictionService.predictStockout(feeding) : null,
    };
  }
}


