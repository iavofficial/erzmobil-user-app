import UIKit
import Flutter
import MobileCoreServices

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "erzmobil.native/share", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler({
        [weak self](call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        
        guard call.method == "shareLocation" else {
                       result(FlutterMethodNotImplemented)
                       return
                      }
        
        if let args = call.arguments as? Dictionary<String, String>,
           let lat = args["lat"] as? String,
           let lng = args["lng"] as? String {
            self!.shareLocation(latitude: lat, longitude: lng)
            result(nil)
          } else {
            result(FlutterError.init(code: "errorSharePosition", message: "data or format error", details: nil))
          }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    func shareLocation(latitude: String, longitude: String) -> Void{
        if let shareObject = self.activityItems(latitude: latitude, longitude: longitude) {
            let vc = UIActivityViewController(activityItems: shareObject, applicationActivities: nil)
            self.window?.rootViewController?.present(vc, animated: true, completion: nil)
        }
    }
    
    func activityItems(latitude: String, longitude: String) -> [AnyObject]? {
        var items = [AnyObject]()

        let locationTitle : String = "Shared Location"
        let URLString = "https://maps.apple.com?ll=\(latitude),\(longitude)"

        if let url = NSURL(string: URLString) {
            items.append(url)
        }

        let locationVCardString = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "PRODID:-",
            "N:;\(locationTitle);;;",
            "FN:\(locationTitle)",
            "item1.URL;type=pref:\(URLString)",
            "item1.X-ABLabel:map url",
            "END:VCARD"
            ].joined(separator:"\n")

        guard let vCardData = locationVCardString.data(using: String.Encoding.utf8) else {
            return nil
        }

        let vCardActivity = NSItemProvider(item: vCardData as NSSecureCoding, typeIdentifier: kUTTypeVCard as String)

        items.append(vCardActivity)

        //items.append(locationTitle)

        return items
    }
}
