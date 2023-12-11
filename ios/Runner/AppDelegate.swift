import UIKit
import Flutter
import AVFoundation
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var audioRecorder: AVAudioRecorder?
    var isBackground: Bool = false

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }

        SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback(registerPlugins)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            setupAudioSession()
            let flutterViewController: FlutterViewController = window?.rootViewController as! FlutterViewController

            let channel = FlutterMethodChannel(name: "app_state", binaryMessenger: flutterViewController.binaryMessenger)
            channel.setMethodCallHandler({
                [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
                // Handle method calls from Dart here
                if call.method == "appState" {
                    let state = call.arguments as! String
                    print ("APPSTATE")
                    print (state)
                    if state == "background" {
                        self?.isBackground = true
                    } else if state == "stopped" {
                        self?.isBackground = false
                    }
                }
            })
        }

        // Observe audio interruptions
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.duckOthers]
            )
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }
    @objc func startRecordingIfNeeded() {
        print ("isBackground?")
        print(isBackground)
        if (isBackground == true) {
            
            startRecording()
        }
        else {
            stopRecording()
        }
    }
    @objc func stopRecording() {
        if let audioRecorder = audioRecorder, audioRecorder.isRecording {
            audioRecorder.stop()
        }
    }

    @objc func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 22050,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
        } catch {
            print("Error recording audio: \(error.localizedDescription)")
        }
    }
    
    @objc func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        switch type {
        case .began:
            // Handle interruption began
            if let audioRecorder = audioRecorder, audioRecorder.isRecording {
                audioRecorder.pause()
            }
        case .ended:
            // Handle interruption ended
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            
            if options.contains(.shouldResume), let audioRecorder = audioRecorder {
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    audioRecorder.record()
                } catch {
                    print("Error resuming recording: \(error.localizedDescription)")
                }
            }
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func applicationWillResignActive(_ application: UIApplication) {
        startRecordingIfNeeded()
     
    }


}
func registerPlugins(registry: FlutterPluginRegistry) {
    GeneratedPluginRegistrant.register(with: registry)
}
