//
//  FFSwitchButton.swift
//  Artemis
//
//  Created by yo_i on 2017/11/22.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

typealias FFSwitchColor = (on:UIColor,off:UIColor)
typealias FFSwitchString = (on:String,off:String)

///色,文字列,枠線が設定できるswitchボタン
class FFSwitchButton:FFButton
{
    /// オンとオフを管理するパラメター
    var on:Bool = false
    {
        didSet
        {
            self.updateLayout()
        }
    }

    //ボタンに保持したいデータを格納
    var convenientDictionary = Dictionary<String,Any>()
    
    /// 背景色(on,off)
    var switchBackgroundColor:FFSwitchColor? = nil
    /// 枠線色(on,off)
    var switchBroderColor:FFSwitchColor? = nil
    /// 表示文字列(on,off)
    var switchTitle:FFSwitchString? = nil
    
    var switchTitleColor:FFSwitchColor? = nil
    /// デフォルト枠線の太さ
    var borderWidth = 1
    

    
    /// フレームのみの
    ///
    /// - Parameter frame: フレーム
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.type = .manual
        self.addTarget(self, action: #selector(self.setClick(_:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(self.setCancel(_:)), for: .touchUpOutside)
        self.addTarget(self, action: #selector(self.setCancel(_:)), for: .touchCancel)
        self.addTarget(self, action: #selector(self.setTouchDown), for: .touchDown)
    }
    
    
    /// 全指定
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - titles: オンとオフの文字列
    ///   - backgroundColors: オンとオフの背景色
    ///   - broderColors: オンとオフの枠色
    convenience init(frame: CGRect, titles: FFSwitchString,titlesColor:FFSwitchColor,backgroundColors: FFSwitchColor,broderColors: FFSwitchColor)
    {
        self.init(frame: frame)
        self.switchTitle = titles
        self.switchTitleColor = titlesColor
        self.switchBroderColor = broderColors
        self.switchBackgroundColor = backgroundColors
    }
    
    /// 全指定
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - titles: オンとオフの文字列
    ///   - backgroundColors: オンとオフの背景色
    ///   - broderColors: オンとオフの枠色
    convenience init(frame: CGRect, titles: FFSwitchString,backgroundColors: FFSwitchColor,broderColors: FFSwitchColor)
    {
        self.init(frame: frame)
        self.switchTitle = titles
        self.switchBroderColor = broderColors
        self.switchBackgroundColor = backgroundColors
    }
    
    /// オンとオフの文字列指定
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - titles: オンとオフの文字列
    convenience init(frame: CGRect, titles: FFSwitchString)
    {
        self.init(frame: frame)
        self.switchTitle = titles
    }
    
    
    /// オンとオフの枠線色指定
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - broderColors:オンとオフの枠線色
    convenience init(frame: CGRect, broderColors: FFSwitchColor)
    {
        self.init(frame: frame)
        self.switchBroderColor = broderColors
    }
    
    
    /// オンとオフの背景色指定
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - backgroundColors: オンとオフの枠線色
    convenience init(frame: CGRect, backgroundColors: FFSwitchColor)
    {
        self.init(frame: frame)
        self.switchBackgroundColor = backgroundColors
    }
    

    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelfStyle()
    {
        //使用不可の時の背景色を設定する
        let disableBackgroundColorView = UIView(frame: self.frame)                            //ビューを用意して
        disableBackgroundColorView.backgroundColor = UIColor.disabledGrey                     //ビューの背景色を指定
        disableBackgroundColorView.layer.cornerRadius = self.layer.cornerRadius               //ビュー角丸に指定する
        self.setBackgroundImage(disableBackgroundColorView.toImage(), for: .disabled)
        
        

        
        updateLayout()
        
    }
    
    ///ボタン表示更新
    internal func updateLayout()
    {
        updateBackgroundColor()
        updateBroderColor()
        updateTitleString()
        updateTitleColor()
        updateEnabled()
        self.layoutIfNeeded()
    }
    
    
    /// 背景色更新
    internal func updateBackgroundColor()
    {
        guard let color = switchBackgroundColor else
        {
            return
        }
        
        if on
        {
            UIView.animate(withDuration: 0.5, animations: {
                self.backgroundColor = color.on
            },completion:nil)
        }
        else
        {
            UIView.animate(withDuration: 0.5, animations: {
                self.backgroundColor = color.off
            },completion:nil)
        }
    }
    
    /// 枠線色更新
    internal func updateBroderColor()
    {
        guard let color = switchBroderColor else
        {
            return
        }
        
        if on
        {
            self.setBorder(borderWidth: self.borderWidth, borderColor: color.on)

        }
        else
        {
            self.setBorder(borderWidth: self.borderWidth, borderColor: color.off)
        }
    }
    
    internal func updateTitleColor()
    {
        guard let color = switchTitleColor else
        {
            return
        }
        
        if on
        {
            self.setTitleColor(color.on, for: .normal)
        }
        else
        {
            self.setTitleColor(color.off, for: .normal)
        }
    }
    
    /// 表示文字列更新
    internal func updateTitleString()
    {
        guard let title = switchTitle else
        {
            return
        }
        
        if on
        {
            self.setTitle(title.on, for: .normal)
        }
        else
        {
            self.setTitle(title.off, for: .normal)
        }
    }
    
    internal func updateEnabled()
    {
        if isEnabled
        {
            self.alpha = 1
        }
        else
        {
            self.alpha = 0.5
        }
        
    }
    
    //通常状態
    @objc internal func setClick(_ sender:AnyObject)
    {
        self.on = !self.on
        self.alpha = 1                  //不透明にする
    }
    
    //通常状態
    @objc internal func setCancel(_ sender:AnyObject)
    {
        self.alpha = 1                  //不透明にする
    }
    
    //タップイベント
    @objc internal override func setTouchDown()
    {
        self.alpha = 0.8                //半透明にする
        playTapSound()
    }

    
}

