import 'package:flutter/material.dart';
import 'package:sales_bets/core/services/event_service.dart';
import 'package:sales_bets/models/even_model.dart';

class EventsProvider extends ChangeNotifier {
  final EventService _eventService;

  EventsProvider(this._eventService);

  // A stream to listen for real-time changes to all events (for the home screen).
  Stream<List<Event>> get events {
    return _eventService.getEventsStream();
  }

  // A future to get a single event by its ID (for the detailed event screen).
  Future<Event?> getEventById(String eventId) {
    return _eventService.getEventById(eventId);
  }
}