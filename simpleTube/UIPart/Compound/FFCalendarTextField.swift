//
//  FFCalendarTextField.swift
//  Artemis
//
//  Created by Actus_03 on 2017/12/07.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

class FFCalendarTextField: UITextField
{
    
    var calendarView : FFFlexCalendar!                                  //カレンダー
    var isClear : Bool = false                                        //テキストクリア押下時か
    
    override var isEnabled: Bool
        {
        willSet
        {
            backgroundColor = newValue ? UIColor.white : UIColor.disabledGrey
            self.updateSelfStyle()
        }
    }
    //使用中　背景色変更
    var inUse:Bool = false
    {
        didSet
        {
            self.updateSelfStyle()
        }
    }
    func updateSelfStyle()
    {
        if self.inUse == true
        {
            //アニメション付きの背景色変化
            UIView.animate(withDuration: 0.5
                , animations: {self.backgroundColor = UIColor.cellSelected}
                , completion: nil)
        }
        else
        {
            //アニメション付きの背景色変化
            UIView.animate(withDuration: 0.5
                , animations: {self.backgroundColor = UIColor.white}
                , completion: nil)
        }
    }
    
    /// 初期化
    ///
    /// - Parameter frame: フレーム
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        setSelfStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //外観設定
    func setSelfStyle()
    {
        self.clearButtonMode = UITextFieldViewMode.always                           //クリアボタン常に表示
        self.borderStyle = UITextBorderStyle.roundedRect                            //角丸
        self.layer.borderColor = UIColor.borderColor.cgColor     //枠の色
        self.backgroundColor = UIColor.white                     //背景色
        self.textColor = UIColor.fontBlack                      //フォントカラー
        self.font = FFFont.systemFontOfSize(18)                 //フォント
        
        createCalendarView()
        
    }
    func createCalendarView()
    {
        calendarView = FFFlexCalendar()
        calendarView.delegate = self
    }
    
    //テキストフィールド更新
    func updateText()
    {
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.dateFormat = "yyyy/MM/dd"
        if self.calendarView.selectedDate != nil
        {
            self.text = dateFormat.string(from: self.calendarView.selectedDate!)
        }
        else
        {
            self.text = ""
        }
    }
    
}

extension FFCalendarTextField : UITextFieldDelegate,FFFlexCalendarDelegate
{
    //編集始める時の処理
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        //クリアボタン押下時は表示しない
        if self.isClear == true
        {
            self.text = ""
            self.isClear = false
            return false
        }
        self.superview?.addSubview(calendarView)
        self.superview?.bringSubview(toFront: calendarView)
        self.inUse = true
        
        //テキストの日付を選択状態にする
        if self.text == "" ||  self.text == nil
        {
            self.calendarView.calendar.selectedDate = Date()
            self.calendarView.calendar.setSelectedDate(self.calendarView.calendar)
        }
        else
        {
            self.calendarView.calendar.selectedDate = (self.text?.parseStringToDate("yyyy/MM/dd"))!
            self.calendarView.calendar.setSelectedDate(self.calendarView.calendar)
        }
        
        //カレンダー表示
        self.calendarView.showCalendar()
        //キーボード非表示
        return false
    }
    //カレンダー非表示になるときの処理
    func flexCalendarWillHide(flexCalendar: UIView) {
        self.inUse = false
        updateText()
    }
    //カレンダー非表示が終わったときの処理
    func flexCalendarDidHide(flexCalendar: UIView) {
        //        calendarView.removeFromSuperview()
    }
    //クリアボタン押下時の処理
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.isClear = true
        self.calendarView.selectedDate = nil
        return true
    }
}

