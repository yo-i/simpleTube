//
//  FFApplication.swift
//  Tiamat
//
//  Created by yo_i on 2018/03/15.
//  Copyright © 2018年 Open Resource Corporation. All rights reserved.
//

import UIKit
///参考:https://blog.gaelfoppolo.com/detecting-user-inactivity-in-ios-application-684b0eeeef5b
///UIApplicationから継承、runloopを監視
class FFApplication: UIApplication
{
    override init()
    {
        super.init()
        NSLog("FFApplication")
    }
    
    
    // the timeout in seconds, after which should perform custom actions
    // such as disconnecting the user
    private var timeoutInSeconds: TimeInterval {
        // 5 hours
        return 5 * 60 * 60
    }
    
    private var idleTimer: Timer?
    
    // resent the timer because there was user interaction
    private func resetIdleTimer() {
        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }
        
        idleTimer = Timer.scheduledTimer(timeInterval: timeoutInSeconds,
                                         target: self,
                                         selector: #selector(FFApplication.timeHasExceeded),
                                         userInfo: nil,
                                         repeats: false
        )
    }
    
    // if the timer reaches the limit as defined in timeoutInSeconds, post this notification
    @objc private func timeHasExceeded() {
        NSLog(#function)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "app.appTimeout"),
                                        object: nil
        )
    }
    
    
    /// 全てのイベントを監視し、何かイベントがあったら、タイマーをリセット
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        if idleTimer != nil {
            self.resetIdleTimer()
        }
        
        if let touches = event.allTouches {
            for touch in touches where touch.phase == UITouchPhase.began {
                self.resetIdleTimer()
            }
        }
    }
}
