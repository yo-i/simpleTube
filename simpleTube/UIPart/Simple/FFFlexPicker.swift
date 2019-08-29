//
//  FFPickerView.swift
//  Artemis
//
//  Created by Actus_03 on 2017/12/01.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

@objc protocol FFFlexPickerDelegate : UIPickerViewDelegate
{
    @objc optional func pickerView(pickerView: UIPickerView,didSelect number : Int)
    @objc optional func flexPickerViewDidShow(pickerView: UIPickerView)
    @objc optional func flexPickerViewDidHide(pickerView: UIPickerView)
    @objc optional func flexPickerViewWillHide(pickerView: UIPickerView)
    @objc optional func flexPickerViewWillShow(pickerView: UIPickerView)
}

class FFFlexPicker : UIView
{
    //表示用
    var displayArray:Array<String> = []
    //表示された項目に対応するオブジェクト
    var objectArray:Array<Any> = []
    
    var pickerView : UIPickerView!                              //ピッカー
    var pickerToolbar : UIToolbar!                              //ツールバー
    
    let screenSize : CGSize = UIScreen.main.bounds.size         //スクリーンサイズ
    var delegate : FFFlexPickerDelegate?                        //デリゲート
    var selectedRow : Int = 0                                   //選択されているインデックス
    var notification : NotificationCenter!                      //通知
    
    /// 初期化
    ///
    /// - Parameters:
    ///   - displayArray: 表示用配列
    ///   - objectArray: 表示された項目に対応するオブジェクト
    init(displayArray:Array<String>,objectArray:Array<Any>)
    {
        super.init(frame: CGRect(x: 0, y: screenSize.height, width:screenSize.width, height: 244))
        self.displayArray = displayArray
        self.objectArray = objectArray
        initSetting()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 初期化設定
    private func initSetting()
    {
        createPickerView()
        createPickerToolbar()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        notification = NotificationCenter.default

    }
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    //ピッカービュー作成
    func createPickerView()
    {
        pickerView = UIPickerView(frame: CGRect(x: 0, y: 44, width: screenSize.width, height: 200))
        pickerView.showsSelectionIndicator = true
        pickerView.backgroundColor = UIColor.lightGray
        pickerView.tintColor = UIColor.black
        self.addSubview(pickerView)
        
    }
    //ツールバー作成
    func createPickerToolbar()
    {
        pickerToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 44))
        pickerToolbar.isTranslucent = false
        //スペーサー
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        //キャンセルボタン
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtonTapped))
        //完了ボタン
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped))
        pickerToolbar.setItems([spacer,cancelButton,doneButton], animated: false)
        self.addSubview(pickerToolbar)
    }
    
    /// 完了ボタン押下
    @objc func doneButtonTapped()
    {
        hidePicker()
        selectedRow = getSelectedRows()
        delegate?.pickerView?(pickerView: self.pickerView, didSelect: selectedRow)
    }
    
    /// キャンセルボタン押下
    @objc func cancelButtonTapped()
    {
        hidePicker()
    }
    
    /// ピッカー表示
    func showPicker()
    {
        self.delegate?.flexPickerViewWillShow?(pickerView: self.pickerView)
        notification.post(name: NSNotification.Name("willShowFlexView"), object: nil)
        checkFlexView()
        self.pickerView.selectRow(selectedRow, inComponent: 0, animated: true)
        UIView.animate(withDuration: 0.5
            , animations: {self.frame = CGRect(x: 0, y: self.screenSize.height - 244, width: self.screenSize.width, height: 294)}
            , completion:{ finish in  self.delegate?.flexPickerViewDidShow?(pickerView: self.pickerView)}
        )
        
    }
    
    
    /// ピッカー非表示
    func hidePicker()
    {
        self.delegate?.flexPickerViewWillHide?(pickerView: self.pickerView)
        UIView.animate(withDuration: 0.5
            , animations: {self.frame = CGRect(x: 0, y: self.screenSize.height, width: self.screenSize.width, height: 244)}
            , completion:{ finish in  self.delegate?.flexPickerViewDidHide?(pickerView: self.pickerView)}
        )
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
    
    /// 選択されているインデックスを取得
    ///
    /// - Returns: インデックス
    private func getSelectedRows() -> Int
    {
        return self.pickerView.selectedRow(inComponent: 0)
    }
    
    /// 選択されたオブジェクトを返却
    ///
    /// - Returns: 選択されたオブジェクトを返却,未選択時空の配列を返却
    func getSelectedObject()->Any
    {
        let index = self.pickerView.selectedRow(inComponent: 0)
        return self.objectArray[index]
        
    }
    
    
    /// 選択された行の文字列を返却
    ///
    /// - Returns: 選択された行の文字列を返却,未選択時空の配列を返却
    func getSelectedDisplay()->String
    {
        let index = self.pickerView.selectedRow(inComponent: 0)
        return self.displayArray[index]
    }
}

extension FFFlexPicker : UIPickerViewDelegate , UIPickerViewDataSource
{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return displayArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return displayArray[row]
    }
    
    
}
