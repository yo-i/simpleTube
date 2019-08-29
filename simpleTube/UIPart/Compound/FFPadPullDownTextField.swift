//
//  FFPullDownTextField.swift
//  Tiamat
//
//  Created by yo_i on 2018/01/30.
//  Copyright © 2018年 Open Resource Corporation. All rights reserved.
//

import UIKit

@objc protocol FFPadPullDownTextFieldDelegate : NSObjectProtocol
{
    @objc optional func pullDownValueChanged(textField:FFPadPullDownTextField)
}

class FFPadPullDownTextField : UITextField,UITextFieldDelegate ,FFPopoverViewControllerDelegate
{
    var pickerView : FFSimpleTableView!
    var popPicker : FFPopoverViewController!                        //ポップビュー
    var isClear : Bool = false                                      //クリアボタン押下時か
    var presentFromViewController : UIViewController!               //表示元のVC
    var popDelegate: FFPadPullDownTextFieldDelegate?
    //表示用
    var displayArray:Array<String> = []
    //表示された項目に対応するオブジェクト
    var objectArray:Array<Any> = []
    
    override var isEnabled: Bool
        {
        willSet {
            backgroundColor = newValue ? UIColor.white : UIColor.disabledGrey
        }
    }
    
    /// 初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - presentFromViewController: プレゼント元になるVC
    ///   - pulldownSize: pop表示サイズデフォルト(width: 300, height: 200)
    ///   - displayArray: 表示用配列
    ///   - objectArray: オブジェクト保持用配列
    init(frame:CGRect,presentFromViewController : UIViewController
        ,pullDownSize:CGSize = CGSize(width: 300, height: 200)
        ,displayArray:Array<String> = []
        ,objectArray:Array<Any> = [])
    {
        super.init(frame: frame)
        self.displayArray = displayArray
        self.objectArray = objectArray
        self.presentFromViewController = presentFromViewController
        self.delegate = self
        setSelfStyle()
        createPopPicker(size: pullDownSize)
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
    
    func createPopPicker(size:CGSize)
    {
        popPicker = FFPopoverViewController()
        popPicker.setBaseView(showFromView: self, presenFromViewController: self.presentFromViewController)
        pickerView = FFSimpleTableView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        pickerView.layer.borderColor = UIColor.white.cgColor
        popPicker.view.addSubview(pickerView)
        popPicker.contentSize = pickerView.frame.size
        popPicker.delegate = self
    }
    
    
    /// ポップアップのサイズを再設定
    ///
    /// - Parameter newSize: サイズ
    func resetContentSize(newSize:CGSize)
    {
        self.popPicker.contentSize = newSize
        self.pickerView.frame.size = newSize
    }
    
    func updateText()
    {
        self.text = self.pickerView.getSelectedDisplay()
        self.popDelegate?.pullDownValueChanged?(textField: self)
    }
    //テキストフィールドが編集始まる前の処理
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        //クリアボタン押下時はポップカレンダー表示しない
        if self.isClear == true
        {
            self.text = ""
            self.isClear = false
            self.pickerView.selectRow(at: nil, animated: false, scrollPosition: .none)
            self.popDelegate?.pullDownValueChanged?(textField: self)
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
        self.pickerView.selectRow(at: nil, animated: false, scrollPosition: .none)
        self.pickerView.reloadData()
    }
    
    //インデックス指定行を選択
    func selectRow(index:Int)
    {
        if index >= self.displayArray.count
            || index < 0
        {
            self.text = ""
            self.popDelegate?.pullDownValueChanged?(textField: self)
            return
        }
        
        let path = IndexPath(row: index, section: 0)
        self.pickerView.selectRow(at: path, animated: true, scrollPosition: UITableViewScrollPosition.top)
        updateText()
        self.popDelegate?.pullDownValueChanged?(textField: self)
    }
    
    //オブジェクト指定行を選択
    func selectRow(obj:Any)
    {
        let anyObj = obj as AnyObject
        let haveIndex = self.objectArray.index(where: {($0 as AnyObject).isEqual(anyObj)})
        
        //objが存在しないの場合、クリアする
        guard let i = haveIndex else
        {
            self.text = ""
            self.popDelegate?.pullDownValueChanged?(textField: self)
            return
        }
        let path = IndexPath(row: i, section: 0)
        self.pickerView.selectRow(at: path, animated: true, scrollPosition: UITableViewScrollPosition.top)
        
        updateText()
        self.popDelegate?.pullDownValueChanged?(textField: self)
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
    
    /// 選択されたオブジェクトを文字列として返却、文字列変換できない場合、空文字列を返却
    ///
    /// - Returns: 選択されたオブジェクトを返却,未選択時空文字
    func getSelectedObjectAsString()->String
    {
        if self.text == ""
        {
            return ""
        }
        else
        {
            return (self.pickerView.getSelectedObject() as? String) ?? ""
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
            return self.pickerView.indexPathForSelectedRow!.row
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
