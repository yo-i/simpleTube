//
//  FFAlert.swift
//  Artemis
//
//  Created by yo_i on 2017/12/04.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

enum FFAlertType
{
    case info
    case error
    case warning
    case question
    case undefined
}


/// アラート
class FFAlert:UIViewController
{
    var strongSelf:FFAlert?         //強参照(所有権は自分自身にある、画面に依存しない)
    var contentView = UIView()      //コンテンツビュー
    
    var titleLabel:FFLabel!         //タイトル
    var iconImageView:UIImageView!  //アイコン
    var messageLabel:FFLabel!
    
    
    var yesButton:FFButton!         //結果trueのボタン
    var noButton:FFButton!          //結果falseのボタン
    
    var result:Bool? = nil          //結果
    
    var alertType:FFAlertType = .undefined                  //アラートタイプ
    var userAction:((_ isYesButton: Bool) -> Void)? = nil   //結果クロージャー
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
        self.view.frame = UIScreen.main.bounds
        self.view.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 100)
        self.view.addSubview(contentView)
        
        //Retaining itself strongly so can exist without strong refrence
        strongSelf = self
    }
    
    required public init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// コンテンツを乗せるView
    fileprivate func setContentView() {
        contentView.frame.size = CGSize(width: 300, height: 230)
        contentView.center = self.view.center
        contentView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.backgroundColor = UIColor(red: 255, green: 255, blue: 255)
        contentView.layer.borderColor = UIColor(red: 204, green: 204, blue: 204).cgColor
        view.addSubview(contentView)
    }
    
    
    /// タイトル
    fileprivate func setTitleLabel()
    {
        titleLabel = FFLabel(frame: CGRect(x: 5, y: 2, width: 300 - 10, height: 48))
        titleLabel.layer.cornerRadius = 5.0
        titleLabel.layer.masksToBounds = true
        titleLabel.text = ""
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.font = FFFont.systemFontOfSize(25)
        titleLabel.textColor = UIColor(red: 87, green: 87, blue: 87)
        
        switch self.alertType
        {
        case .info:
            titleLabel.backgroundColor = UIColor.alertInfo
        case .error:
            titleLabel.backgroundColor = UIColor.alertError
        case .question:
            titleLabel.backgroundColor = UIColor.alertQuestion
        case .warning:
            titleLabel.backgroundColor = UIColor.alertWarning
        case .undefined:
            break
        }
        
        self.contentView.addSubview(titleLabel)
    }
    
    
    /// メッセージ領域
    fileprivate func setMessageLable()
    {
        messageLabel = FFLabel(frame: CGRect(x: 20, y: 50, width: 260, height: 120))
        messageLabel.text = ""
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = FFFont.systemFontOfSize()
        self.contentView.addSubview(messageLabel)
    }
    
    /// アラートアイコン
    fileprivate func setIconImageView()
    {
        var iconName = ""
        switch self.alertType
        {
        case .info:
            iconName = "alert_icon_01.png"
        case .error:
            iconName = "alert_icon_04.png"
        case .question:
            iconName = "alert_icon_02.png"
        case .warning:
            iconName = "alert_icon_03.png"
        case .undefined:
            break
        }
        
        let image = UIImage(named: iconName)
        iconImageView = UIImageView(frame: CGRect(x: 20, y: 50, width: 120, height: 120))
        iconImageView.image = image
        self.contentView.addSubview(iconImageView)
        self.contentView.sendSubview(toBack: iconImageView)
    }
    
    //true回答ボタン
    fileprivate func setYesButton()
    {
        yesButton = FFButton(frame: CGRect(x: 160, y: 185, width: 120, height: 40))
        yesButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        yesButton.type = .manual
        yesButton.backgroundColor = UIColor.darkGray
        self.contentView.addSubview(yesButton)
    }
    //false回答ボタン
    fileprivate func setNoButton()
    {
        noButton = FFButton(frame: CGRect(x: 20, y: 185, width: 120, height: 40))
        noButton.backgroundColor = UIColor.darkGray
        noButton.type = .manual
        noButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        self.contentView.addSubview(noButton)
    }
    
    
    /// アラート閉じる
    ///
    /// - Parameter sender: イベントセンダー
    @objc fileprivate func dismissAlert(sender:FFButton)
    {
        if sender.isEqual(yesButton)
        {
            self.result = true
        }
        else
        {
            self.result = false
        }
        
        //アニメション処理
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.alpha = 0
            //透明まで変換
            self.contentView.alpha = 0
            //大きさ1.2倍まで変換
            self.contentView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
        }, completion: { (_) -> Void in
            
            self.view.removeFromSuperview()
            self.cleanUpAlert()
            self.strongSelf = nil
            
            if self.userAction !=  nil
            {
                self.userAction!(self.result!)
            }
        })
    }
    
    //後処理
    fileprivate func cleanUpAlert()
    {
        self.contentView.removeFromSuperview()
        self.contentView = UIView()
    }
    
    //結果を待つ
    @discardableResult
    public func waitForAlert()->Bool
    {
        //結果を押すまでロック
        while self.result == nil
        {
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return self.result!
    }
    
    //MARK: - 表示メッソド
    
    
    /// アラートの表示
    ///
    /// - Parameters:
    ///   - messageId: メッセージID
    ///   - withNoButton: false結果ボタン表示非表示 省略可、デフォルトfalse
    ///   - replacTargets: {0}など置換の文字列配列 省略可、デフォルト０要素の配列
    ///   - yesButtonTitle: true結果ボタンタイトル 省略可、デフォルトOK
    ///   - noButtonTitle: false結果ボタンタイトル 省略可、デフォルトCancel
    ///   - action: コールバック 省略可、デフォルトnil
    ///   - replacMessage: 書き換えメッセージ用　省略可、デフォルト空
//    public func showAlert(_ messageId:String
//        ,withNoButton: Bool = false
//        ,replacTargets:[String] = []
//        ,yesButtonTitle: String = "OK"
//        ,noButtonTitle: String = "Cancel"
//        ,action: ((_ isOtherButton: Bool) -> Void)? = nil
//        ,replacMessage:String = "")
//    {
//        log.info("show Alert messageId:" + messageId)
//        let selectResult = alertMessageDao.select(messageId: messageId)
//        if selectResult.count > 0
//        {
//            //メッセージマスターと連携
//            let resigedMessage = selectResult.first
//            var msgString = resigedMessage!["mainvalue"] ?? ""
//            var msgType:FFAlertType = .undefined
//            switch resigedMessage!["subvalue"]!
//            {
//            case "I":
//                msgType = .info
//            case "Q":
//                msgType = .question
//            case "W":
//                msgType = .warning
//            case "E":
//                msgType = .error
//            default:
//                msgType = .undefined
//            }
//
//            //｛0｝など置換
//            for (index,replacStr) in replacTargets.enumerated()
//            {
//                msgString = msgString.replace(of: "{\(index)}", with: replacStr)
//            }
//
//            //; = >改行に置換
//            msgString = msgString.replace(of: ";", with: "\n")
//
//            //replaceMessageが空でなければ表示するメッセージを置き換える
//            if replacMessage != ""{msgString = replacMessage}
//            self.showAlert(""
//                , messageId: messageId
//                , message: msgString
//                , type: msgType
//                , withNoButton: withNoButton
//                , yesButtonTitle: yesButtonTitle
//                , noButtonTitle: noButtonTitle
//                , action: action)
//        }
//        else
//        {
//            //replaceメッセージがあった場合
//            if replacMessage != ""
//            {
//                self.showAlert("未登録メッセージ: " + messageId, message: replacMessage
//                    , type: .undefined, withNoButton: withNoButton
//                    , yesButtonTitle: yesButtonTitle, noButtonTitle: noButtonTitle
//                    , action: action)
//            }
//            else
//            {
//                self.showAlert("未登録メッセージ: " + messageId, message: "該当メッセージ(" + messageId + ")は登録されていません。"
//                    , type: .undefined, withNoButton: withNoButton
//                    , yesButtonTitle: yesButtonTitle, noButtonTitle: noButtonTitle
//                    , action: action)
//            }
//        }
//
//    }
//
    
    
    /// アラート表示
    ///
    /// - Parameters:
    ///   - title: アラートタイトル
    ///   - messageId: エラー時表示用メッセージID
    ///   - message: アラートメッセージ
    ///   - type: アラートタイプ
    ///   - withNoButton: false返答ボタン表示非表示
    ///   - yesButtonTitle: true返答ボタン文字 デフォルト はい
    ///   - noButtonTitle: false返答ボタン文字 デフォルト いいえ
    ///   - action: 結果クロージャー
    public func showAlert(_ title: String = ""
        ,messageId:String = ""
        ,message:String
        ,type:FFAlertType
        ,withNoButton: Bool
        ,yesButtonTitle: String = "OK"
        ,noButtonTitle: String = "Cancel"
        ,action: ((_ isOtherButton: Bool) -> Void)? = nil)
    {
        userAction = action
        let window: UIWindow = UIApplication.shared.keyWindow!
        window.addSubview(view)
        window.bringSubview(toFront: view)
        view.frame = window.bounds
        
        self.alertType = type
        
        //コンテンツセット
        self.setContentView()
        self.setTitleLabel()
        self.setMessageLable()
        self.setIconImageView()
        
        //タイトル反映
        if title == ""
        {
            switch self.alertType
            {
            case .info:
                self.titleLabel.text = "インフォメーション"
            case .error:
                self.titleLabel.text = "エラー"
            case .question:
                self.titleLabel.text = "質問"
            case .warning:
                self.titleLabel.text = "ワーニング"
            case .undefined:
                break
            }
        }
        else
        {
            self.titleLabel.text = title
        }
        
        //エラーの場合メッセージの先頭にメッセージIDを太文字で表示
        if self.alertType == .error
        {
            //メッセージを反映
            self.messageLabel.text = messageId + "\n" + message
            //メッセージIDの文字列を太字化
            let attrText = NSMutableAttributedString(string: messageLabel.text!)
            attrText.addAttribute(.font,
                                  value: UIFont.boldSystemFont(ofSize: 20),
                                  range: NSMakeRange(0, messageId.count))
            self.messageLabel.attributedText = attrText
        }
        else
        {
            //メッセージ反映
            self.messageLabel.text = message
        }
        
        //ボタンの追加
        self.setYesButton()
        yesButton.setTitle(yesButtonTitle, for: .normal)
        if withNoButton
        {
            self.setNoButton()
            noButton.setTitle(noButtonTitle, for: .normal)
        }
        else
        {
            //ボタン一つしかない場合、位置を調節
            yesButton.center.x = titleLabel.center.x
        }
        
        
        //ベースビューを1.2倍に拡大
        contentView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        //アニメション処理
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            //等倍に戻る
            self.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            //透明度を指定する
            self.contentView.alpha = 1
            
        },
                       //アニメション終わったら
            completion:
            {
                finish in
                //NOP
        }
        )
        
    }
    
}
