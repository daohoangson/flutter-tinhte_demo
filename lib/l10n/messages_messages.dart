// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a messages locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'messages';

  static m0(howMany, formatted) => "${Intl.plural(howMany, one: '${howMany} reply', other: '${formatted} replies')}";

  static m1(howMany, formatted) => "${Intl.plural(howMany, one: '${howMany} view', other: '${formatted} views')}";

  static m2(version, buildNumber) => "${version} (build number: ${buildNumber})";

  static m3(method) => "${method} has been cancelled.";

  static m4(method) => "Cannot login with ${method}.";

  static m5(page) => "Page ${page}";

  static m6(x, y) => "${x} of ${y}";

  static m7(howMany) => "${Intl.plural(howMany, one: 'You can only choose one.', other: 'You can only select up to ${howMany} choices.')}";

  static m8(number) => "Tap to load ${number} hidden replies...";

  static m9(query) => "Submit to search for \'${query}\'";

  static m10(username) => " by user \'${username}\'";

  static m11(forumTitle) => " in forum \'${forumTitle}\'";

  static m12(tag) => "Choose how you want to be notified when new contents are available in ${tag}:";

  static m13(tag) => "Unfollow ${tag}?";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "_statsXReplies" : m0,
    "_statsXViews" : m1,
    "apiError" : MessageLookupByLibrary.simpleMessage("API Error"),
    "apiUnexpectedResponse" : MessageLookupByLibrary.simpleMessage("Unexpected API response"),
    "appTitle" : MessageLookupByLibrary.simpleMessage("tinhte.vn Demo"),
    "appVersion" : MessageLookupByLibrary.simpleMessage("Version"),
    "appVersionInfo" : m2,
    "appVersionNotAvailable" : MessageLookupByLibrary.simpleMessage("N/A"),
    "forums" : MessageLookupByLibrary.simpleMessage("Forums"),
    "home" : MessageLookupByLibrary.simpleMessage("Home"),
    "justAMomentEllipsis" : MessageLookupByLibrary.simpleMessage("Just a moment..."),
    "loadingEllipsis" : MessageLookupByLibrary.simpleMessage("Loading..."),
    "login" : MessageLookupByLibrary.simpleMessage("Login"),
    "loginAssociate" : MessageLookupByLibrary.simpleMessage("Associate"),
    "loginAssociateEnterPassword" : MessageLookupByLibrary.simpleMessage("An existing account has been found, please enter your password to associate it for future logins."),
    "loginErrorCancelled" : m3,
    "loginErrorNoAccessToken" : m4,
    "loginErrorNoAccessTokenAutoRegister" : MessageLookupByLibrary.simpleMessage("Cannot register new user account."),
    "loginErrorPasswordIsEmpty" : MessageLookupByLibrary.simpleMessage("Please enter your password to login"),
    "loginErrorUsernameIsEmpty" : MessageLookupByLibrary.simpleMessage("Please enter your username or email"),
    "loginGoogleErrorAccountIsNull" : MessageLookupByLibrary.simpleMessage("Cannot get Google account information."),
    "loginGoogleErrorTokenIsEmpty" : MessageLookupByLibrary.simpleMessage("Cannot get Google authentication info."),
    "loginPassword" : MessageLookupByLibrary.simpleMessage("Password"),
    "loginPasswordHint" : MessageLookupByLibrary.simpleMessage("hunter2"),
    "loginUsername" : MessageLookupByLibrary.simpleMessage("Username"),
    "loginUsernameHint" : MessageLookupByLibrary.simpleMessage("keyboard_warrior"),
    "loginUsernameOrEmail" : MessageLookupByLibrary.simpleMessage("Username / email"),
    "loginWithApple" : MessageLookupByLibrary.simpleMessage("Sign in with Apple"),
    "loginWithFacebook" : MessageLookupByLibrary.simpleMessage("Sign in with Facebook"),
    "loginWithGoogle" : MessageLookupByLibrary.simpleMessage("Sign in with Google"),
    "menu" : MessageLookupByLibrary.simpleMessage("Menu"),
    "menuDarkTheme" : MessageLookupByLibrary.simpleMessage("Dark theme"),
    "menuDarkTheme0" : MessageLookupByLibrary.simpleMessage("No, use light theme"),
    "menuDarkTheme1" : MessageLookupByLibrary.simpleMessage("Yes, use dark theme"),
    "menuDarkThemeAuto" : MessageLookupByLibrary.simpleMessage("Use system\'s color scheme"),
    "menuLogout" : MessageLookupByLibrary.simpleMessage("Logout"),
    "myFeed" : MessageLookupByLibrary.simpleMessage("My Feed"),
    "navLowercaseNext" : MessageLookupByLibrary.simpleMessage("next"),
    "navLowercasePrevious" : MessageLookupByLibrary.simpleMessage("previous"),
    "navPageX" : m5,
    "navXOfY" : m6,
    "notifications" : MessageLookupByLibrary.simpleMessage("Notifications"),
    "openInBrowser" : MessageLookupByLibrary.simpleMessage("Open in browser"),
    "pollErrorTooManyVotes" : m7,
    "pollVote" : MessageLookupByLibrary.simpleMessage("Vote"),
    "postDelete" : MessageLookupByLibrary.simpleMessage("Delete"),
    "postDeleteReasonHint" : MessageLookupByLibrary.simpleMessage("Reason to delete post."),
    "postDeleted" : MessageLookupByLibrary.simpleMessage("Deleted post."),
    "postError" : MessageLookupByLibrary.simpleMessage("Post error"),
    "postGoUnreadQuestion" : MessageLookupByLibrary.simpleMessage("Continue reading?"),
    "postGoUnreadYes" : MessageLookupByLibrary.simpleMessage("YES"),
    "postLike" : MessageLookupByLibrary.simpleMessage("Like"),
    "postLoadXHidden" : m8,
    "postReply" : MessageLookupByLibrary.simpleMessage("Reply"),
    "postReplyMessageHint" : MessageLookupByLibrary.simpleMessage("Enter your message to post"),
    "postReplyingToAt" : MessageLookupByLibrary.simpleMessage("Replying to @"),
    "postReport" : MessageLookupByLibrary.simpleMessage("Report"),
    "postReportReasonHint" : MessageLookupByLibrary.simpleMessage("Problem to be reported."),
    "postReportedThanks" : MessageLookupByLibrary.simpleMessage("Thank you for your report!"),
    "postUnlike" : MessageLookupByLibrary.simpleMessage("Unlike"),
    "privacyPolicy" : MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "search" : MessageLookupByLibrary.simpleMessage("Search"),
    "searchEnterSomething" : MessageLookupByLibrary.simpleMessage("Enter something to search"),
    "searchSubmitToContinue" : m9,
    "searchThisForum" : MessageLookupByLibrary.simpleMessage("Search this forum"),
    "searchThisUser" : MessageLookupByLibrary.simpleMessage("Search for this user"),
    "searchThreadByUser" : m10,
    "searchThreadInForum" : m11,
    "share" : MessageLookupByLibrary.simpleMessage("Share"),
    "tagFollow" : MessageLookupByLibrary.simpleMessage("Follow"),
    "tagFollowing" : MessageLookupByLibrary.simpleMessage("Following"),
    "tagLowercaseDiscussions" : MessageLookupByLibrary.simpleMessage("discussions"),
    "tagLowercaseNews" : MessageLookupByLibrary.simpleMessage("news"),
    "tagNotificationChannelAlert" : MessageLookupByLibrary.simpleMessage("Alert"),
    "tagNotificationChannelEmail" : MessageLookupByLibrary.simpleMessage("Email"),
    "tagNotificationChannelExplainForX" : m12,
    "tagNotificationChannels" : MessageLookupByLibrary.simpleMessage("Notification channels"),
    "tagUnfollowXQuestion" : m13,
    "threadStickyBanner" : MessageLookupByLibrary.simpleMessage("Sticky"),
    "topThreads" : MessageLookupByLibrary.simpleMessage("Top Threads"),
    "userFollow" : MessageLookupByLibrary.simpleMessage("Follow"),
    "userIgnore" : MessageLookupByLibrary.simpleMessage("Ignore"),
    "userRegisterDate" : MessageLookupByLibrary.simpleMessage("Joined"),
    "userUnfollow" : MessageLookupByLibrary.simpleMessage("Unfollow"),
    "userUnignore" : MessageLookupByLibrary.simpleMessage("Unignore")
  };
}
