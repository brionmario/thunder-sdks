import Flutter
import UIKit
import Thunder

@objc public class ThunderIDFlutterPlugin: NSObject, FlutterPlugin {
    private let handler = ThunderIDMethodHandler()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "dev.thunderid/sdk", binaryMessenger: registrar.messenger())
        let instance = ThunderIDFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        Task {
            await handler.handle(method: call.method, args: args, result: result)
        }
    }
}
