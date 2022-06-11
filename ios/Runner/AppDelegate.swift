import UIKit
import Flutter
import GoogleMaps
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GMSServices.provideAPIKey("AIzaSyAMaQbpp9zQ2cNnvTezTK-Zi1b7OAz6pIk")

    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 10.0, *){
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }


    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}