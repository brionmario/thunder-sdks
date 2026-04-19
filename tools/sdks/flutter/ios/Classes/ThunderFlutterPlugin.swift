import Flutter
import UIKit
import Thunder

@objc public class ThunderFlutterPlugin: NSObject, FlutterPlugin {
    private let handler = ThunderMethodHandler()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "io.thunder/sdk", binaryMessenger: registrar.messenger())
        let instance = ThunderFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        Task {
            await handler.handle(method: call.method, args: args, result: result)
        }
    }
}
