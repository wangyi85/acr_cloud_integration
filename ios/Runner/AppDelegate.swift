import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
	var audioRecorder: AVAudioRecorder?

	override func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		GeneratedPluginRegistrant.register(with: self)

		let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

		let deviceChannel = FlutterMethodChannel(name: "it.chartmusic.radiomonitor/iOS", binaryMessenger: controller.binaryMessenger)

		// prepareMethodHandler(deviceChannel: deviceChannel)
		deviceChannel?.setMethodCallHandler(onMethodCall)

		SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback(registerPlugins)
		if #available(iOS 10.0, *) {
			UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
			setupAudioSession()
		}

		return super.application(application, didFinishLaunchingWithOptions: launchOptions)
	}

	private func prepareMethodHandler(deviceChannel: FlutterMethodChannel) {
        
        deviceChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            if call.method == "startRecording" {  
				print("startRecording channel")
                self.startRecording()
            }
            else {
                result(FlutterMethodNotImplemented)
                return
            }
            
        })
    }

	private func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if call.method == "startRecording" {
			print("startRecording channel")
			startRecording()
		}
		else {
			result(FlutterMethodNotImplemented)
		}
	}

	func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSession.Category.playAndRecord,
                mode: AVAudioSession.Mode.default,
                options: [
                    AVAudioSession.CategoryOptions.duckOthers
                ]
            )
            try! AVAudioSession.sharedInstance().setActive(true)
                
            //<<try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }
	
    func startRecording() {
		let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

		let settings = [
			AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
			AVSampleRateKey: 44100,
			AVNumberOfChannelsKey: 2,
			AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
		] as [String : Any]

		do {
			audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
			audioRecorder?.record()
		} catch {
			print("Error recording audio: \(error.localizedDescription)")
		}
	}
        
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}

    override func applicationWillResignActive(_ application: UIApplication) {
		// This method is called when the app is about to move from active to inactive state.
		// Set up the audio session when the app enters the background.
		startRecording()
	}
}

func registerPlugins(registry: FlutterPluginRegistry) {
  	GeneratedPluginRegistrant.register(with: registry)
}
