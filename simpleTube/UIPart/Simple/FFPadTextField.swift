//
//  FFPadTextField.swift
//  Albina
//
//  Created by yo_i on 2018/02/07.
//  Copyright © 2018年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

class FFPadTextField : UITextField
{
    var maxLength : Int = Int.max
    var minLength : Int = 0
    var isClear : Bool = false                                        //テキストクリア押下時か
    var notification:NotificationCenter!                              //通知センター、キーボードの表示を監視する
    var superViewInitFrame:CGRect!                                      //自分の親ビュー
    var shouldMoveMin:CGFloat = 510                                     //親を上にスクロールするの基準
    var name : String = ""                                             //名前（アラート表示）
    var isInPopup:Bool = false
    var isInSubView:Bool = false
    override var isEnabled: Bool
        {
        willSet
        {
            backgroundColor = newValue ? UIColor.white : UIColor.disabledGrey
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
        self.clearButtonMode = UITextFieldViewMode.always
        self.font = FFFont.systemFontOfSize(20)                     //フォントサイズ
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.clearButtonMode = UITextFieldViewMode.always
    }
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    //自分が表示される前の処理
    override func willMove(toSuperview newSuperview: UIView?)
    {
        setSelfStyle()                                                  //表示内容を指定する
    }
    
    override func didMoveToSuperview() {
        superViewInitFrame = self.superview?.frame
        
    }
    //外観設定
    func setSelfStyle()
    {
        self.clearButtonMode = UITextFieldViewMode.always                           //クリアボタン常に表示
        self.borderStyle = UITextBorderStyle.roundedRect                            //角丸
        self.layer.borderColor = UIColor.borderColor.cgColor     //枠の色
        self.backgroundColor = UIColor.white                     //背景色
        self.textColor = UIColor.fontBlack                      //フォントカラー
        
        notification = NotificationCenter.default                         //通知センターのインスタンスを生成する
        notification.addObserver(self, selector: #selector(FFTextField.keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)    //キーボードが表示される寸前を監視する、通知が来たらkeyBoardWillShow()を呼び出す
        notification.addObserver(self, selector: #selector(FFTextField.keyBoardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)    //キーボードが閉じられる寸前を監視する、通知が来たらkeyBoardWillHide()を呼び出す
        notification.addObserver(self, selector: #selector(FFTextField.hideKeyboard), name: NSNotification.Name("willShowFlexView"), object: nil)
        
        if self.isInSubView
        {
            notification.addObserver(self, selector: #selector(self.initSuperViewFrame), name: NSNotification.Name("subViewDidShow"), object: nil)
        }
    }
    
    @objc func initSuperViewFrame()
    {
        log.info(#function)
    
        self.superViewInitFrame = self.superview?.frame
    }
    
    /// フレックスビューを開くとキーボードを閉じる
    @objc func hideKeyboard()
    {
        self.resignFirstResponder()
    }
    
    //キーボード表示前の通知
    @objc func keyBoardWillShow(_ notification:NotificationCenter)
    {
        
    }
    
    //キーボード閉じる前の通知
    @objc func keyBoardWillHide(_ notification:NotificationCenter)
    {
        self.superViewRollBack()                            //画面を元に戻る
    }
    //画面を上にスクロール
    func superViewRollUp(_ py:CGFloat)
    {
        if isInPopup { return }
        UIView.animate(withDuration: 0.35                                     //0.35秒を掛かって
            , delay: 0                                                      //遅延0秒
            , options: UIViewAnimationOptions()                //アニメションオプション：加速で開始、減速で終了
            , animations: {self.superview!.frame.origin.y = 250 - py }      //アニメション処理
            , completion: nil)                                              //アニメション終了処理
    }
    //画面を元に戻す
    func superViewRollBack()
    {
        if isInPopup { return }
        UIView.animate(withDuration: 0.35                                     //0.35秒を掛かって
            , delay: 0                                                      //遅延0秒
            , options: UIViewAnimationOptions()                //アニメションオプション：加速で開始、減速で終了
            , animations: {self.superview!.frame = self.superViewInitFrame } //アニメション処理
            , completion: nil)                                              //アニメション終了処理
    }
    
    
}


extension FFPadTextField : UITextFieldDelegate
{
    //編集終わる時の処理
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        self.inUse = false
        return true
    }
    
    //編集始める時の処理
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        //クリアボタン押下時はキーボード表示しない
        if self.isClear == true
        {
            self.text = ""
            self.isClear = false
            return false
        }
        
        self.inUse = true
        
        
        
        self.superViewRollBack()
        self.superViewInitFrame = self.superview?.frame
        //テキストフィールドがキーボードに重なる場合
        if (convert(textField.frame.origin, to: self.window).y + textField.frame.height) > self.shouldMoveMin
        {
            self.superViewRollUp(textField.frame.origin.y + textField.frame.height)  //親ビューを上にスクロールする
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.isClear = true
        return true
    }
    //編集終わる時の処理
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.text != nil
        {
            if (self.text?.count)! > maxLength
            {
                self.text = self.text?.substring(0, length: maxLength)
            }
        }
    }
    
    
}
