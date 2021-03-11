import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User(
    int userId, {
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
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
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
