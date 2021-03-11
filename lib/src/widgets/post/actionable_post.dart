import 'package:flutter/foundation.dart';
import 'package:the_api/post.dart';

class ActionablePost extends ChangeNotifier {
  final Post _post;

  bool _isDeleted;
  bool _isLiked;
  int _likeCount;
  PostPermissions _permissions;

  ActionablePost(this._post) {
    _isDeleted = _post.postIsDeleted == true;
    _isLiked = _post.postIsLiked == true;
    _likeCount = _post.postLikeCount ?? 0;
    _permissions = _post.permissions;
  }

  String get bodyHtml => _post.postBodyHtml;

  int get createDate => _post.postCreateDate;

  bool get isDeleted => _isDeleted;
  set isDeleted(bool v) {
    if (v == _isDeleted) return;

    if (v) {
      _isDeleted = v;
      _permissions = null;
      notifyListeners();
    } else {
      throw UnimplementedError();
    }
  }

  bool get isFirst => _post.postIsFirstPost;

  bool get isLiked => _isLiked;
  set isLiked(bool v) {
    if (v == _isLiked) return;

    if (_isLiked = v) {
      _likeCount++;
    } else if (_likeCount > 0) {
      _likeCount--;
    }

    notifyListeners();
  }

  int get likeCount => _likeCount;

  PostLinks get links => _post.links;

  PostPermissions get permissions => _permissions;
}
