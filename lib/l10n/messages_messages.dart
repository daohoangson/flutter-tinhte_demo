// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a messages locale. All the
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
  String get localeName => 'messages';

  static m0(howMany, formatted) => "${Intl.plural(howMany, one: '${howMany} reply', other: '${formatted} replies')}";

  static m1(howMany, formatted) => "${Intl.plural(howMany, one: '${howMany} view', other: '${formatted} views')}";

  static m2(version, buildNumber) => "${version} (build number: ${buildNumber})";

  static m3(tag) => "Choose how you want to be notified when new contents are available in ${tag}:";

  static m4(tag) => "Unfollow ${tag}?";

  static m5(method) => "${method} has been cancelled.";

  static m6(method) => "Cannot login with ${method}.";

  static m7(page) => "Page ${page}";

  static m8(x, y) => "${x} of ${y}";

  static m9(howMany) => "${Intl.plural(howMany, one: 'You can only choose one.', other: 'You can only select up to ${howMany} choices.')}";

  static m10(number) => "Tap to load ${number} hidden replies...";

  static m11(query) => "Submit to search for \'${query}\'";

  static m12(username) => " by user \'${username}\'";

  static m13(forumTitle) => " in forum \'${forumTitle}\'";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function> {
    "_statsXReplies" : m0,
    "_statsXViews" : m1,
    "apiError" : MessageLookupByLibrary.simpleMessage("API Error"),
    "apiUnexpectedResponse" : MessageLookupByLibrary.simpleMessage("Unexpected API response"),
    "appTitle" : MessageLookupByLibrary.simpleMessage("tinhte.vn Demo"),
    "appVersion" : MessageLookupByLibrary.simpleMessage("Version"),
    "appVersionInfo" : m2,
    "appVersionNotAvailable" : MessageLookupByLibrary.simpleMessage("N/A"),
    "follow" : MessageLookupByLibrary.simpleMessage("Follow"),
    "followFollowing" : MessageLookupByLibrary.simpleMessage("Following"),
    "followNotificationChannelAlert" : MessageLookupByLibrary.simpleMessage("Alert"),
    "followNotificationChannelEmail" : MessageLookupByLibrary.simpleMessage("Email"),
    "followNotificationChannelExplainForX" : m3,
    "followNotificationChannels" : MessageLookupByLibrary.simpleMessage("Notification channels"),
    "followUnfollowXQuestion" : m4,
    "forums" : MessageLookupByLibrary.simpleMessage("Forums"),
    "home" : MessageLookupByLibrary.simpleMessage("Home"),
    "justAMomentEllipsis" : MessageLookupByLibrary.simpleMessage("Just a moment..."),
    "loadingEllipsis" : MessageLookupByLibrary.simpleMessage("Loading..."),
    "login" : MessageLookupByLibrary.simpleMessage("Login"),
    "loginAssociate" : MessageLookupByLibrary.simpleMessage("Associate"),
    "loginAssociateEnterPassword" : MessageLookupByLibrary.simpleMessage("An existing account has been found, please enter your password to associate it for future logins."),
    "loginErrorCancelled" : m5,
    "loginErrorNoAccessToken" : m6,
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
    "menuDeveloper" : MessageLookupByLibrary.simpleMessage("Developer Menu"),
    "menuDeveloperCrashTest" : MessageLookupByLibrary.simpleMessage("Crash Test"),
    "menuDeveloperShowPerformanceOverlay" : MessageLookupByLibrary.simpleMessage("Show Performance Overlay"),
    "menuLogout" : MessageLookupByLibrary.simpleMessage("Logout"),
    "myFeed" : MessageLookupByLibrary.simpleMessage("My Feed"),
    "navLowercaseNext" : MessageLookupByLibrary.simpleMessage("next"),
    "navLowercasePrevious" : MessageLookupByLibrary.simpleMessage("previous"),
    "navPageX" : m7,
    "navXOfY" : m8,
    "notifications" : MessageLookupByLibrary.simpleMessage("Notifications"),
    "openInBrowser" : MessageLookupByLibrary.simpleMessage("Open in browser"),
    "pickGallery" : MessageLookupByLibrary.simpleMessage("Select image to upload"),
    "pollErrorTooManyVotes" : m9,
    "pollVote" : MessageLookupByLibrary.simpleMessage("Vote"),
    "postDelete" : MessageLookupByLibrary.simpleMessage("Delete"),
    "postDeleteReasonHint" : MessageLookupByLibrary.simpleMessage("Reason to delete post."),
    "postDeleted" : MessageLookupByLibrary.simpleMessage("Deleted post."),
    "postError" : MessageLookupByLibrary.simpleMessage("Post error"),
    "postGoUnreadQuestion" : MessageLookupByLibrary.simpleMessage("Continue reading?"),
    "postGoUnreadYes" : MessageLookupByLibrary.simpleMessage("YES"),
    "postLike" : MessageLookupByLibrary.simpleMessage("Like"),
    "postLoadXHidden" : m10,
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
    "searchSubmitToContinue" : m11,
    "searchThisForum" : MessageLookupByLibrary.simpleMessage("Search this forum"),
    "searchThisUser" : MessageLookupByLibrary.simpleMessage("Search for this user"),
    "searchThreadByUser" : m12,
    "searchThreadInForum" : m13,
    "share" : MessageLookupByLibrary.simpleMessage("Share"),
    "tagLowercaseDiscussions" : MessageLookupByLibrary.simpleMessage("discussions"),
    "tagLowercaseNews" : MessageLookupByLibrary.simpleMessage("news"),
    "threadBookmark" : MessageLookupByLibrary.simpleMessage("Bookmark"),
    "threadBookmarkList" : MessageLookupByLibrary.simpleMessage("Bookmarks"),
    "threadBookmarkUndo" : MessageLookupByLibrary.simpleMessage("Unbookmark"),
    "threadCreateBody" : MessageLookupByLibrary.simpleMessage("Post body"),
    "threadCreateBodyHint" : MessageLookupByLibrary.simpleMessage(""),
    "threadCreateChooseAForum" : MessageLookupByLibrary.simpleMessage("Choose a forum"),
    "threadCreateError" : MessageLookupByLibrary.simpleMessage("Creating thread error"),
    "threadCreateErrorBodyIsEmpty" : MessageLookupByLibrary.simpleMessage("Please enter a post body to create thread"),
    "threadCreateErrorTitleIsEmpty" : MessageLookupByLibrary.simpleMessage("Please enter a title to create thread"),
    "threadCreateNew" : MessageLookupByLibrary.simpleMessage("Create new thread"),
    "threadCreateSubmit" : MessageLookupByLibrary.simpleMessage("Submit"),
    "threadCreateTitle" : MessageLookupByLibrary.simpleMessage("Thread title"),
    "threadCreateTitleHint" : MessageLookupByLibrary.simpleMessage("Something interesting"),
    "threadStickyBanner" : MessageLookupByLibrary.simpleMessage("Sticky"),
    "topThreads" : MessageLookupByLibrary.simpleMessage("Top Threads"),
    "userIgnore" : MessageLookupByLibrary.simpleMessage("Ignore"),
    "userRegisterDate" : MessageLookupByLibrary.simpleMessage("Joined"),
    "userUnignore" : MessageLookupByLibrary.simpleMessage("Unignore")
  };
}
