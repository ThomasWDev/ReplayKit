//
//  ScreenSharingViewController.swift
//  ScreenSharing
//
//  Created by Thomas Woodfin twoodfin@berkeley.edu on 05/22/2022.
//

import UIKit
import ReplayKit
import AGEVideoLayout
import AgoraRtcKit
import AGEVideoLayout

class ScreenSharingViewController: UIViewController {
    
    @IBOutlet weak var infoContainerView: UIView!
    
    private var localVideoView = Bundle.loadView(fromNib: "VideoView", withType: VideoView.self)
    private var remoteVideoView = Bundle.loadView(fromNib: "VideoView", withType: VideoView.self)
    
    private var isJoined: Bool = false
    private var isScreenSharing: Bool = false
    private var agoraKit: AgoraRtcEngineKit!
    private var screenCaptureParams: AgoraScreenCaptureParameters2?
    
    public var configs: [String : Any] = [:]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        guard let channelName = configs["channelName"] as? String else {
            return
        }

        let config = AgoraRtcEngineConfig()
        config.appId = "530490d0e19b4c5994c0b42e7c68ce19"
        config.areaCode = AgoraAreaCode.GLOB.rawValue
        
        let logConfig = AgoraLogConfig()
        logConfig.level = .info
        config.logConfig = logConfig
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        
        agoraKit.setChannelProfile(.liveBroadcasting)
        agoraKit.setClientRole(.broadcaster)
        
        agoraKit.enableVideo()
        agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: CGSize(width: 1280, height: 720),
                frameRate: AgoraVideoFrameRate.fps30,
                bitrate: AgoraVideoBitrateStandard,
                orientationMode: AgoraVideoOutputOrientationMode.adaptative))
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.view = localVideoView.videoView
        videoCanvas.renderMode = .hidden
        agoraKit.setupLocalVideo(videoCanvas)
        
        // Set audio route to speaker
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        agoraKit.setAudioProfile(.default, scenario: .gameStreaming)
        
        let option = AgoraRtcChannelMediaOptions()
        let result = agoraKit.joinChannel(byToken: "006530490d0e19b4c5994c0b42e7c68ce19IADPdWaJfPthGf5EfSoS9qlpGEekabitjQPwzXtGAsNxrWQucoQAAAAAEAB9OJJ5s52MYgEAAQCznYxi", channelId: channelName, info: nil, uid: 0, options: option)
        if result != 0 {
            self.showAlert(title: "Error", message: "joinChannel call failed: \(result), please check your params.")
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            if isJoined {
                agoraKit.leaveChannel { (stats) -> Void in
                    debugPrint("Left channel, duration: \(stats.duration)")
                }
            }
        }
    }
    
    func setupUI() {
        localVideoView.setPlaceholder(text: "Local Host")
        remoteVideoView.setPlaceholder(text: "Remote Host")
        let screenBounds = UIScreen.main.bounds
        let width = screenBounds.width / 4.0
        remoteVideoView.frame = CGRect(x: 0, y: 0, width: screenBounds.width, height: screenBounds.height)
        localVideoView.frame = CGRect(x: screenBounds.width - width - 10, y: 90, width: width, height: width * 4 / 2)
        self.view.addSubview(remoteVideoView)
        self.view.addSubview(localVideoView)
        self.view.bringSubviewToFront(infoContainerView)
        updateButtonTitle()
    }
    
    func showAlert( title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    @IBAction func startShareBtnClick(_ sender: Any) {
        
        if isScreenSharing {
            agoraKit.stopScreenCapture()
        } else {
            if screenCaptureParams == nil {
                let screenParams = AgoraScreenCaptureParameters2()
                screenParams.captureAudio = true
                screenParams.captureVideo = true
                
                let videoParams = AgoraScreenVideoParameters()
                videoParams.dimensions = CGSize(width: 0, height: 0)
                videoParams.frameRate = 30
                screenParams.videoParams = videoParams;
                screenCaptureParams = screenParams
            }
            agoraKit.startScreenCapture(screenCaptureParams!)
            
            let pickerView = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y:0, width: 50, height: 50))
            if let url = Bundle.main.url(forResource: "Broadcast", withExtension: "appex", subdirectory: "PlugIns") {
                if let bundle = Bundle(url: url) {
                    pickerView.preferredExtension = bundle.bundleIdentifier
                    pickerView.showsMicrophoneButton = false
                    
                    // Auto click RPSystemBroadcastPickerView
                    for view in pickerView.subviews {
                        let startButton = view as! UIButton
                        startButton.sendActions(for: .allTouchEvents)
                    }
                }
            }
        }
    }
    
    func startScreenCapture() {
        isScreenSharing = true
        localVideoView.isHidden = true
        remoteVideoView.isHidden = true
        infoContainerView.isHidden = false
        
        updateButtonTitle()
    }
    
    func stopScreenCapture() {
        screenCaptureParams = nil
        isScreenSharing = false
        localVideoView.isHidden = false
        remoteVideoView.isHidden = false
        infoContainerView.isHidden = true
        
        agoraKit.setVideoSource(AgoraRtcDefaultCamera())
        updateButtonTitle()
    }
    
    func updateButtonTitle() {
        let title = (screenCaptureParams != nil) ? "⏹ Screen Sharing" : "▶ Screen Sharing"
        let rightBarButton = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(startShareBtnClick))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
}

/// agora rtc engine delegate events @available(iOS 12.0, *)
extension ScreenSharingViewController: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        isJoined = true
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
    
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        // the view to be binded
        videoCanvas.view = remoteVideoView.videoView
        videoCanvas.renderMode = .fill
        agoraKit.setupRemoteVideo(videoCanvas)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        // the view to be binded
        videoCanvas.view = nil
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, localVideoStateChange state: AgoraLocalVideoStreamState, error: AgoraLocalVideoStreamError) {
        
        switch error {
        case .extensionCaptureStarted:
            startScreenCapture()
            break
        case .extensionCaptureStoped:
            stopScreenCapture()
            break
        case .extensionCaptureDisconnected:
            stopScreenCapture()
            break
        default: break
        }
    }
}
