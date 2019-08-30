//
//  FFTextField.swift
//  Artemis
//
//  Created by Actus_03 on 2017/11/30.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

@objc protocol FFFlexTextFieldDelegate : NSObjectProtocol
{
    @objc optional func flexTextFieldValueChanged(textField:FFTextField)
    @objc optional func keyBoradWillOpen(textField:FFTextField) -> Bool
}

class FFTextField : UITextField
{
    var maxLength : Int = Int.max
    var minLength : Int = 0
    var isClear : Bool = false                                        //テキストクリア押下時か
    var notification:NotificationCenter!                              //通知センター、キーボードの表示を監視する
    var superViewInitFrame:CGRect!                                      //自分の親ビュー
    var shouldMoveMin:CGFloat = 340                                     //親を上にスクロールするの基準
    var name : String = ""                                             //名前（アラート表示）
    
    var isInCell = false                                                //cellのなら初期化時true
    var tablePy:CGFloat = 0                                             //delegateにtableView.frame.heightを代入
    
    var sectionTag:Int = 0                                              //テーブルビューセル内に使用時に使用可能
    
    weak var flexDelegate: FFFlexTextFieldDelegate?
    
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
            
            notification = NotificationCenter.default                         //通知センターのインスタンスを生成する
            notification.addObserver(self, selector: #selector(FFTextField.keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)    //キーボードが表示される寸前を監視する、通知が来たらkeyBoardWillShow()を呼び出す
            notification.addObserver(self, selector: #selector(FFTextField.keyBoardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)    //キーボードが閉じられる寸前を監視する、通知が来たらkeyBoardWillHide()を呼び出す
            notification.addObserver(self, selector: #selector(FFTextField.hideKeyboard), name: NSNotification.Name("willShowFlexView"), object: nil)
            
            
        }
        else
        {
            //アニメション付きの背景色変化
            UIView.animate(withDuration: 0.5
                , animations: {self.backgroundColor = UIColor.white}
                , completion: nil)
            
            NotificationCenter.default.removeObserver(self)
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
    override func willMove(toSuperview newSuperview: UIView?) {
        setSelfStyle()                                                  //表示内容を指定する
    }
    
    override func didMoveToSuperview()
    {
        if !isInCell
        {
            superViewInitFrame = self.superview?.frame ?? CGRect.zero
        }
    }
    //外観設定
    func setSelfStyle()
    {
        self.clearButtonMode = UITextFieldViewMode.always                           //クリアボタン常に表示
        self.borderStyle = UITextBorderStyle.roundedRect                            //角丸
        self.layer.borderColor = UIColor.borderColor.cgColor     //枠の色
        self.backgroundColor = UIColor.white                     //背景色
        self.textColor = UIColor.fontBlack                      //フォントカラー
        
        //ツールバー作成
        makeToolbar()
        
    }
    
    
    /// ツールバー作成
    func makeToolbar()
    {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        toolbar.barStyle = UIBarStyle.default
        toolbar.sizeToFit()
        toolbar.barTintColor = UIColor.actusBlue
        //スペーサー
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        //完了ボタン
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped))
        doneButton.tintColor = UIColor.white
        toolbar.items = [spacer,doneButton]
        self.inputAccessoryView = toolbar
    }
    
    
    /// 完了ボタン押下
    @objc func doneButtonTapped()
    {
        flexDelegate?.flexTextFieldValueChanged?(textField: self)
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
        log.info(#function)
        UIView.animate(withDuration: 0.35                                     //0.35秒を掛かって
            , delay: 0                                                      //遅延0秒
            , options: UIViewAnimationOptions()                //アニメションオプション：加速で開始、減速で終了
            , animations: {
                
                if self.isInCell
                {
                    currentMainView!.view.frame.origin.y =  -py
                }
                else
                {
                    self.superview!.frame.origin.y = 250 - py
                }
                
        }      //アニメション処理
            , completion: nil)                                              //アニメション終了処理
    }
    //画面を元に戻す
    func superViewRollBack()
    {
        log.info(#function)
        UIView.animate(withDuration: 0.35                                     //0.35秒を掛かって
            , delay: 0                                                      //遅延0秒
            , options: UIViewAnimationOptions()                //アニメションオプション：加速で開始、減速で終了
            , animations: {
                
                if self.isInCell
                {
                    currentMainView!.view.frame.origin.y = 0
                }
                else
                {
                    self.superview!.frame = self.superViewInitFrame
                }
                
                
        } //アニメション処理
            , completion: nil)                                              //アニメション終了処理
    }
    
    
}


extension FFTextField : UITextFieldDelegate
{
    //編集終わる時の処理
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        self.inUse = false
        superViewRollBack()
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
            flexDelegate?.flexTextFieldValueChanged?(textField: self)
            return false
        }
        let shouldBegin = self.flexDelegate?.keyBoradWillOpen?(textField: self) ?? true
        if !shouldBegin{ return false}
        
        self.inUse = true
        
        if !isInCell
        {
            self.superViewRollBack()
        }
        superViewInitFrame = self.superview?.frame
        
        if isInCell
        {
            self.superViewRollUp(self.tablePy - (currentMainView?.navigationController?.navigationBar.frame.height)!)  //親ビューを上にスクロールする 60はナビゲーションバーの高さ
        }
        else
        {
//            let aaaa = (convert(textField.frame.origin, to: self.window).y + textField.frame.height)
            //テキストフィールドがキーボードに重なる場合
            if (convert(textField.frame.origin, to: self.window).y + textField.frame.height) > self.shouldMoveMin
            {
                
                self.superViewRollUp(textField.frame.origin.y + textField.frame.height)  //親ビューを上にスクロールする
                
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if isInCell
        {
            self.superViewRollUp(self.tablePy - (currentMainView?.navigationController?.navigationBar.frame.height)!)  //親ビューを上にスクロールする
        }
        else
        {
            
            //テキストフィールドがキーボードに重なる場合
            if (convert(textField.frame.origin, to: self.window).y + textField.frame.height) > self.shouldMoveMin
            {
                
                self.superViewRollUp(textField.frame.origin.y + textField.frame.height)  //親ビューを上にスクロールする
                
            }
        }
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
    //テキストフィールドの文字数制限
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if self.keyboardType == .numberPad
        {
            //入力済の文字と入力された文字
            let str = textField.text! + string
            if str.characters.count <= maxLength
            {
                return true
            }
            else
            {
                return false
            }
        }
        else
        {
            return true
        }
        
    }
    
}
