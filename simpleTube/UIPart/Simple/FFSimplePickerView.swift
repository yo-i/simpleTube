//
//  FFPickerView.swift
//  Artemis
//
//  Created by yo_i on 2017/12/01.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import UIKit
class FFSimplePickerView: UIPickerView,UIPickerViewDataSource,UIPickerViewDelegate
{
    //表示用
    var displayArray:Array<String> = []
    //表示された項目に対応するオブジェクト
    var objectArray:Array<Any> = []
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initSetting()
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSetting()
    }
    
    convenience init(frame: CGRect,displayArray:[String],objectArray:[Any])
    {
        self.init(frame: frame)
        self.displayArray = displayArray
        self.objectArray = objectArray
    }
    
    /// 初期化設定
    private func initSetting()
    {
        self.dataSource = self
        self.delegate = self
        //枠線の設定
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 7.5
        
    }
    
    //delegate&dataSource
    //表示する列
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    //表示する行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return displayArray.count
    }
    
    //表示する文字列
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return self.displayArray[row]
    }
    
    
    
    /// 選択されたオブジェクトを返却
    ///
    /// - Returns: 選択されたオブジェクトを返却,未選択時空の配列を返却
    func getSelectedObject()->Any
    {
        if self.objectArray.count == 0 { return ""}
        let index = self.selectedRow(inComponent: 0)
        return self.objectArray[index]
        
    }
    
    
    /// 選択された行の文字列を返却
    ///
    /// - Returns: 選択された行の文字列を返却,未選択時空の配列を返却
    func getSelectedDisplay()->String
    {
        if self.displayArray.count == 0 { return ""}
        let index = self.selectedRow(inComponent: 0)
        return self.displayArray[index]
    }
    
}

