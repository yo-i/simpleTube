//
//  FFNumPad.swift
//  Artemis
//
//  Created by yo_i on 2017/12/01.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import UIKit

//iPod ~74 iPad 95
fileprivate let BUTTON_WIDTH  = 74
fileprivate let BUTTON_HEIGHT = 55
fileprivate let BUTTON_PLAIN = 2

//数字キー以外の機能キーの用
enum FFNumPadKeyType:Int
{
    case doubleZero = 100
    case clear      = 101
    case backSpace  = 102
    case enter      = 103
    case dot        = 104
}

//テンキー用のボタン
class FFNumPadKeyButton:FFButton
{
    var keyCode:Int? = nil
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}


/// テンキータイプ
///
/// - withEnterKey: 確定キー付き
/// - withOutEnterKey: 確定キーなし
enum FFNumPadType
{
    case withEnterKey
    case withOutEnterKey
    case withDot
}

class FFNumPad:UIView
{
    /// テンキータイプ
    var numPadType:FFNumPadType = .withDot
    /// キー押された時の通知名
    static let notificationName = "FFNumberPad.key.click"
    var notifinTarget:Any?
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.frame.size = CGSize(width: BUTTON_WIDTH * 4 + BUTTON_PLAIN * 3
            , height: BUTTON_HEIGHT * 4 + BUTTON_PLAIN * 3)
        setNumPadButtons()
    }
    
    init(frame: CGRect,type:FFNumPadType)
    {
        self.numPadType = type
        super.init(frame: frame)
        self.frame.size = CGSize(width: BUTTON_WIDTH * 4 + BUTTON_PLAIN * 3
            , height: BUTTON_HEIGHT * 4 + BUTTON_PLAIN * 3)
        setNumPadButtons()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    /// 画面レイアウト
    private func setNumPadButtons()
    {
        //数字キー
        setNumKeys()
        
        //数字以外のキー
        switch self.numPadType
        {
        case .withEnterKey,.withDot:
            setNumPayWithEnterKey()
        case .withOutEnterKey:
            setNumPayWithOutEnterKey()
        }
    }
    
    //数字のkeyレイアウト
    private func setNumKeys()
    {
        for i in 0...8
        {
            let keyCode = (7 - ( i / 3) * 3 + ( i % 3) )
            let px = BUTTON_WIDTH * (i % 3) + BUTTON_PLAIN * (i % 3)
            let py = BUTTON_HEIGHT * (i / 3) + BUTTON_PLAIN * (i / 3)
            let rect = CGRect(x: px, y: py, width: BUTTON_WIDTH, height: BUTTON_HEIGHT)
            let key = FFNumPadKeyButton(frame: rect, title: keyCode.toString())
            key.type = .subProcess
            key.keyCode = keyCode
            key.backgroundColor = UIColor.lightGray
            key.addTarget(self, action: #selector(self.clickButton(_:)), for: .touchDown)
            self.addSubview(key)
        }
        
        let wildRect = CGRect(x: 0
            , y: BUTTON_HEIGHT * 3 + BUTTON_PLAIN * 3
            , width: BUTTON_WIDTH * 2 + BUTTON_PLAIN
            , height: BUTTON_HEIGHT)
        let zeroKey = FFNumPadKeyButton(frame: wildRect, title: 0.toString())
        zeroKey.type = .subProcess
        zeroKey.keyCode = 0
        zeroKey.backgroundColor = UIColor.lightGray
        zeroKey.addTarget(self, action: #selector(self.clickButton(_:)), for: .touchDown)
        self.addSubview(zeroKey)
        
        if self.numPadType == .withDot
        {
            let keyRect = CGRect(x: BUTTON_WIDTH * 2 + BUTTON_PLAIN * 2
                , y: BUTTON_HEIGHT * 3 + BUTTON_PLAIN * 3
                , width: BUTTON_WIDTH
                , height: BUTTON_HEIGHT)
            let dotKey = FFNumPadKeyButton(frame: keyRect, title: ".")
            dotKey.type = .subProcess
            dotKey.backgroundColor = UIColor.lightGray
            dotKey.keyCode = FFNumPadKeyType.dot.rawValue
            dotKey.addTarget(self, action: #selector(self.clickButton(_:)), for: .touchDown)
            self.addSubview(dotKey)
        }
        else
        {
            let keyRect = CGRect(x: BUTTON_WIDTH * 2 + BUTTON_PLAIN * 2
                , y: BUTTON_HEIGHT * 3 + BUTTON_PLAIN * 3
                , width: BUTTON_WIDTH
                , height: BUTTON_HEIGHT)
            let doubleZeroKey = FFNumPadKeyButton(frame: keyRect, title: "00")
            doubleZeroKey.type = .subProcess
            doubleZeroKey.backgroundColor = UIColor.lightGray
            doubleZeroKey.keyCode = FFNumPadKeyType.doubleZero.rawValue
            doubleZeroKey.addTarget(self, action: #selector(self.clickButton(_:)), for: .touchDown)
            self.addSubview(doubleZeroKey)
        }
        
    }
    
    //タイプ別画面レイアウト
    private func setNumPayWithEnterKey()
    {
        let cKeyRect = CGRect(x: BUTTON_WIDTH * 3 + BUTTON_PLAIN * 3
            , y: BUTTON_HEIGHT * 0 + BUTTON_PLAIN * 0
            , width: BUTTON_WIDTH
            , height: BUTTON_HEIGHT)
        let cKey = FFNumPadKeyButton(frame: cKeyRect, title: "C")
        cKey.type = .manual
        cKey.backgroundColor = UIColor.actusBlue
        cKey.keyCode = FFNumPadKeyType.clear.rawValue
        cKey.addTarget(self, action: #selector(self.clickButton(_:)), for: .touchDown)
        self.addSubview(cKey)
        
        let bsKeyRect = CGRect(x: BUTTON_WIDTH * 3 + BUTTON_PLAIN * 3
            , y: BUTTON_HEIGHT * 1 + BUTTON_PLAIN * 1
            , width: BUTTON_WIDTH
            , height: BUTTON_HEIGHT)
        let bsKey = FFNumPadKeyButton(frame: bsKeyRect, title: "BS")
        bsKey.type = .manual
        bsKey.backgroundColor = UIColor.actusBlue
        bsKey.keyCode = FFNumPadKeyType.backSpace.rawValue
        bsKey.addTarget(self, action: #selector(self.clickButton(_:)), for: .touchDown)
        self.addSubview(bsKey)
        
        let enterKeyRect = CGRect(x: BUTTON_WIDTH * 3 + BUTTON_PLAIN * 3
            , y: BUTTON_HEIGHT * 2 + BUTTON_PLAIN * 2
            , width: BUTTON_WIDTH
            , height: BUTTON_HEIGHT * 2 + BUTTON_PLAIN * 1)
        let enterKey = FFNumPadKeyButton(frame: enterKeyRect, title: "確定")
        enterKey.type = .manual
        enterKey.keyCode = FFNumPadKeyType.enter.rawValue
        enterKey.backgroundColor = UIColor.darkGray
        enterKey.addTarget(self, action: #selector(self.clickButton(_:)), for: .touchDown)
        self.addSubview(enterKey)
    }
    
    //タイプ別画面レイアウト
    private func setNumPayWithOutEnterKey()
    {
        let cKeyRect = CGRect(x: BUTTON_WIDTH * 3 + BUTTON_PLAIN * 3
            , y: BUTTON_HEIGHT * 0 + BUTTON_PLAIN * 0
            , width: BUTTON_WIDTH
            , height: BUTTON_HEIGHT * 2 + BUTTON_PLAIN * 1)
        let cKey = FFNumPadKeyButton(frame: cKeyRect, title: "C")
        cKey.type = .manual
        cKey.backgroundColor = UIColor.actusBlue
        cKey.keyCode = FFNumPadKeyType.clear.rawValue
        cKey.addTarget(self, action: #selector(self.clickButton(_:)), for: .touchDown)
        self.addSubview(cKey)
        
        let bsKeyRect = CGRect(x: BUTTON_WIDTH * 3 + BUTTON_PLAIN * 3
            , y: BUTTON_HEIGHT * 2 + BUTTON_PLAIN * 2
            , width: BUTTON_WIDTH
            , height: BUTTON_HEIGHT * 2 + BUTTON_PLAIN * 1)
        let bsKey = FFNumPadKeyButton(frame: bsKeyRect, title: "BS")
        bsKey.type = .manual
        bsKey.backgroundColor = UIColor.actusBlue
        bsKey.keyCode = FFNumPadKeyType.backSpace.rawValue
        bsKey.addTarget(self, action: #selector(self.clickButton(_:)), for: .touchDown)
        self.addSubview(bsKey)
    }
    
    
    /// キーの通知
    ///
    /// - Parameter sender: 通知発行センダー
    @objc private func clickButton(_ sender:FFNumPadKeyButton)
    {
        if sender.keyCode == nil
        {
            return
        }
        let clickInfo = ["keyCode":sender.keyCode!]
        let clickNotification = Notification(name: Notification.Name(rawValue: FFNumPad.notificationName), object: notifinTarget, userInfo: clickInfo)
        NotificationCenter.default.post(clickNotification)
    }
    
    
}

