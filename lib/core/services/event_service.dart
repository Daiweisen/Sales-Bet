import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sales_bets/models/even_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // A stream to get all events in real-time.
  Stream<List<Event>> getEventsStream() {
    return _firestore.collection('events').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // A future to get a single event by its ID.
  Future<Event?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return Event.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      // Handle error gracefully
      return null;
    }
  }

  // A method to add a new event.
  Future<void> addEvent(Event event) async {
    await _firestore.collection('events').doc(event.id).set(event.toMap());
  }
}