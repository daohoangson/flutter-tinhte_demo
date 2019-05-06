part of '../posts.dart';

typedef void NewPostListener(Post post);

class PostListInheritedWidget extends InheritedWidget {
  final List<NewPostListener> _listeners = List();

  PostListInheritedWidget({
    Widget child,
    Key key,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(PostListInheritedWidget old) => true;

  VoidCallback addListener(NewPostListener listener) {
    _listeners.add(listener);

    return () => _listeners.remove(listener);
  }

  void notifyListeners(Post post) => _listeners.forEach((listener) {
        try {
          listener(post);
        } catch (e) {
          // print debug info then ignore
          debugPrint("Token listener $listener error: $e");
        }
      });

  static PostListInheritedWidget of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(PostListInheritedWidget);
}

class _ParentPostInheritedWidget extends InheritedWidget {
  final Post parentPost;

  _ParentPostInheritedWidget({
    Widget child,
    this.parentPost,
    Key key,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(_ParentPostInheritedWidget old) =>
      parentPost != old.parentPost;

  static _ParentPostInheritedWidget of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(_ParentPostInheritedWidget);
}

class _ThreadInheritedWidget extends InheritedWidget {
  final Thread thread;

  _ThreadInheritedWidget({
    Widget child,
    this.thread,
    Key key,
  })  : assert(thread != null),
        super(child: child, key: key);

  @override
  bool updateShouldNotify(_ThreadInheritedWidget old) => thread != old.thread;

  static _ThreadInheritedWidget of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(_ThreadInheritedWidget);
}
