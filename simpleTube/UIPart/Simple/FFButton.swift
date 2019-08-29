//
//  FFButton.swift
//  Artemis
//
//  Created by yo_i on 2017/11/21.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

enum FFButtonDesignType
{
    /// メイン処理ボタン
    case mainProcess
    /// サブ処理ボタン
    case subProcess
    /// 手動設定
    case manual
}

class FFButton: UIButton
{
    static let defWidth = 182
    static let defHeight = 40
    var subMenuBranchDivision:UInt? = nil        //サブメニュー用区分
    var type:FFButtonDesignType = .subProcess
    var controlInfo:Dictionary<String,String> = [:]
    
    override var isEnabled: Bool {
        didSet {
            updateBorder()
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.addTarget(self, action: #selector(self.setNormal(_:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(self.setNormal(_:)), for: .touchUpOutside)
        self.addTarget(self, action: #selector(self.setNormal(_:)), for: .touchCancel)
        self.addTarget(self, action: #selector(self.setTouchDown), for: .touchDown)
        
        
        self.titleLabel?.font = FFFont.systemFontOfSize(20)
        //ボタンの文字が複数行で表示できるように設定する
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.lineBreakMode = NSLineBreakMode.byCharWrapping
        self.titleLabel?.textAlignment = NSTextAlignment.center
        //同時押し禁止する
        self.isExclusiveTouch = true
        
        
        //角丸を指定する
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
    }
    
    func updateBorder()
    {
        if self.isEnabled
        {
            setColorForType(self.type)
        }
        else
        {
            self.setBorder(borderWidth: 0, borderColor: .clear)
        }

    }
    
    
    override func willMove(toSuperview newSuperview: UIView?)
    {
        super.willMove(toSuperview: newSuperview)
        setSelfStyle()
    }
    convenience init(frame: CGRect,title:String)
    {
        self.init(frame: frame)
        setTitle(title, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
    }
    
    // MARK: - 外観設定
    func setSelfStyle()
    {
        //使用不可の時の背景色を設定する
        let disableBackgroundColorView = UIView(frame: self.frame)                            //ビューを用意して
        disableBackgroundColorView.setBorder(borderWidth: Int(self.layer.borderWidth), borderColor: .clear )
        disableBackgroundColorView.backgroundColor = UIColor.disabledGrey                     //ビューの背景色を指定
        disableBackgroundColorView.layer.cornerRadius = self.layer.cornerRadius               //ビュー角丸に指定する
        self.setBackgroundImage(disableBackgroundColorView.toImage(), for: .disabled)
        
        
        
        setColorForType(self.type)
        
    }
    
    func setColorForType(_ type:FFButtonDesignType)
    {
        switch type {
        case .mainProcess:
            //背景色
            self.backgroundColor = .actusBlue
            
            self.setBorder(borderWidth: 1, borderColor: .actusBlue)
            
            self.setTitleColor(.white, for: .normal)
        case .subProcess:
            //背景色
            self.backgroundColor = .white
            
            self.setBorder(borderWidth: 1, borderColor: .actusBlue)
            
            self.setTitleColor(.actusBlue, for: .normal)
            
            self.setTitleColor(.white, for: .disabled)
        case .manual:
            break
        }
        
    }
    
    //通常状態
    @objc func setNormal(_ sender:AnyObject)
    {
        self.alpha = 1                  //不透明にする
    }
    
    //タップイベント
    @objc func setTouchDown()
    {
        self.alpha = 0.2                //半透明にする
        playTapSound()
    }
    //効果音
    @objc func playTapSound()
    {
        FFSound.playSound(soundId: 1104)
    }
    
    
}

