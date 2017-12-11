//
//  CallViewController+Explorer.swift
//  sample-videochat-webrtc
//
//  Created by Vladyslav Poznyak on 12/8/17.
//  Copyright © 2017 QuickBlox Team. All rights reserved.
//

import UIKit
import AVKit

extension CallViewController {
    @IBAction func unwindToConference(_ segue: UIStoryboardSegue) {
        if let explorer = segue.source as? ExploreVideoViewController {
            if let video = explorer.selectedVideo {
                let asset = AVAsset(url: video)
                let item = AVPlayerItem(asset: asset)
                let player = AVPlayer(playerItem: item)
                playerVC.player = player
                player.play()
            }
        }
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playerEmbeded" {
            playerVC = segue.destination as? AVPlayerViewController
        }
    }
}
