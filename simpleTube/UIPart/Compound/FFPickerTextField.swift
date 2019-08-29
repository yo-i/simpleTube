//
//  FFPickerTextField.swift
//  Artemis
//
//  Created by Actus_03 on 2017/12/08.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

class FFPickerTextField : UITextField
{
    var pickerView : FFFlexPicker!
    //表示用
    var displayArray:Array<String> = []
    //表示された項目に対応するオブジェクト
    var objectArray:Array<Any> = []
    
    
    /// 初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - displayArray: 表示用配列
    ///   - objectArray: 表示された項目に対するオブジェクト
    init(frame:CGRect,displayArray:Array<String>,objectArray:Array<Any>)
    {
        super.init(frame: frame)
        self.displayArray = displayArray
        self.objectArray = objectArray
        self.delegate = self
        setSelfStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //外観設定
    func setSelfStyle()
    {
        self.clearButtonMode = UITextFieldViewMode.never                           //クリアボタン常に非表示
        self.borderStyle = UITextBorderStyle.roundedRect                            //角丸
        self.textAlignment = .center                            //中央表示
        self.layer.borderColor = UIColor.borderColor.cgColor     //枠の色
        self.backgroundColor = UIColor.pickerTextFieldColor      //背景色
        self.textColor = UIColor.white                          //フォントカラー
        self.font = FFFont.systemFontOfSize(20)                 //フォント
        
        createPickerView()
        
    }
    
    func createPickerView()
    {
        pickerView = FFFlexPicker(displayArray: displayArray, objectArray: objectArray)
        pickerView.delegate = self
    }
    //テキストフィールド更新
    func updateText()
    {
        let index = pickerView.selectedRow
        self.text = displayArray[index]
    }
}

extension FFPickerTextField : UITextFieldDelegate,FFFlexPickerDelegate
{
    //編集始める時の処理
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.superview?.addSubview(pickerView)
        self.superview?.bringSubview(toFront: pickerView)
        
        //ピッカー表示
        self.pickerView.showPicker()
        //キーボード非表示
        return false
    }
    //ピッカー非表示になるときの処理
    func flexPickerViewDidHide(pickerView: UIPickerView)
    {
        updateText()
    }
}
