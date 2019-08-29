//
//  FFComboTableView.swift
//  Artemis
//
//  Created by yo_i on 2017/11/28.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import UIKit


/// 簡易tableView
/// displayArrayとobjectArrayの数を一致する必要があります
class FFSimpleTableView:UITableView,UITableViewDelegate,UITableViewDataSource
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
    override init(frame: CGRect, style: UITableViewStyle)
    {
        super.init(frame: frame, style: style)
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
        self.delegate = self
        self.dataSource = self
        
        //cell線を詰め
        self.separatorInset = UIEdgeInsets.zero
        //cell上の余白を詰める
        //self.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
        //枠線の設定
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 7.5
        
        //複数選択デフォルトfalse
        self.allowsMultipleSelection = false
        
    }
    
    
    //////////////////////////////////////////////
    //delegaeとdataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return displayArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "comboTableCell") as UITableViewCell
        cell.textLabel!.text = displayArray[indexPath.row]
        cell.backgroundColor = UIColor.clear
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.cellSelected
        cell.selectedBackgroundView = selectedBackgroundView
        return cell
    }
    //選択状態を解除する
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    {
        let workcell = self.cellForRow(at: indexPath)
        if workcell?.isSelected == true
        {
            self.deselectRow(at: indexPath, animated: true)
            return nil
        }
        else
        {
            return indexPath
        }
    }
    
    /// 選択しているかどうか
    ///
    /// - Returns: 選択されていないfalse以外true
    func isSeleceted()->Bool
    {
        return indexPathsForSelectedRows == nil ? false : true
    }
    
    
    func getSelectedIndex()->Int?
    {
        return self.indexPathForSelectedRow?.row
    }
    
    /// 選択されたオブジェクトを返却
    ///
    /// - Returns: 選択されたオブジェクトを返却,未選択時空の配列を返却
    func getSelectedObject()->Any
    {
        if self.isSeleceted()
        {
            return objectArray[indexPathForSelectedRow!.row]
        }
        else
        {
            return ""
        }
    }
    
    /// 選択された行の文字列を返却
    ///
    /// - Returns: 選択された行の文字列を返却,未選択時空の配列を返却
    func getSelectedDisplay()->String
    {
        if self.isSeleceted()
        {
            return displayArray[indexPathForSelectedRow!.row]
        }
        else
        {
            return ""
        }
    }
    
    /// 選択されたオブジェクトを返却
    ///
    /// - Returns: 選択されたオブジェクトを返却,未選択時空の配列を返却
    func getSelectedObjects()->[Any]
    {
        var resultArray:[Any] = []
        if self.isSeleceted()
        {
            //indexをmap、ソートも掛ける
            for index in indexPathsForSelectedRows!.map({$0.row}).sorted()
            {
                resultArray.append(objectArray[index])
            }
        }
        return resultArray
    }
    
    
    /// 選択された行の文字列を返却
    ///
    /// - Returns: 選択された行の文字列を返却,未選択時空の配列を返却
    func getSelectedDisplays()->[String]
    {
        var resultArray:[String] = []
        if self.isSeleceted()
        {
            //indexをmap、ソートも掛ける
            for index in indexPathsForSelectedRows!.map({$0.row}).sorted()
            {
                resultArray.append(displayArray[index])
            }
        }
        return resultArray
    }
    
}

