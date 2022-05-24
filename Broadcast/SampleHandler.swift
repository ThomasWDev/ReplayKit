//
//  SampleHandler.swift
//  Broadcast
//
//  Created by Thomas Woodfin twoodfin@berkeley.edu on 05/22/2022.
//

import ReplayKit

class SampleHandler: RPBroadcastSampleHandler {

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        AgoraReplayKitExt.shareInstance().start(self)
    }
    
    override func broadcastPaused() {
        AgoraReplayKitExt.shareInstance().pause()
    }
    
    override func broadcastResumed() {
        AgoraReplayKitExt.shareInstance().resume()
    }
    
    override func broadcastFinished() {
        AgoraReplayKitExt.shareInstance().stop()
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        AgoraReplayKitExt.shareInstance().push(sampleBuffer, with: sampleBufferType)
    }
}

extension SampleHandler: AgoraReplayKitExtDelegate {
    func broadcastFinished(_ broadcast: AgoraReplayKitExt, reason: AgoraReplayKitExtReason) {
        debugPrint("broadcastFinished:\(reason.rawValue)")
        switch reason {
        case .connectFail:
            let error = NSError(domain: "ConnectFail", code: 0, userInfo: nil)
            finishBroadcastWithError(error)
            break
        case .disconnect:
            let error = NSError(domain: "Disconnect", code: 0, userInfo: nil)
            finishBroadcastWithError(error)
            break
        case .initiativeStop:
            // Pass nil in objc method to avoid showing alert view
            SampleHandlerUtil.finishBroadcast(withNilError: self)
            break
        default: break
        }
    }
}
