import UserNotifications

class FcmService {
  func onApplicationDidReceiveRemoteNotification(_ userInfo: [AnyHashable : Any]) {
    guard let readNotificationId = userInfo["read_notification_id"] as? String else { return }
    onNotificationRead(readNotificationId)
  }

  private func onNotificationRead(_ which: String) {
    let isAll = which == "all"
    let unc = UNUserNotificationCenter.current()

    unc.getDeliveredNotifications { notifications in
      var identifiers: [String] = []

      for notification in notifications {
        let userInfo = notification.request.content.userInfo
        guard let notificationId = userInfo["notification_id"] as? String else { continue }
        if isAll || notificationId == which {
          identifiers.append(notification.request.identifier)
        }
      }

      if !identifiers.isEmpty {
        unc.removeDeliveredNotifications(withIdentifiers: identifiers)
      }

      // TODO: switch to Logger when iOS 14 is available
      NSLog("onNotificationRead(which=\(which)) dismissed=\(identifiers.count)")
    }
  }
}
