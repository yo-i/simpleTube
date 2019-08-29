//
//  FFPopNumPadTextField.swift
//  Tiamat
//
//  Created by yo_i on 2018/01/30.
//  Copyright © 2018年 Open Resource Corporation. All rights reserved.
//

import UIKit

@objc protocol FFPopNumPadTextFieldDelegate : NSObjectProtocol
{
    @objc optional func numPadValueChanged(textField:FFPopNumPadTextField)
    @objc optional func numPadClickEnter(textField:FFPopNumPadTextField)
}

/// テンキーバリュータイプ
///
/// - code: コード
/// - decimal: 数値
enum FFNumPadTextFieldValueType
{
    /// - code: コード
    case code
    /// - decimal: 数値
    case decimal
}

class FFPopNumPadTextField: UITextField,UITextFieldDelegate ,FFPopoverViewControllerDelegate,FFNumPadTextFieldDelegate
{
    var numPad : FFNumPad!
    var valueHoldTextField : FFNumPadTextField!
    var contectView:UIView!
    var numPadType:FFNumPadType = .withDot
    var valueType : FFNumPadTextFieldValueType = .decimal               //テンキーバリュータイプ
    var roundScale : Int = 5                                            //小数点位置
    var popController : FFPopoverViewController!                        //ポップビュー
    var isClear : Bool = false                                          //クリアボタン押下時か
    weak var presentFromViewController : UIViewController!              //表示元のVC
    weak var popDelegate: FFPopNumPadTextFieldDelegate?
    
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
    
    init(frame:CGRect,presentFromViewController : UIViewController,numPadType:FFNumPadType = .withDot)
    {
        super.init(frame: frame)
        self.presentFromViewController = presentFromViewController
        self.delegate = self
        self.numPadType = numPadType
        setSelfStyle()
        createContentView()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelfStyle()
    {
        self.clearButtonMode = UITextFieldViewMode.always                           //クリアボタン常に表示
        self.borderStyle = UITextBorderStyle.roundedRect                            //角丸
        self.layer.borderColor = UIColor.borderColor.cgColor     //枠の色
        self.backgroundColor = UIColor.white                     //背景色
        self.textColor = UIColor.fontBlack                      //フォントカラー
        self.font = FFFont.systemFontOfSize(20)
    }
    
    func createContentView()
    {
        contectView = UIView(frame: CGRect(x: 0, y: 0, width: 310, height: 280))
        
        
        popController = FFPopoverViewController()
        popController.setBaseView(showFromView: self, presenFromViewController: self.presentFromViewController)
        valueHoldTextField = FFNumPadTextField(frame: CGRect(x: 4, y: 4, width: 302, height: 40))
        valueHoldTextField.padDelegate = self
        contectView.addSubview(valueHoldTextField)
        
        numPad = FFNumPad(frame: CGRect(x: 4, y: 48, width: 0, height: 0), type: numPadType)
        numPad.notifinTarget = valueHoldTextField
        contectView.addSubview(numPad)
        
        
        popController.view.addSubview(contectView)
        popController.contentSize = contectView.frame.size
        popController.delegate = self
    }
    
    //テキストフィールドにセット
    func updateText()
    {
        let valueHoldText = self.valueHoldTextField.text
        switch  valueType{
        case .code:
            self.text = valueHoldText
        case .decimal:
            if valueHoldText?.count == 0
            {
                self.text = valueHoldText
            }
            else
            {
                self.text = cutDecimalPlace(valueHoldText: (valueHoldText?.decimal.toString())!)
            }
        }
    }
    
    /// 小数点切り捨て
    ///
    /// - Parameter valueHoldText: 入力した値
    /// - Returns: 小数点切り捨てた値
    func cutDecimalPlace(valueHoldText : String) -> String
    {
        if valueHoldText.contains(".")
        {
            //.で区切り
            var str : [String] = valueHoldText.components(separatedBy: ".")
            //str[0] は整数分　str[1]　は小数分
            if str[1].count > roundScale
            {
                //小数点切り捨て
                str[1] = str[1].substring(0, length:  roundScale)
            }
            return str.joined(separator: ".").decimal.toString()
        }
        else
        {
            return valueHoldText
        }
        
    }
    
    //テキストフィールドが編集始まる前の処理
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        //クリアボタン押下時はポップ表示しない
        if self.isClear == true
        {
            self.text = ""
            popDelegate?.numPadValueChanged?(textField: self)
            self.isClear = false
            return false
        }
        else
        {
            //表示
            popController.presentPop()
            valueHoldTextField.text = self.text
            valueHoldTextField.inUse = true
            //キーボードを出さない
            return false
        }
        
    }
    
    //テキストクリア
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        self.isClear = true
        return true
    }
    
    //ポップオーバーを閉じる時の処理
    func popShouldDismiss()
    {
        updateText()
        valueHoldTextField.inUse = false
        popDelegate?.numPadValueChanged?(textField: self)
    }
    
    func clickEnter()
    {
        self.popController.dismiss(animated: false, completion: {
            
            self.popShouldDismiss()
            self.popDelegate?.numPadClickEnter?(textField: self)
            
            
        })
        
    }

}

