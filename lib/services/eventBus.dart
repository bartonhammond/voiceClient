import 'package:event_bus/event_bus.dart';

/// The global [EventBus] object.
EventBus eventBus = EventBus();

class MessagesEvent {
  MessagesEvent(this.empty);
  bool empty;
}

class GetUserMessagesEvent {}

//id no stories, book can be deleted
class BookHasNoStories {
  BookHasNoStories(this.id);
  String id;
}

class HideProfileBanner {}

class HideStoryBanner {}

class ProxyStarted {}

class ProxyEnded {}

class BookWasAdded {}

class BookWasDeleted {}

class StoryWasAssignedToBook {}

class ProfileEvent {
  ProfileEvent(this.isComplete);
  bool isComplete;
}
