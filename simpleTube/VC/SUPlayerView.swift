//
//  SUPlayerView.swift
//  simpleTube
//
//  Created by yo_i on 2019/08/29.
//  Copyright © 2019年 yang. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import SwiftyJSON



class SUPlayerView: FFBaseMainViewController ,YTPlayerViewDelegate{
    

    var playerView :YTPlayerView!
    
    var apiReuest = YTVideosRequest()
    var selectedIndex = 0
    var count = 0
    var nowState:YTPlayerState = .unknown

    var videosIds:Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        playerView = YTPlayerView(frame: CGRect(x: 0, y: 60, width: self.view.frame.width, height: 300))
        playerView.delegate = self
        self.view.addSubview(playerView)
        self.playerView.load(withVideoId: apiReuest.id[selectedIndex], playerVars: ["playsinline":1])

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        log.info(#function)
        self.playerView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        
        
//       YTPlayerState
//         {
//            kYTPlayerStateUnstarted,
//            kYTPlayerStateEnded,
//            kYTPlayerStatePlaying,
//            kYTPlayerStatePaused,
//            kYTPlayerStateBuffering,
//            kYTPlayerStateQueued,
//            kYTPlayerStateUnknown
//        };
//
        log.info(state)
        switch state {
        case .paused:
            if UIApplication.shared.applicationState == .background
            {
                if (UIApplication.shared.delegate as! AppDelegate).backgroudOnceFlag && self.nowState == .playing
                {
                    self.playerView.playVideo()
                    (UIApplication.shared.delegate as! AppDelegate).backgroudOnceFlag = false
                }
            }

            
            break
        case .ended:
            self.playerView.playVideo()
        case .queued:
            log.info("queued")
            self.playerView.playVideo()
        case .buffering:
            log.info("buffering")
        default:
            break
        }
        nowState = state
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
