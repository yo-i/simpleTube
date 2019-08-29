//
//  FFPadSeachPullDownTextField.swift
//  Tiamat
//
//  Created by yo_i on 2018/04/05.
//  Copyright © 2018年 Open Resource Corporation. All rights reserved.
//

import UIKit
class FFPadSeachPullDownTextField:FFPadPullDownTextField,UITableViewDelegate,UITableViewDataSource
{
    var searchText:UITextField!
    var selectDisplayString = ""
    var searchedArray:[String] = []

    /// 初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - presentFromViewController: プレゼント元になるVC
    ///   - pulldownSize: pop表示サイズデフォルト(width: 400, height: 200)
    ///   - displayArray: 表示用配列
    ///   - objectArray: オブジェクト保持用配列
    override init(frame:CGRect,presentFromViewController : UIViewController
        ,pullDownSize:CGSize = CGSize(width: 400, height: 320)
        ,displayArray:Array<String> = []
        ,objectArray:Array<Any> = [])
    {
        super.init(frame: frame
            , presentFromViewController: presentFromViewController
            , pullDownSize: pullDownSize
            , displayArray: displayArray
            , objectArray: objectArray)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func createPopPicker(size:CGSize)
    {
        popPicker = FFPopoverViewController()
        popPicker.setBaseView(showFromView: self, presenFromViewController: self.presentFromViewController!)
        pickerView = FFSimpleTableView(frame: CGRect(x: 0, y: 40, width: size.width, height: size.height - 40.0))
        pickerView.layer.borderColor = UIColor.white.cgColor
        popPicker.view.addSubview(pickerView)
        
        searchText = UITextField(frame: CGRect(x: 1, y: 1, width: size.width-2, height: 38))
        searchText.layer.borderWidth = 1.0
        searchText.layer.borderColor = UIColor.lightGray.cgColor
        searchText.placeholder = " 絞り込み"
        searchText.layer.cornerRadius = 9
        searchText.clearButtonMode = .always
        searchText.addTarget(self, action: #selector(self.textValueChanged(sender:)), for: .editingChanged)
        popPicker.view.addSubview(searchText)
        
        popPicker.contentSize = size
        popPicker.delegate = self
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
    }
    //////////////////////////////////////////////
    //delegaeとdataSource
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchText.text!.count > 0 ? searchedArray.count : displayArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "seachPullDownTextFieldCell") as UITableViewCell
        cell.textLabel!.text = searchText.text!.count > 0 ? searchedArray[indexPath.row] : displayArray[indexPath.row]
        cell.backgroundColor = UIColor.clear
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.cellSelected
        cell.selectedBackgroundView = selectedBackgroundView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectDisplayString = searchText.text!.count > 0 ? searchedArray[indexPath.row] : displayArray[indexPath.row]
    }
    
    override func updateText()
    {
        self.text = getSeachSelectedIndex() == nil ? "" : displayArray[getSeachSelectedIndex()!]
        self.popDelegate?.pullDownValueChanged?(textField: self)
    }
    
    //オブジェクト指定行を選択
    override func selectRow(obj:Any)
    {
        let anyObj = obj as AnyObject
        let haveIndex = self.objectArray.index(where: {($0 as AnyObject).isEqual(anyObj)})
        
        print(self.pickerView.getSelectedDisplay())
        
        
        //objが存在しない場合、クリアする
        guard let i = haveIndex else
        {
            self.text = ""
            selectDisplayString = ""
            self.popDelegate?.pullDownValueChanged?(textField: self)
            return
        }
        let path = IndexPath(row: i, section: 0)
        self.pickerView.selectRow(at: path, animated: true, scrollPosition: UITableViewScrollPosition.top)
        selectDisplayString = displayArray[haveIndex!]
        
        updateText()
        self.popDelegate?.pullDownValueChanged?(textField: self)
    }
    //入力変更イベント
    @objc func textValueChanged(sender:UITextField)
    {
        print(#function)
        var index = 0
        if sender.text == ""
        {
            searchedArray = displayArray
        }
        else
        {
            //結果含むの検索
            //searchedArray = displayArray.filter({$0.contains(sender.text!)})
            
            //検索文字も検索対象も　大文字変換し全角変換してから文字列を検索
            let toSearch = (sender.text ?? "").uppercased().parseHalfToWidth()
            let containsedDisplayArray = displayArray.filter({  $0.uppercased().parseHalfToWidth().contains(toSearch) })
            searchedArray = containsedDisplayArray
        }
        
        self.pickerView.reloadData()
        
        //既存選択肢がいない場合、処理終了
        if searchedArray.index(of: selectDisplayString) == nil
        {
            return
        }
        
        index = searchedArray.index(of: selectDisplayString)!
        
        let indexPath = IndexPath(row: index, section: 0)
        
        self.pickerView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
        
    }
    
    override func popShouldDismiss()
    {
        updateText()
        //検索単語を廃棄
        searchText.text = ""
        textValueChanged(sender: searchText)
    }
    
    func getSeachSelectedIndex()->Int?
    {
        if self.pickerView.indexPathForSelectedRow == nil
        {
            return nil
        }
        else
        {
            return displayArray.index(of: selectDisplayString)
        }
    }
    
    
    /// 選択されたオブジェクトを返却
    ///
    /// - Returns: 選択されたオブジェクトを返却,未選択時空の配列を返却
    override func getSelectedObject()->Any
    {
        if self.text == ""
        {
            return ""
        }
        else
        {
            if getSeachSelectedIndex() == nil
            {
                return ""
            }
            else
            {
                return self.objectArray[getSeachSelectedIndex()!]
            }
            
        }
    }
    
    /// 選択されたオブジェクトを文字列として返却、文字列変換できない場合、空文字列を返却
    ///
    /// - Returns: 選択されたオブジェクトを返却,未選択時空文字
    override func getSelectedObjectAsString()->String
    {
        if self.text == ""
        {
            return ""
        }
        else
        {
            if getSeachSelectedIndex() == nil
            {
                return ""
            }
            else
            {
                return (self.objectArray[getSeachSelectedIndex()!] as? String) ?? ""
            }
        }
    }
    
    override func getSelectedIndex()->Int
    {
        if self.text == ""
        {
            return -1
        }
        else
        {
            if getSeachSelectedIndex() == nil
            {
                return -1
            }
            else
            {
                return getSeachSelectedIndex()!
            }
        }
    }
    
    override func getSelectedDisplay()->String
    {
        if self.text == ""
        {
            return ""
        }
        else
        {
            if getSeachSelectedIndex() == nil
            {
                return ""
            }
            else
            {
                return self.displayArray[getSeachSelectedIndex()!]
            }
        }
    }
}
