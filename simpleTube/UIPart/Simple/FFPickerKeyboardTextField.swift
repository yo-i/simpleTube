//
//  FFPickerKeyboardTextField.swift
//  Artemis
//
//  Created by Actus_03 on 2017/12/25.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

class FFPickerKeyboardTextField  : FFTextField
{
    //表示用
    var displayArray:Array<String> = []
    //表示された項目に対応するオブジェクト
    var objectArray:Array<Any> = []
    
    var presentFromViewController : UIViewController!               //表示元のVC
    var picker : FFSimplePickerView!                                //ピッカー
    var popPicker : FFPopoverViewController!                        //ポップビュー
    var doneButton : FFButton!                                      //完了ボタン
    var keyboardButton : FFButton!                                  //キーボードボタン
    var isKeyboard : Bool = false                                   //キーボード表示か
    
    
    /// 初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - displayArray: 表示用配列
    ///   - objectArray: 表示された項目に対応するオブジェクト
    ///   - presentFromViewController: 表示元のVC
    init(frame: CGRect,displayArray : Array<String>,objectArray:Array<Any>,presentFromViewController : UIViewController)
    {
        super.init(frame: frame)
        self.displayArray = displayArray
        self.objectArray = objectArray
        self.presentFromViewController = presentFromViewController
        self.delegate = self
        createPopPicker()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// ポップピッカー作成
    func createPopPicker()
    {
        popPicker = FFPopoverViewController()
        popPicker.setBaseView(showFromView: self, presenFromViewController: self.presentFromViewController)
        picker = FFSimplePickerView(frame: CGRect(x: 0, y: 0, width: 340, height: 200)
            , displayArray: self.displayArray, objectArray: self.objectArray)
        picker.layer.borderColor = UIColor.white.cgColor
        popPicker.view.addSubview(picker)
        doneButton = FFButton(frame: CGRect(x: 220, y: 185, width: 100, height: 50)
            , title: "Done")
        doneButton.addTarget(self, action: #selector(self.tappedDoneButton), for: .touchUpInside)
        popPicker.view.addSubview(doneButton)
        keyboardButton = FFButton(frame: CGRect(x: 20, y: 185, width: 100, height: 50)
            , title: "手入力")
        keyboardButton.addTarget(self, action: #selector(self.tappedKeyboardButton), for: .touchUpInside)
        popPicker.view.addSubview(keyboardButton)
        popPicker.contentSize = CGSize(width: 340, height: 260)
        popPicker.delegate = self
    }
    
    /// ポップの完了ボタン押下時
    @objc func tappedDoneButton()
    {
        self.text = picker.getSelectedDisplay()
        self.inUse = false
        popPicker.dismiss(animated: false, completion: nil)
    }
    
    /// ポップのキーボードボタン押下時
    @objc func tappedKeyboardButton()
    {
        isKeyboard = true
        popPicker.dismiss(animated: false, completion: nil)
        self.becomeFirstResponder()
    }
    
    /// 選択されたオブジェクトを返却
    ///
    /// - Returns: 選択されたオブジェクトを返却,自由記入時特定コードを返却
    func getSelectedObject()->Any
    {
        let text = self.text
        
        for i in 0 ..< displayArray.count
        {
            if text == displayArray[i]
            {
                return objectArray[i]
            }
            
        }
        //TODO  自由記入時の特定コード
        return 1111
        
    }

}

extension FFPickerKeyboardTextField : FFPopoverViewControllerDelegate
{
    //テキストフィールドが編集始まる前の処理
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        //クリアボタン押下時はポップピッカー表示しない
        if self.isClear == true
        {
            self.text = ""
            self.isClear = false
            return false
        }
        else
        {
            self.inUse = true
            self.superViewRollBack()
            self.superViewInitFrame = self.superview?.frame
            
            //キーボードボタン押下時
            if isKeyboard
            {
                //テキストフィールドがキーボードに重なる場合
                if (convert(textField.frame.origin, to: self.window).y + textField.frame.height) > self.shouldMoveMin
                {
                    self.superViewRollUp(textField.frame.origin.y + textField.frame.height)  //親ビューを上にスクロールする
                }
                return true
            }
            else
            {
                //ピッカー表示
                popPicker.presentPop()
                
                //キーボードを出さない
                return false
            }
            
        }
        
    }
    //編集終わる時の処理
    override func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        self.inUse = false
        self.isKeyboard = false
        return true
    }
    //ポップオーバーを閉じる時の処理
    func popShouldDismiss() {
        self.inUse = false
        self.isKeyboard = false
    }

}
