//
//  FFBaseSubViewController.swift
//  Artemis
//
//  Created by yo_i on 2017/11/20.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import UIKit

/// 現在表示されているサブ画面
var currentSubView:FFBaseSubViewController? = nil

class FFBaseSubViewController: UIViewController
{
    let defContentSize = CGSize(width: 740, height: 480)
    var contentSize:CGSize? = nil
    var maskView:UIView!                            //グレーのマスクビュー
    var maskTapGesture:UITapGestureRecognizer!      //マスクのタップイベント
    var contentView:UIView!                         //コンテンツエリア
    var okButton:FFButton!                          //okボタン
    var titleLabel:FFLabel!                         //
    
    var cancelAble = true                           //キャンセル可能フラグ
    var withOkButton = true                         //OKボタン表示フラグ
    var okButtonTitle = ""                          //okボタンタイトル
    var viewID :String { return String(describing: type(of: self)) }
    //MARK: - 通知関連
    ///通知センター宣言
    var notificationCenter = NotificationCenter.default
    ///リザルト通知名を格納
    var resultNotificationName = ""
    ///OKの通知名を格納,継承先によりオーバーライドする
    var okNotificationName:String      {return "baseSubViewOk" }
    ///cancelの通知名を格納,継承先によりオーバーライドする
    var cancelNotificationName:String  {return "baseSubViewCancel" }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        currentSubView = self
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    //メイン画面に表示
    func showInMainView()
    {
        self.showInMainView(canCancel: true)
    }
    
    
    /// メイン画面に表示
    ///
    /// - Parameter canCancel: キャンセルできるようフラグ
    func showInMainView(canCancel:Bool)
    {
        cancelAble = canCancel
        
        createMaskView()
        createContentView()
        createTitleLabel()
        
        createOkButton()

        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(self.view)
        self.maskTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.cancel(sender:)))
        
        //UIパーツ追加のサマリー
        initializeView()
        initViewStatus()
        
        //アニメションで表示
        UIView.animate(withDuration: 0.3 * 0.75, delay: 0.05, options: UIViewAnimationOptions(),
        animations:
        {
            self.contentView.center.y = self.maskView.center.y
        },completion:
        { finish in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute:
            {
                //マスクビューにタップイベントを追加
                self.maskView.addGestureRecognizer(self.maskTapGesture)
                self.notificationCenter.post(name: NSNotification.Name(rawValue: "subViewDidShow"), object: nil)
            })

        })
        
    }
    
    
    /// 画面初期入化
    func initializeView()
    {
        
    }
    
    func initViewStatus()
    {
        
    }
    
    /// OKボタンのイベント
    @objc func clickOkButton()
    {
        print(#function)
        resultNotificationName = okNotificationName
        closeFromMainView()
    }
    
    ///マスクビューをタップするのキャンセルイベント
    @objc func cancel(sender:UITapGestureRecognizer)
    {
        print(#function)
        if self.cancelAble
        {
            resultNotificationName = cancelNotificationName
            closeFromMainView()
        }
    }
    
    
    /// 閉じる処理
    @objc func closeFromMainView()
    {
        self.maskView.removeGestureRecognizer(self.maskTapGesture)
        
        UIView.animate(withDuration: 0.3 * 0.75, delay: 0.05, options: UIViewAnimationOptions(),
        animations:
        {
                self.contentView.frame.origin.y = self.maskView.frame.height + 120
        },completion:
            { finish in
                for v in self.view.subviews
                {
                    v.removeFromSuperview()
                }
                //閉じるアニメション後、resultのイベントを発行
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.resultNotificationName), object: currentMainView)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute:
                {
                    //後片付け
                    self.view.removeFromSuperview()
                    NotificationCenter.default.removeObserver(self)
                })
                
        })
        
    }
    
}
