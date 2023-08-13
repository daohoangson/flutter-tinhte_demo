// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a vi locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, always_declare_return_types

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef String MessageIfAbsent(String? messageStr, List<Object>? args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'vi';

  static m0(howMany, formatted) => "${Intl.plural(howMany, other: '${formatted} trả lời')}";

  static m1(howMany, formatted) => "${Intl.plural(howMany, other: '${formatted} xem')}";

  static m2(version, buildNumber) => "${version} (số thứ tự: ${buildNumber})";

  static m3(tag) => "Chọn cách bạn muốn nhận thông tin khi có bài mới trong mục ${tag}:";

  static m4(tag) => "Bỏ theo dõi ${tag}?";

  static m5(method) => "${method} đã bị huỷ.";

  static m6(method) => "Không thể đăng nhập bằng ${method}.";

  static m7(page) => "Trang ${page}";

  static m8(x, y) => "${x} / ${y}";

  static m9(howMany) => "${Intl.plural(howMany, one: 'Bạn chỉ có thể chọn một.', other: 'Bạn chỉ có thể chọn tối đa ${howMany} lựa chọn.')}";

  static m10(number) => "Tải thêm ${number} bài ẩn...";

  static m11(query) => "Bấm gửi đi để tìm cho \'${query}\'";

  static m12(username) => " bởi thành viên \'${username}\'";

  static m13(forumTitle) => " trong khu vực \'${forumTitle}\'";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function> {
    "_statsXReplies" : m0,
    "_statsXViews" : m1,
    "apiError" : MessageLookupByLibrary.simpleMessage("Lỗi hệ thống"),
    "apiUnexpectedResponse" : MessageLookupByLibrary.simpleMessage("Lỗi máy chủ"),
    "appTitle" : MessageLookupByLibrary.simpleMessage("Tinh tế Demo"),
    "appVersion" : MessageLookupByLibrary.simpleMessage("Phiên bản"),
    "appVersionInfo" : m2,
    "appVersionNotAvailable" : MessageLookupByLibrary.simpleMessage("Không có thông tin"),
    "follow" : MessageLookupByLibrary.simpleMessage("Theo dõi"),
    "followFollowing" : MessageLookupByLibrary.simpleMessage("Đang theo dõi"),
    "followNotificationChannelAlert" : MessageLookupByLibrary.simpleMessage("Thông báo"),
    "followNotificationChannelEmail" : MessageLookupByLibrary.simpleMessage("Email"),
    "followNotificationChannelExplainForX" : m3,
    "followNotificationChannels" : MessageLookupByLibrary.simpleMessage("Kênh thông tin"),
    "followUnfollowXQuestion" : m4,
    "forums" : MessageLookupByLibrary.simpleMessage("Diễn đàn"),
    "home" : MessageLookupByLibrary.simpleMessage("Trang chủ"),
    "justAMomentEllipsis" : MessageLookupByLibrary.simpleMessage("Chờ một xíu..."),
    "loadingEllipsis" : MessageLookupByLibrary.simpleMessage("Đang tải..."),
    "login" : MessageLookupByLibrary.simpleMessage("Đăng nhập"),
    "loginAssociate" : MessageLookupByLibrary.simpleMessage("Kết nối tài khoản"),
    "loginAssociateEnterPassword" : MessageLookupByLibrary.simpleMessage("Tìm thấy tài khoản có sẵn, xin vui lòng nhập mật khẩu để kết nối cho lần đăng nhập tiếp theo."),
    "loginErrorCancelled" : m5,
    "loginErrorNoAccessToken" : m6,
    "loginErrorPasswordIsEmpty" : MessageLookupByLibrary.simpleMessage("Xin vui lòng nhập mật khẩu để đăng nhập"),
    "loginErrorUsernameIsEmpty" : MessageLookupByLibrary.simpleMessage("Xin vui lòng nhập tên hoặc email để đăng nhập"),
    "loginGoogleErrorAccountIsNull" : MessageLookupByLibrary.simpleMessage("Không thể lấy thông tin tài khoản Google."),
    "loginGoogleErrorTokenIsEmpty" : MessageLookupByLibrary.simpleMessage("Không thể lấy thông tin xác thực từ Google."),
    "loginPassword" : MessageLookupByLibrary.simpleMessage("Mật khẩu"),
    "loginPasswordHint" : MessageLookupByLibrary.simpleMessage("hunter2"),
    "loginUsername" : MessageLookupByLibrary.simpleMessage("Tên đăng nhập"),
    "loginUsernameHint" : MessageLookupByLibrary.simpleMessage("anh_hung_ban_phim"),
    "loginUsernameOrEmail" : MessageLookupByLibrary.simpleMessage("Tên / email"),
    "loginWithApple" : MessageLookupByLibrary.simpleMessage("Đăng nhập tài khoản Apple"),
    "loginWithFacebook" : MessageLookupByLibrary.simpleMessage("Đăng nhập tài khoản Facebook"),
    "loginWithGoogle" : MessageLookupByLibrary.simpleMessage("Đăng nhập tài khoản Google"),
    "menu" : MessageLookupByLibrary.simpleMessage("Cài đặt"),
    "menuDarkTheme" : MessageLookupByLibrary.simpleMessage("Giao diện tối"),
    "menuDarkTheme0" : MessageLookupByLibrary.simpleMessage("Không, dùng giao diện sáng"),
    "menuDarkTheme1" : MessageLookupByLibrary.simpleMessage("Có, dùng giao diện tối"),
    "menuDarkThemeAuto" : MessageLookupByLibrary.simpleMessage("Thay đổi theo hệ điều hành"),
    "menuDeveloper" : MessageLookupByLibrary.simpleMessage("Cài đặt dev"),
    "menuDeveloperCrashTest" : MessageLookupByLibrary.simpleMessage("Thử crash app"),
    "menuDeveloperShowPerformanceOverlay" : MessageLookupByLibrary.simpleMessage("Hiển thị đồ thị hiệu năng"),
    "menuLogout" : MessageLookupByLibrary.simpleMessage("Thoát"),
    "myFeed" : MessageLookupByLibrary.simpleMessage("Cá nhân"),
    "navLowercaseNext" : MessageLookupByLibrary.simpleMessage("tiếp"),
    "navLowercasePrevious" : MessageLookupByLibrary.simpleMessage("trước"),
    "navPageX" : m7,
    "navXOfY" : m8,
    "notifications" : MessageLookupByLibrary.simpleMessage("Thông báo"),
    "openInBrowser" : MessageLookupByLibrary.simpleMessage("Mở trong trình duyệt"),
    "pickGallery" : MessageLookupByLibrary.simpleMessage("Chọn ảnh để tải lên"),
    "pollErrorTooManyVotes" : m9,
    "pollVote" : MessageLookupByLibrary.simpleMessage("Gửi đi"),
    "postDelete" : MessageLookupByLibrary.simpleMessage("Xoá"),
    "postDeleteReasonHint" : MessageLookupByLibrary.simpleMessage("Lý do xoá bài."),
    "postDeleted" : MessageLookupByLibrary.simpleMessage("Bài đã xoá."),
    "postError" : MessageLookupByLibrary.simpleMessage("Lỗi gửi bài"),
    "postGoUnreadQuestion" : MessageLookupByLibrary.simpleMessage("Đọc tiếp?"),
    "postGoUnreadYes" : MessageLookupByLibrary.simpleMessage("CÓ"),
    "postLike" : MessageLookupByLibrary.simpleMessage("Thích"),
    "postLoadXHidden" : m10,
    "postReply" : MessageLookupByLibrary.simpleMessage("Trả lời"),
    "postReplyMessageHint" : MessageLookupByLibrary.simpleMessage("Nhập nội dung bài đăng"),
    "postReplyingToAt" : MessageLookupByLibrary.simpleMessage("Đang trả lời @"),
    "postReport" : MessageLookupByLibrary.simpleMessage("Báo cáo"),
    "postReportReasonHint" : MessageLookupByLibrary.simpleMessage("Vấn đề cần thông báo cho quản trị viên."),
    "postReportedThanks" : MessageLookupByLibrary.simpleMessage("Cảm ơn bạn đã báo cáo nội dung xấu!"),
    "postUnlike" : MessageLookupByLibrary.simpleMessage("Bỏ thích"),
    "privacyPolicy" : MessageLookupByLibrary.simpleMessage("Chính sách quyền riêng tư"),
    "search" : MessageLookupByLibrary.simpleMessage("Tìm kiếm"),
    "searchEnterSomething" : MessageLookupByLibrary.simpleMessage("Nhập nội dung cần tìm kiếm"),
    "searchSubmitToContinue" : m11,
    "searchThisForum" : MessageLookupByLibrary.simpleMessage("Tìm trong khu vực này"),
    "searchThisUser" : MessageLookupByLibrary.simpleMessage("Tìm bài viết của thành viên này"),
    "searchThreadByUser" : m12,
    "searchThreadInForum" : m13,
    "share" : MessageLookupByLibrary.simpleMessage("Chia sẻ"),
    "tagLowercaseDiscussions" : MessageLookupByLibrary.simpleMessage("thảo luận"),
    "tagLowercaseNews" : MessageLookupByLibrary.simpleMessage("tin tức"),
    "threadBookmark" : MessageLookupByLibrary.simpleMessage("Đánh dấu"),
    "threadBookmarkList" : MessageLookupByLibrary.simpleMessage("Các bài đã đánh dấu"),
    "threadBookmarkUndo" : MessageLookupByLibrary.simpleMessage("Bỏ đánh dấu"),
    "threadCreateBody" : MessageLookupByLibrary.simpleMessage("Nội dung"),
    "threadCreateBodyHint" : MessageLookupByLibrary.simpleMessage(""),
    "threadCreateChooseAForum" : MessageLookupByLibrary.simpleMessage("Chọn một khu vực"),
    "threadCreateError" : MessageLookupByLibrary.simpleMessage("Lỗi tạo chủ đề"),
    "threadCreateErrorBodyIsEmpty" : MessageLookupByLibrary.simpleMessage("Xin vui lòng nhập nội dung để tạo chủ đề"),
    "threadCreateErrorTitleIsEmpty" : MessageLookupByLibrary.simpleMessage("Xin vui lòng nhập tiêu đề để tạo chủ đề"),
    "threadCreateNew" : MessageLookupByLibrary.simpleMessage("Tạo chủ đề mới"),
    "threadCreateSubmit" : MessageLookupByLibrary.simpleMessage("Tạo chủ đề"),
    "threadCreateTitle" : MessageLookupByLibrary.simpleMessage("Tiêu đề"),
    "threadCreateTitleHint" : MessageLookupByLibrary.simpleMessage("Cái gì đó hay hay"),
    "threadStickyBanner" : MessageLookupByLibrary.simpleMessage("Bài dính"),
    "topThreads" : MessageLookupByLibrary.simpleMessage("Bài nổi bật"),
    "userIgnore" : MessageLookupByLibrary.simpleMessage("Ẩn bài"),
    "userRegisterDate" : MessageLookupByLibrary.simpleMessage("Gia nhập"),
    "userUnignore" : MessageLookupByLibrary.simpleMessage("Bỏ ẩn bài")
  };
}
