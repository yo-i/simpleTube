//
//  FFFlexCalendar.swift
//  Artemis
//
//  Created by Actus_03 on 2017/12/06.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

@objc protocol FFFlexCalendarDelegate : NSObjectProtocol
{
    @objc optional func flaxCalenfar(flecxCalendar : UIView)
    @objc optional func flexCalendarDidShow(flexCalendar: UIView)
    @objc optional func flexCalendarDidHide(flexCalendar: UIView)
    @objc optional func flexCalendarWillShow(flexCalendar: UIView)
    @objc optional func flexCalendarWillHide(flexCalendar: UIView)
    
}

class FFFlexCalendar : UIView
{
    var calendar : FFCalendar!                                      //カレンダー
    var calendarToolbar : UIToolbar!                                //ツールバー
    
    let screenSize : CGSize = UIScreen.main.bounds.size         //スクリーンサイズ
    var delegate : FFFlexCalendarDelegate?                          //デリゲート
    var selectedDate : Date? = nil                                //選択されている日付
    var notification : NotificationCenter!                          //通知
    
    /// 初期化
    ///
    /// - Parameter frame: フレーム
    init() {
        super.init(frame: CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: 344))

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //自分が表示される前の処理
    override func willMove(toSuperview newSuperview: UIView?) {
        setSelfStyle()                                                  //表示内容を指定する
    }
    

    //外観設定
    func setSelfStyle()
    {
        self.backgroundColor = UIColor.white
        createCalendar()
        createCalendarToolbar()
        notification = NotificationCenter.default
        notification.post(name: NSNotification.Name("willShowFlexView"), object: nil)
    }
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    func createCalendar()
    {
        calendar = FFCalendar(frame: CGRect(x: 0, y: 44, width: 0, height: 0 ))
        calendar.center = CGPoint(x: screenSize.width / 2, y: 150 + 44)
        self.addSubview(calendar)
    }
    
    func createCalendarToolbar()
    {
        calendarToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 44))
        calendarToolbar.isTranslucent = false
        //スペーサー
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        //キャンセルボタン
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtonTapped))
        //完了ボタン
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped))
        calendarToolbar.setItems([spacer,cancelButton,doneButton], animated: false)
        self.addSubview(calendarToolbar)
    }
    
    /// 完了ボタン押下
    @objc func doneButtonTapped()
    {
        self.selectedDate = getDate()!
        hideCalendar()
    }
    
    /// キャンセルボタン押下
    @objc func cancelButtonTapped()
    {
        hideCalendar()
    }
    //カレンダー表示
    func showCalendar()
    {
        self.delegate?.flexCalendarWillShow?(flexCalendar: self)
        notification.post(name: NSNotification.Name("willShowFlexView"), object: nil)
        checkFlexView()
        UIView.animate(withDuration: 0.5
            , animations: {self.frame = CGRect(x: 0, y:self.screenSize.height - 350 , width: self.screenSize.width, height: 344)}
            , completion: {finish in
                self.delegate?.flexCalendarDidShow?(flexCalendar: self)
        })
    }
    //カレンダー非表示
    func hideCalendar()
    {
        self.delegate?.flexCalendarWillHide?(flexCalendar: self)
        UIView.animate(withDuration: 0.5
            , animations: {self.frame = CGRect(x: 0, y: self.screenSize.height, width: self.screenSize.width, height: 344)}
            , completion: { finish in
                self.delegate?.flexCalendarDidHide?(flexCalendar: self)
        })
    }
    
    /// 自分以外にフレックスビューが表示されていたら非表示にする
    func checkFlexView()
    {
        for picker in (self.superview?.subviews.filter { $0 is FFFlexPicker})!
        {
            if picker.frame.origin.y < screenSize.height
            {
                let pi = picker as! FFFlexPicker
                pi.hidePicker()
            }
        }
        for calendar in (self.superview?.subviews.filter{ $0 is FFFlexCalendar})!
        {
            if calendar.frame.origin.y < screenSize.height
            {
                let ca = calendar as! FFFlexCalendar
                ca.hideCalendar()
            }
        }
        
        
    }
    //選択されている日付取得
    func getDate() -> Date?
    {
        return self.calendar.getSelectedDate()
    }

    
    
}


