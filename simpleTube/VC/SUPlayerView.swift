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
    
    let playUrl = "https://www.youtube.com/watch?v=7lCDEYXw3mM"
    let apiURL = "https://www.googleapis.com/youtube/v3/videos?id=7lCDEYXw3mM,ZJUMvQDCunQ&key=AIzaSyCr58GUWUuFoQ2ROgqLWe4i50FLkAqkwVg&part=snippet,contentDetails,statistics,status"
    let listURL = "https://www.googleapis.com/youtube/v3/playlists?id=PLkUN9TXojGuPSVoKpsFTxuABYcZ-cPWz9&key=AIzaSyCr58GUWUuFoQ2ROgqLWe4i50FLkAqkwVg&part=snippet"
    var playerView :YTPlayerView!
    
    var playButton :FFButton!
    var apiReuest = YTVideosRequest()
    var selectedIndex = 0
    var count = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
//        let request = YTVideosRequest()
//        request.id = ["7lCDEYXw3mM","ZJUMvQDCunQ"]
//        request.apiType = .videos
//
//        let apiUrl = request.getFullUrl()
//
//        let webCore = FFWebCore()
//        let result = webCore.getSync(urlStr: apiUrl)
//        if result.success
//        {
//            let jsonResult = FFCore.jsonDeserialization(jsondata: result.data ?? Data())
//            log.info(jsonResult)
            
//            var jsonDic = jsonResult as! Dictionary<String,Any>
//            log.info(jsonDic)
            
//            let sJson = try! JSON(data:result.data ?? Data())
//            log.info(sJson)
//            log.info( sJson["items"][0]["snippet"]["title"])
//
//            for ti in sJson["items"].map({ $0.1["snippet"]["title"]})
//            {
//                log.info(ti)
//            }
            

            
//            playerView.load(withVideoId: "7lCDEYXw3mM")

//            playerView.load(withVideoId: "7lCDEYXw3mM", playerVars: ["playsinline":1])
//            playerView.load(withPlaylistId: "PLkUN9TXojGuPSVoKpsFTxuABYcZ-cPWz9", playerVars: ["playsinline":1])
            
            
            

        
//        }
        
        playerView = YTPlayerView(frame: CGRect(x: 0, y: 60, width: self.view.frame.width, height: 300))
        playerView.delegate = self
        
        self.view.addSubview(playerView)
        
        
        playButton = FFButton(frame: CGRect(x: 0, y: Int(self.view.frame.height) - 100, width: FFButton.defWidth, height: FFButton.defHeight))
        playButton.center.x = self.view.center.x
        playButton.addTarget(self, action: #selector(self.startToPlayView), for: .touchUpInside)
        self.view.addSubview(playButton)
        
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
        log.info(state.rawValue)
        switch state {
        case .paused:
            if UIApplication.shared.applicationState == .background
            {
                self.playerView.playVideo()
            }
            break
        case .ended:
            
            self.playerView.pauseVideo()
            count += 1
            self.playButton.setTitle(count.toString(), for: .normal)
            
        case .queued:
            log.info("queued")
            self.playerView.pauseVideo()
        case .buffering:
            log.info("buffering")
        default:
            break
        }
    }
    
    
    @objc func startToPlayView()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.playerView.playVideo()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
