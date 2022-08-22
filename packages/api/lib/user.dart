import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'followable.dart';

part 'user.freezed.dart';
part 'user.g.dart';

final _internalZero = _UserInternal.fromJson({'user_id': 0});

class User extends ChangeNotifier implements _User, Followable {
  _UserInternal _;

  User.fromJson(Map<String, dynamic> json) : _ = _UserInternal.fromJson(json);

  User.zero() : _ = _internalZero;

  void reset() => _update(_internalZero);

  void update(Map<String, dynamic> json) =>
      _update(_UserInternal.fromJson(json));

  void _update(_UserInternal v) {
    if (v == _) return;
    _ = v;
    notifyListeners();
  }

  @Deprecated("Use setters instead of copyWith")
  @override
  // ignore: library_private_types_in_public_api
  _$$_UserCopyWith<_$_User> get copyWith => throw UnimplementedError();

  @override
  String? get followersLink => links?.followers;

  @override
  bool get isFollowed => userIsFollowed ?? false;

  @override
  set isFollowed(bool v) {
    if (v == isFollowed) return;

    _ = _.copyWith(userIsFollowed: v);
    notifyListeners();
  }

  @override
  UserLinks? get links => _.links;

  @override
  String get name => username ?? '#$userId';

  @override
  UserPermissions? get permissions => _.permissions;

  @override
  UserRank? get rank => _.rank;

  @override
  Map<String, dynamic> toJson() => _.toJson();

  @override
  bool? get userHasVerifiedBadge => _.userHasVerifiedBadge;

  @override
  int get userId => _.userId;

  @override
  bool? get userIsFollowed => _.userIsFollowed ?? false;

  @override
  bool get userIsIgnored => _.userIsIgnored ?? false;

  set userIsIgnored(bool v) {
    if (v == userIsIgnored) return;

    _ = _.copyWith(userIsIgnored: v);
    notifyListeners();
  }

  @override
  bool? get userIsValid => _.userIsValid;

  @override
  bool? get userIsVerified => _.userIsVerified;

  @override
  bool? get userIsVisitor => _.userIsVisitor;

  @override
  int? get userLastSeenDate => _.userLastSeenDate;

  @override
  int? get userLikeCount => _.userLikeCount;

  @override
  int? get userMessageCount => _.userMessageCount;

  @override
  int? get userRegisterDate => _.userRegisterDate;

  @override
  String? get userTitle => _.userTitle;

  @override
  int? get userUnreadNotificationCount => _.userUnreadNotificationCount;

  @override
  String? get username => _.username;
}

@freezed
class _UserInternal with _$_UserInternal {
  const factory _UserInternal(
    int userId,
    bool? userHasVerifiedBadge,
    bool? userIsFollowed,
    bool? userIsIgnored,
    bool? userIsValid,
    bool? userIsVerified,
    bool? userIsVisitor,
    int? userLastSeenDate,
    int? userLikeCount,
    int? userMessageCount,
    int? userRegisterDate,
    String? userTitle,
    int? userUnreadNotificationCount,
    String? username,
    UserLinks? links,
    UserPermissions? permissions,
    UserRank? rank,
  ) = _User;

  factory _UserInternal.fromJson(Map<String, dynamic> json) =>
      _$_UserInternalFromJson(json);
}

@freezed
class UserLinks with _$UserLinks {
  const factory UserLinks({
    String? avatar,
    String? avatarBig,
    String? avatarSmall,
    String? detail,
    String? followers,
    String? followings,
    String? ignore,
    String? permalink,
    String? timeline,
  }) = _UserLinks;

  factory UserLinks.fromJson(Map<String, dynamic> json) =>
      _$UserLinksFromJson(json);
}

@freezed
class UserPermissions with _$UserPermissions {
  const factory UserPermissions({
    bool? edit,
    bool? follow,
    bool? ignore,
    bool? profilePost,
  }) = _UserPermissions;

  factory UserPermissions.fromJson(Map<String, dynamic> json) =>
      _$UserPermissionsFromJson(json);
}

@freezed
class UserRank with _$UserRank {
  const factory UserRank({
    int? rankGroupId,
    int? rankLevel,
    String? rankName,
    // TODO: handle rank_points, it could be String or int (-1)
  }) = _UserRank;

  factory UserRank.fromJson(Map<String, dynamic> json) =>
      _$UserRankFromJson(json);
}
