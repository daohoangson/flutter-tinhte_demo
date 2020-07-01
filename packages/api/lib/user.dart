import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  int userId;
  bool userHasVerifiedBadge;
  bool userIsFollowed;
  bool userIsIgnored;
  bool userIsValid;
  bool userIsVerified;
  bool userIsVisitor;
  int userLastSeenDate;
  int userLikeCount;
  int userMessageCount;
  int userRegisterDate;
  String userTitle;
  int userUnreadNotificationCount;
  String username;

  UserLinks links;

  UserPermissions permissions;

  UserRank rank;

  User(this.userId);
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@JsonSerializable()
class UserLinks {
  String avatar;
  String avatarBig;
  String avatarSmall;
  String detail;
  String followers;
  String followings;
  String ignore;
  String permalink;
  String timeline;

  UserLinks();
  factory UserLinks.fromJson(Map<String, dynamic> json) =>
      _$UserLinksFromJson(json);
}

@JsonSerializable()
class UserPermissions {
  bool edit;
  bool follow;
  bool ignore;
  bool profilePost;

  UserPermissions();
  factory UserPermissions.fromJson(Map<String, dynamic> json) =>
      _$UserPermissionsFromJson(json);
}

@JsonSerializable()
class UserRank {
  int rankGroupId;
  int rankLevel;
  String rankName;

  // TODO: handle rank_points, it could be String or int (-1)

  UserRank();
  factory UserRank.fromJson(Map<String, dynamic> json) =>
      _$UserRankFromJson(json);
}
