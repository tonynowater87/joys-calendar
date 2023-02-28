import UIKit
import Flutter
import OpenCC

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let openCcChannel = FlutterMethodChannel(name: "joyscalendar.opencc",
                                               binaryMessenger: controller.binaryMessenger)
      openCcChannel.setMethodCallHandler({
        // This method is invoked on the UI thread.
          [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            // This method is invoked on the UI thread.
            guard call.method == "convertToTraditionalChinese" else {
              result(FlutterMethodNotImplemented)
              return
            }
          
          let args = call.arguments as! Dictionary<String, Any>
          let input = args["input"] as! String
          let output = self?.convertByOpenCC(input: input)
          if output == nil || output?.isEmpty == true {
              result(FlutterError(code: "UNAVAILABLE",
                           message: "Can't convert, input=\(input), method=\(call.method)",
                           details: nil))
          } else {
              result(String(output!))
          }
      })

      GeneratedPluginRegistrant.register(with: self)
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func convertByOpenCC(input: String) -> String {
        let converter = try! ChineseConverter(options: [.traditionalize, .twStandard, .twIdiom])
        let output = converter.convert(input)
        return output
    }
 }
