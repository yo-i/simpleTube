//
//  FFBadge.swift
//  Artemis
//
//  Created by Actus_03 on 2017/12/04.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

class FFBadge : UILabel
{
    var count : Int = 0                                 //件数
    var notificationCenter : NotificationCenter!        //通知
    var name : String!                                  //通知の名前（更新するバッジ指定）
    var bgColor : UIColor!                              //バッジのカラー
    

    
    /// 初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - name: 通知の名前（更新するバッジ指定）
    convenience init(frame: CGRect,name : String) {
        self.init(frame: frame, name: name, backgroundColor: UIColor.badgeColor
        )
    }

    /// 初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - name: 通知の名前
    ///   - backgroundColor: バッジのバックカラー
    init(frame: CGRect,name : String,backgroundColor: UIColor)
    {
        super.init(frame: frame)
        self.name = name
        self.bgColor = backgroundColor
        //通知の設定
        notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.updateCount), name: NSNotification.Name(self.name), object: nil)
        setSelfStyle()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelfStyle()
    {
        //自分の設定
        self.backgroundColor = self.bgColor
        self.textAlignment = .center
        self.font = FFFont.systemFontOfSize(18)
        self.textColor = UIColor.white
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.width / 2
        self.text = count.description
        
        //初期値０なら非表示
        let _ = isZero()
    }
    
    
    /// バッジ件数更新
    ///
    /// - Parameter notification: 通知
    @objc func updateCount(notification : Notification)
    {
        self.count = notification.userInfo!["count"] as! Int
        if !isZero()
        {
            self.text = count.description
            if count > 99
            {
                self.text = "99"
            }
            bumpAnimation()
        }
        else
        {
            return
        }
        
    }
    
    /// 件数チェック
    ///
    /// - Returns: ０ならtrue
    func isZero() -> Bool
    {
        //０件の場合バッジ非表示
        if count <= 0
        {
            self.isHidden = true
            return true
        }
        else
        {
            self.isHidden = false
            return false
        }
        
    }
    //通知の際のアニメーション
    func bumpAnimation()
    {
        UIView.animate(withDuration: 0.1, animations: {self.center.y -= 10}, completion: { finished in
            UIView.animate(withDuration: 0.1, animations: {self.center.y += 10}, completion: { finished in
                UIView.animate(withDuration: 0.1, animations: {self.center.y -= 5}, completion: { finished in
                    UIView.animate(withDuration: 0.1, animations: {self.center.y += 5}, completion: nil)
                })
            })
        })
    }
    
}
