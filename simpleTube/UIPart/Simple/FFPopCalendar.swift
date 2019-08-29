//
//  FFPopCalendar.swift
//  Artemis
//
//  Created by Actus_03 on 2017/12/06.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

@objc protocol FFPopCalendarTextFieldDelegate : NSObjectProtocol
{
    @objc optional func popCalendarValueChanged(textField:FFPopCalendar)
}

class FFPopCalendar : UITextField
{
    var calendar : FFCalendar!                                      //カレンダー
    var popCalendar : FFPopoverViewController!                      //ポップビュー
    var isClear : Bool = false                                      //クリアボタン押下時か
    var presentFromViewController : UIViewController!               //表示元のVC
    
    weak var popDelegate : FFPopCalendarTextFieldDelegate?
    
    var isShowDelivery : Bool = false                               //定期便ラベル表示
    
    override var isEnabled: Bool
        {
        willSet
        {
            backgroundColor = newValue ? UIColor.white : UIColor.disabledGrey
        }
    }
    
    /// 初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - presentFromViewController: 表示元のVC
    init(frame: CGRect,presentFromViewController : UIViewController) {
        super.init(frame: frame)
        self.presentFromViewController = presentFromViewController
        setSelfStyle()
        createPopCalendar()
    }
    
    /// 初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - presentFromViewController: 表示元のVC
    init(frame: CGRect,startSelectDate:Date,presentFromViewController : UIViewController) {
        super.init(frame: frame)
        self.presentFromViewController = presentFromViewController
        setSelfStyle()
        createPopCalendar(startSelectDate)
        self.text = startSelectDate.toString("yyyy/MM/dd")
    }
    
    init(frame: CGRect,presentFromViewController : UIViewController,isShowDelivery:Bool) {
        super.init(frame: frame)
        self.presentFromViewController = presentFromViewController
        self.isShowDelivery = isShowDelivery
        setSelfStyle()
        createPopCalendar()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //外観設定
    func setSelfStyle()
    {
        self.delegate = self
        
        self.clearButtonMode = UITextFieldViewMode.always                           //クリアボタン常に表示
        self.borderStyle = UITextBorderStyle.roundedRect                            //角丸
        self.layer.borderColor = UIColor.borderColor.cgColor     //枠の色
        self.backgroundColor = UIColor.white                     //背景色
        self.textColor = UIColor.fontBlack                      //フォントカラー
        self.font = FFFont.systemFontOfSize(20)
    }
    
    func createPopCalendar()
    {
        popCalendar = FFPopoverViewController()
        popCalendar.setBaseView(showFromView: self, presenFromViewController: self.presentFromViewController)
        if isShowDelivery
        {
            calendar = FFCalendar(frame: CGRect(x: 0, y: 0, width: 0, height: 0)
                , isShowDelivery: isShowDelivery)
        }
        else
        {
            calendar = FFCalendar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        }
        popCalendar.view.addSubview(calendar)
        popCalendar.contentSize = calendar.viewSize
        popCalendar.delegate = self
    }
    
    func createPopCalendar(_ date:Date)
    {
        popCalendar = FFPopoverViewController()
        popCalendar.setBaseView(showFromView: self, presenFromViewController: self.presentFromViewController)
        calendar = FFCalendar(frame: CGRect(x: 0, y: 0, width: 0, height: 0), selectedDate: date)
        popCalendar.view.addSubview(calendar)
        popCalendar.contentSize = calendar.viewSize
        popCalendar.delegate = self
    }
    //選択されている日付取得
    func getDate() -> Date?
    {
        return self.calendar.getSelectedDate()
    }
    //テキストフィールドに日付をセット
    func updateText()
    {
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.dateFormat = "yyyy/MM/dd"
        
        if self.getDate() != nil
        {
            self.text = dateFormat.string(from: self.getDate()! as Date)
        }
        else
        {
            self.text = ""
        }
        self.popDelegate?.popCalendarValueChanged?(textField: self)
    }
    func isSelectedDeliveryDate() -> Bool
    {
        return self.calendar.isSelectedDeliveryDate
    }
    
}

extension  FFPopCalendar : UITextFieldDelegate ,FFPopoverViewControllerDelegate
{
    //テキストフィールドが編集始まる前の処理
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        //クリアボタン押下時はポップカレンダー表示しない
        if self.isClear == true
        {
            self.text = ""
            self.isClear = false
            self.popDelegate?.popCalendarValueChanged?(textField: self)
            return false
        }
        else
        {
            //カレンダー表示
            popCalendar.presentPop()
            
            //キーボードを出さない
            return false
        }
        
    }
    
    //テキストクリア
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.isClear = true
        return true
    }
    
    //ポップオーバーを閉じる時の処理
    func popShouldDismiss() {
        updateText()
    }
    
}

