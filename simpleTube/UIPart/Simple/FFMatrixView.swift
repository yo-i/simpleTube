//
//  FFMatrixView.swift
//  Artemis
//
//  Created by Actus_03 on 2017/11/29.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

typealias FFPoint = (x:Int,y:Int)

@objc protocol FFMatrixViewDelegate : NSObjectProtocol
{
    @objc optional func cellTapped()
}

class FFMatrixView : UIView,  UIScrollViewDelegate
{
    
    var columnHeaderView : UIScrollView!                //tableの列
    var rowHeaderView : UIScrollView!                   //tableの行
    var mainView : UIScrollView!                        //tableのメイン
    
    var cellWidth : CGFloat = 0                         //tableセルの長さ
    var cellHeight : CGFloat = 0                        //tableセルの高さ
    
    var columnArray : [String]!                         //列に入る配列
    var rowArray : [String]!                            //行に入る配列
    var mainArray : [[String]]!                         //メインに入る配列
    var switchBackgroundColor:FFSwitchColor? = nil      //メインセル背景色(on,off)
    
    var point:FFPoint? = nil                            //tapしたボタンの座標
    var delegate : FFMatrixViewDelegate?                //デリゲート
    var selectedCell : FFSwitchButton? = nil
    
    
    
    /// 初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - cellWidth: セルの長さ
    ///   - cellHeight: セルの高さ
    ///   - columnArray: 列の配列
    ///   - rowArray: 行の配列
    ///   - mainArray: メインの配列
    ///   - switchBackgroundColor: メインのセルの色指定
    init(frame:CGRect,cellWidth : CGFloat,cellHeight:CGFloat,columnArray:[String],rowArray:[String],mainArray:[[String]],switchBackgroundColor:FFSwitchColor)
    {
        super.init(frame: frame)
        self.cellWidth = cellWidth
        self.cellHeight = cellHeight
        self.columnArray = columnArray
        self.rowArray = rowArray
        self.mainArray = mainArray
        self.point = nil
        self.switchBackgroundColor = switchBackgroundColor
        addSubview(createColumnHeaderView())
        addSubview(createRowHeaderView())
        addSubview(createMainView())
    }
    
    
    /// 色付き初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - cellWidth: セルの長さ
    ///   - cellHeight: セルの高さ
    ///   - columnArray: 列の配列
    ///   - rowArray: 行の配列
    ///   - mainArray: メインの配列
    convenience init(frame:CGRect,cellWidth : CGFloat,cellHeight:CGFloat,columnArray:[String],rowArray:[String],mainArray:[[String]])
    {
        self.init(frame: frame, cellWidth: cellWidth, cellHeight: cellHeight, columnArray: columnArray, rowArray: rowArray, mainArray: mainArray, switchBackgroundColor: (on:UIColor.cellSelected,off:UIColor.lightGray))
    }
    
    /// 色、セルのサイズ付き初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - columnArray: 列の配列
    ///   - rowArray: 行の配列
    ///   - mainArray: メインの配列
    convenience init(frame: CGRect,columnArray:[String],rowArray:[String],mainArray:[[String]])
    {
        self.init(frame: frame, cellWidth:70,cellHeight:30, columnArray: columnArray, rowArray: rowArray, mainArray: mainArray, switchBackgroundColor: (on:UIColor.cellSelected,off:UIColor.lightGray))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //列をセット
    func createColumnHeaderView() -> UIScrollView
    {
        columnHeaderView = UIScrollView(frame: CGRect(x: cellWidth, y: 0, width: self.frame.width - cellWidth, height: cellHeight))
        columnHeaderView.contentSize = CGSize(width: CGFloat(self.columnArray.count) * cellWidth, height: cellHeight)
        columnHeaderView.bounces = false
        columnHeaderView.isScrollEnabled = false
        setColumnHeaderCell()
        return columnHeaderView
    }
    
    func setColumnHeaderCell()
    {
        for (i,str) in columnArray.enumerated()
        {
            let columnCell = FFLabel(frame: CGRect(x: cellWidth * CGFloat(i) , y: 0, width: cellWidth, height: cellHeight)
                , text: str
                , textAlignment: .center
                , fontSize: 15)
            columnHeaderView.addSubview(columnCell)
        }
    }
    //行をセット
    func createRowHeaderView() -> UIScrollView
    {
        rowHeaderView = UIScrollView(frame: CGRect(x: 0, y: cellHeight, width: cellWidth, height: self.frame.height - cellHeight))
        rowHeaderView.contentSize = CGSize(width: cellWidth, height: CGFloat(self.rowArray.count) * cellHeight)
        rowHeaderView.bounces = false
        rowHeaderView.isScrollEnabled = false
        setRowHeaderCell()
        return rowHeaderView
    }
    
    func setRowHeaderCell()
    {
        for (i,str) in rowArray.enumerated()
        {
            let rowCell = FFLabel(frame: CGRect(x: 0, y: cellHeight * CGFloat(i), width: cellWidth, height: cellHeight)
                , text: str
                , textAlignment: .center
                , fontSize: 15)
            rowHeaderView.addSubview(rowCell)
        }
    }
    //メインをセット
    func createMainView() -> UIScrollView
    {
        mainView = UIScrollView(frame: CGRect(x: cellWidth, y: cellHeight, width:self.frame.width - cellWidth , height: self.frame.height - cellHeight))
        mainView.contentSize = CGSize(width: CGFloat(self.columnArray.count) * cellWidth, height: CGFloat(self.rowArray.count) * cellHeight)
        mainView.bounces = false
        mainView.delegate = self
        setMainCell()
        return mainView
    }
    
    func setMainCell()
    {
        for (i,row) in mainArray.enumerated()
        {
            for (m,str) in row.enumerated()
            {
                let mainCell = FFSwitchButton(frame:  CGRect(x: cellWidth * CGFloat(m), y: cellHeight * CGFloat(i), width: cellWidth, height: cellHeight)
                    , titles: (on:str,off:str)
                    , backgroundColors: self.switchBackgroundColor!
                , broderColors:  (on:UIColor.gray,off:UIColor.lightGray))
                mainCell.addTarget(self, action: #selector(self.tappedButton(sender:)), for: .touchDown)
                mainCell.borderWidth = 0
                mainView.addSubview(mainCell)
            }
        }
    }
    
    
    /// ボタンが選択されたときの処理
    ///
    /// - Parameter sender: メインセル
    @objc func tappedButton(sender:FFSwitchButton)
    {
        self.point = (Int(sender.frame.origin.x / self.cellWidth),Int(sender.frame.origin.y / self.cellHeight))
        //初期状態からボタン押下
        if selectedCell == nil
        {
            selectedCell = sender
        }
        //同じボタン押下
        else if selectedCell == sender
        {
            selectedCell = nil
            self.point = nil
        }
        //別のボタン押下
        else
        {
            selectedCell?.setClick(selectedCell!)
            selectedCell = sender
        }
        
        self.delegate?.cellTapped?()
    }
    
    
    
    /// scroll連動(mainViewのみ)
    ///
    /// - Parameter scrollView: scrollしているview
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let contentOffset = scrollView.contentOffset
        
        if scrollView.isEqual(mainView)
        {
            columnHeaderView.contentOffset = CGPoint(x: contentOffset.x, y: 0)
            rowHeaderView.contentOffset = CGPoint(x: 0, y: contentOffset.y)
        }
        
    }
}
