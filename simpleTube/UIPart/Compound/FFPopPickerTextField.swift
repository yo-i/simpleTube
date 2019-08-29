//
//  FFPopPickerTextField.swift
//  Tiamat
//
//  Created by yo_i on 2018/01/30.
//  Copyright © 2018年 Open Resource Corporation. All rights reserved.
//

import UIKit

@objc protocol FFPopPickerTextFieldDelegate : NSObjectProtocol
{
    @objc optional func pickerValueChanged(textField:FFPopPickerTextField)
}

class FFPopPickerTextField : UITextField,UITextFieldDelegate ,FFPopoverViewControllerDelegate
{
    var pickerView : FFSimplePickerView!
    var popPicker : FFPopoverViewController!                      //ポップビュー
    var isClear : Bool = false                                      //クリアボタン押下時か
    var presentFromViewController : UIViewController!               //表示元のVC
    var popDelegate: FFPopPickerTextFieldDelegate?
    //表示用
    var displayArray:Array<String> = []
    //表示された項目に対応するオブジェクト
    var objectArray:Array<Any> = []
    
    override var isEnabled: Bool
    {
        willSet {
            backgroundColor = newValue ? UIColor.clear : UIColor.disabledGrey
        }
    }
    
    /// 初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - displayArray: 表示用配列
    ///   - objectArray: 表示された項目に対するオブジェクト
    init(frame:CGRect,displayArray:Array<String>,objectArray:Array<Any>,presentFromViewController : UIViewController)
    {
        super.init(frame: frame)
        self.displayArray = displayArray
        self.objectArray = objectArray
        self.presentFromViewController = presentFromViewController
        self.delegate = self
        setSelfStyle()
        createPopPicker()
    }
    
    /// 初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - displayArray: 表示用配列
    ///   - objectArray: 表示された項目に対するオブジェクト
    init(frame:CGRect,presentFromViewController : UIViewController)
    {
        super.init(frame: frame)
        self.presentFromViewController = presentFromViewController
        self.delegate = self
        setSelfStyle()
        createPopPicker()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setSelfStyle()
    {
        self.clearButtonMode = UITextFieldViewMode.always                           //クリアボタン常に非表示
        self.borderStyle = UITextBorderStyle.roundedRect                            //角丸
        self.layer.borderColor = UIColor.borderColor.cgColor     //枠の色
        self.backgroundColor = UIColor.white                     //背景色
        self.textColor = UIColor.fontBlack                      //フォントカラー
        self.font = FFFont.systemFontOfSize(20)
    }
    
    func createPopPicker()
    {
        popPicker = FFPopoverViewController()
        popPicker.setBaseView(showFromView: self, presenFromViewController: self.presentFromViewController)
        pickerView = FFSimplePickerView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
        popPicker.view.addSubview(pickerView)
        popPicker.contentSize = pickerView.frame.size
        popPicker.delegate = self
    }
    
    func updateText()
    {
        self.text = self.pickerView.getSelectedDisplay()
        self.popDelegate?.pickerValueChanged?(textField: self)
    }
    //テキストフィールドが編集始まる前の処理
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        //クリアボタン押下時はポップ表示しない
        if self.isClear == true
        {
            self.text = ""
            self.isClear = false
            self.popDelegate?.pickerValueChanged?(textField: self)
            return false
        }
        else
        {
            //ピッカー表示
            popPicker.presentPop()
            
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
    func popShouldDismiss()
    {
        updateText()
    }
    
    func reload()
    {
        self.pickerView.displayArray = self.displayArray
        self.pickerView.objectArray = self.objectArray
        self.pickerView.reloadComponent(0)
    }
    
    func selectRow(index:Int)
    {
        if index >= self.displayArray.count
        || index < 0
        {
            self.text = ""
            self.popDelegate?.pickerValueChanged?(textField: self)
            return
        }
        
        self.pickerView.selectRow(index, inComponent: 0, animated: true)
        updateText()
        self.popDelegate?.pickerValueChanged?(textField: self)
    }
    
    func selectRow(obj:Any)
    {
        let anyObj = obj as AnyObject
        let haveIndex = self.objectArray.index(where: {($0 as AnyObject).isEqual(anyObj)})

        //objが存在しないの場合、クリアする
        guard let i = haveIndex else
        {
            self.text = ""
            self.popDelegate?.pickerValueChanged?(textField: self)
            return
        }
        self.pickerView.selectRow( i
            , inComponent: 0
            , animated: false)

        updateText()
        self.popDelegate?.pickerValueChanged?(textField: self)
    }
    
    /// 選択されたオブジェクトを返却
    ///
    /// - Returns: 選択されたオブジェクトを返却,未選択時空の配列を返却
    func getSelectedObject()->Any
    {
        if self.text == ""
        {
            return ""
        }
        else
        {
            return self.pickerView.getSelectedObject()
        }
    }
    
    func getSelectedIndex()->Int
    {
        if self.text == ""
        {
            return -1
        }
        else
        {
            return self.pickerView.selectedRow(inComponent: 0)
        }
    }
    
    func getSelectedDisplay()->String
    {
        if self.text == ""
        {
            return ""
        }
        else
        {
            return self.pickerView.getSelectedDisplay()
        }
    }
    
}
