#if canImport(Flutter)
import Flutter
#elseif canImport(FlutterMacOS)
import FlutterMacOS
#endif

public class BiometricStoragePlugin: NSObject, FlutterPlugin {
  private let impl = BiometricStorageImpl(storageError: { (code, message, details) -> Any in
    FlutterError(code: code, message: message, details: details)
  }, storageMethodNotImplemented: FlutterMethodNotImplemented)

  public static func register(with registrar: FlutterPluginRegistrar) {
#if canImport(Flutter)
    let channel = FlutterMethodChannel(name: "biometric_storage", binaryMessenger: registrar.messenger())
#elseif canImport(FlutterMacOS)
    let channel = FlutterMethodChannel(name: "biometric_storage", binaryMessenger: registrar.messenger)
#endif
    let instance = BiometricStoragePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    impl.handle(StorageMethodCall(method: call.method, arguments: call.arguments), result: result)
  }
}
