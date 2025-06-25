import UIKit
import Flutter
import GoogleMaps
import Firebase
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()
    
    // Configure Google Maps
    GMSServices.provideAPIKey("AIzaSyAQomYPjlR3qGV6TYu45vrwEfxKOROKvUY") // Replace with your new API key
    
    // Register for remote notifications with enhanced configuration
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      
      // Request comprehensive notification permissions
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound, .provisional]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { granted, error in
          print("📱 Notification permission granted: \(granted)")
          if let error = error {
            print("❌ Notification permission error: \(error)")
          }
        }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    // Register for remote notifications
    application.registerForRemoteNotifications()
    
    // Set up notification categories for better handling
    setupNotificationCategories()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Set up notification categories
  private func setupNotificationCategories() {
    if #available(iOS 10.0, *) {
      let tripCategory = UNNotificationCategory(
        identifier: "trip_notifications",
        actions: [],
        intentIdentifiers: [],
        options: [.allowAnnouncement]
      )
      
      UNUserNotificationCenter.current().setNotificationCategories([tripCategory])
    }
  }
  
  // Handle remote notification registration
  override func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("📱 Device token received: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  // Handle remote notification registration failure
  override func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("❌ Failed to register for remote notifications: \(error)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
  
  // Handle notification when app is in background - ENHANCED
  override func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("📨 Received remote notification in background: \(userInfo)")
    
    // Process the notification data
    if let aps = userInfo["aps"] as? [String: Any] {
      print("📨 APS data: \(aps)")
      
      // Check if this is a silent notification (no alert/badge/sound in aps)
      let hasAlert = aps["alert"] != nil
      let hasBadge = aps["badge"] != nil
      let hasSound = aps["sound"] != nil
      
      print("🔇 Silent notification check - Alert: \(hasAlert), Badge: \(hasBadge), Sound: \(hasSound)")
      
      if !hasAlert && !hasBadge && !hasSound {
        print("🔇 This is a silent notification (data-only message)")
        // Process the data-only message
        processSilentNotification(userInfo)
      }
    }
    
    // Always call completion handler with appropriate result
    completionHandler(.newData)
  }
  
  // Handle notification when app is launched from notification
  override func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    print("📨 Received remote notification: \(userInfo)")
    super.application(application, didReceiveRemoteNotification: userInfo)
  }
  
  // Handle notification tap when app is in background - ENHANCED
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
    print("👆 User tapped notification: \(response.notification.request.content.userInfo)")
    
    // Process the notification response
    let userInfo = response.notification.request.content.userInfo
    if let aps = userInfo["aps"] as? [String: Any] {
      print("👆 APS data from tap: \(aps)")
    }
    
    completionHandler()
  }
  
  // Handle notification when app is in foreground - ENHANCED
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    print("📨 Will present notification: \(notification.request.content.userInfo)")
    
    // Show notification even when app is in foreground
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .badge, .sound])
    } else {
    completionHandler([.alert, .badge, .sound])
    }
  }
  
  // Process silent notifications
  private func processSilentNotification(_ userInfo: [AnyHashable: Any]) {
    print("🔇 Processing silent notification data: \(userInfo)")
    
    // Extract custom data
    if let customData = userInfo["data"] as? [String: Any] {
      print("🔇 Custom data: \(customData)")
      
      // Handle different notification types
      if let type = customData["type"] as? String {
        switch type {
        case "NEW_TRIP_AVAILABLE", "NEW_TRIPS_AVAILABLE":
          print("🚗 New trip notification received")
          // You can add custom logic here
        case "trip_created", "new_trip":
          print("🚗 Trip created notification received")
          // You can add custom logic here
        default:
          print("📨 Unknown notification type: \(type)")
        }
      }
    }
  }
}
