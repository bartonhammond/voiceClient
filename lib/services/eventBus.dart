import 'package:event_bus/event_bus.dart';

/// The global [EventBus] object.
EventBus eventBus = EventBus();

class MessagesEvent {
  MessagesEvent(this.empty);
  bool empty;
}

class ProfileEvent {
  ProfileEvent(this.isComplete);
  bool isComplete;
}
