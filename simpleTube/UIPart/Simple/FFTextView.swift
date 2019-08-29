//
//  FFTextView.swift
//  Artemis
//
//  Created by Actus_03 on 2017/12/01.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

class FFTextView : UITextView
{
    var maxLength : Int = Int.max
    var minLength : Int = 0
    
//    var isNumber:Bool = false                                           //数字だけ
//    var isHirakana:Bool = false                                         //ひらかなだけ
//    var isKatakana:Bool = false                                         //カタカナだけ
//    var isKanjiLevel2:Bool = false                                      //漢字第２水準
//    var isKanjiSoftCheck:Bool = false
    
    var notification:NotificationCenter!                    //通知センター、キーボードの表示を監視する
    var superViewInitFrame:CGRect!                          //自分の親ビュー
    var shouldMoveMin:CGFloat = 300                         //親を上にスクロールする基準
    var name : String = ""                                  //名前（アラート表示）
    
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
    /// - Parameters:
    ///   - frame: フレーム
    ///   - textContainer: テキスト中身
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        self.delegate = self
        setSelfStyle()
    }
    override func didMoveToSuperview() {
        self.superViewInitFrame = self.superview?.frame
    }
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setSelfStyle()
    {
        
        self.layer.borderWidth = 1                               //枠の太さ
        self.layer.borderColor = UIColor.borderColor.cgColor     //枠の色
        self.layer.cornerRadius = 7.5
        self.backgroundColor = UIColor.white                     //背景色
        
        //ツールバー作成
        makeToolbar()
        
        notification = NotificationCenter.default                         //通知センターのインスタンスを生成する
        notification.addObserver(self, selector: #selector(FFTextView.keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)    //キーボードが表示される寸前を監視する、通知が来たらkeyBoardWillShow()を呼び出す
        notification.addObserver(self, selector: #selector(FFTextView.keyBoardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)    //キーボードが閉じられる寸前を監視する、通知が来たらkeyBoardWillHide()を呼び出す
        notification.addObserver(self, selector: #selector(FFTextView.hideKeyboard), name: NSNotification.Name("willShowFlexView"), object: nil)
    }
    
    /// ツールバー作成
    func makeToolbar()
    {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        toolbar.barStyle = UIBarStyle.default
        toolbar.sizeToFit()
        //スペーサー
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        //完了ボタン
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped))
        toolbar.items = [spacer,doneButton]
        self.inputAccessoryView = toolbar
    }
    
    /// 完了ボタン押下
    @objc func doneButtonTapped()
    {
        self.resignFirstResponder()
    }
    
    /// フレックスビューを開くとキーボードを閉じる
    @objc func hideKeyboard()
    {
        self.resignFirstResponder()
    }
    
    //キーボード表示前の通知
    @objc func keyBoardWillShow(_ notification:NotificationCenter)
    {
        checkFlexView()
    }
    /// 自分以外にフレックスビューが表示されていたら非表示にする
    func checkFlexView()
    {
        let screenSize : CGSize = UIScreen.main.bounds.size         //スクリーンサイズ
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
    //キーボード閉じる前の通知
    @objc func keyBoardWillHide(_ notification:NotificationCenter)
    {
        self.superViewRollBack()                            //画面を元に戻る
    }
    //画面を上にスクロール
    func superViewRollUp(_ py:CGFloat)
    {
        UIView.animate(withDuration: 0.35                                     //0.35秒を掛かって
            , delay: 0                                                      //遅延0秒
            , options: UIViewAnimationOptions()                //アニメションオプション：加速で開始、減速で終了
            , animations: {self.superview!.frame.origin.y = 250 - py }      //アニメション処理
            , completion: nil)                                              //アニメション終了処理
    }
    //画面を元に戻す
    func superViewRollBack()
    {
        UIView.animate(withDuration: 0.35                                     //0.35秒を掛かって
            , delay: 0                                                      //遅延0秒
            , options: UIViewAnimationOptions()                //アニメションオプション：加速で開始、減速で終了
            , animations: {self.superview!.frame = self.superViewInitFrame} //アニメション処理
            , completion: nil)                                              //アニメション終了処理
    }
}

extension FFTextView : UITextViewDelegate
{
    //編集始める時の処理
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        self.inUse = true                               //使用中に設定
        self.superViewRollBack()
        self.superViewInitFrame = self.superview?.frame
        
        
        
        //テキストビューがキーボードに重なる場合
        if (convert(textView.frame.origin, to: self.window).y + textView.frame.height) > self.shouldMoveMin
        {
            self.superViewRollUp(textView.frame.origin.y + textView.frame.height)  //親ビューを上にスクロールする
        }
        
        return true
    }
    
    //編集終わる時の処理
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.inUse = false
        return true
    }
    //編集終わる時の処理
    func textViewDidEndEditing(_ textView: UITextView)
    {
        
        if self.text != nil
        {
            if self.text.count > maxLength
            {
                self.text = self.text?.substring(0, length: maxLength)
            }
        }
    }
    
}
