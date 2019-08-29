//
//  FFDraggableView.swift
//  Artemis
//
//  Created by yo_i on 2017/11/28.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import UIKit

@objc protocol FFDraggableDelegate : NSObjectProtocol
{
    @objc optional func panEvent(sender:UIPanGestureRecognizer,obj:FFDraggableView)
    @objc optional func tapEvent(sender:UITapGestureRecognizer,obj:FFDraggableView)
}

/// ドラッグできるView
class FFDraggableView:UIView
{
    //パンージェスチャー
    var panGesture = UIPanGestureRecognizer()
    //タップジェスチャー
    var tapGesture = UITapGestureRecognizer()
    //最小移動距離(移動単位)
    static var minMove:CGFloat = 5.0
    //一回回転する角度
    static var oneTurn:Double = 90.0
    
    //デリゲート
    var delegate:FFDraggableDelegate?
    
    //回転回数
    var turns = 0
    
    //幅選択
    var selectWidth = false
    //高選択
    var selectHeight = false
    
    var isSelected = false
    
    var type = 0
    //初期化
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedView(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(panGesture)
        self.addGestureRecognizer(tapGesture)
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    //トラックイベント
    @objc func draggedView(_ sender:UIPanGestureRecognizer)
    {
        //ガードsuperview存在、存在しない場合終了
        guard let inView = self.superview else
        {
            return
        }
        
        //自分を一番上に
        inView.bringSubview(toFront: self)
        let translation = sender.translation(in: inView)
        
        //パンーした距離を一定値を超えたら移動する(x軸上)
        if abs(translation.x) >= FFDraggableView.minMove
        {
            //方向あるため、方向を計算してから移動値を算出
            let move = CGFloat(Int(translation.x / FFDraggableView.minMove)) * FFDraggableView.minMove
            let newPoint = nearestPoint(p: CGPoint(x: self.frame.origin.x + move, y: self.frame.origin.y),n: Int(FFDraggableView.minMove))
            if checkMax(p: newPoint)
            {
                self.frame.origin = newPoint
            }
            sender.setTranslation(CGPoint.zero, in: inView)
        }
        
        //パンーした距離を一定値を超えたら移動する(y軸上)
        if abs(translation.y) >= FFDraggableView.minMove
        {
            let move = CGFloat(Int(translation.y / FFDraggableView.minMove)) * FFDraggableView.minMove
            let newPoint = nearestPoint(p: CGPoint(x: self.frame.origin.x, y: self.frame.origin.y + move),n: Int(FFDraggableView.minMove))
            if checkMax(p: newPoint)
            {
                self.frame.origin = newPoint
            }
            sender.setTranslation(CGPoint.zero, in: inView)
        }
        
        self.fitSize()
        
        delegate?.panEvent?(sender: sender, obj: self)
    }
    
    
    /// 回転セット
    ///
    /// - Parameter turns: 90毎の回転数
    func setRotated(turns:Int)
    {
        self.turns = (self.turns + turns) % 4
        self.transform = self.transform.rotated(by: CGFloat(Double.pi * (FFDraggableView.oneTurn * Double(turns) / 180.0)))
        self.fitSize()
    }
    
    
    //タップイベント
    @objc func tappedView(_ sender:UITapGestureRecognizer)
    {
        turns = ( turns + 1 ) % 4   //  回転数を4超えないように制御
        
        UIView.animate(withDuration: 0.1, animations: {

            if self.turns == 0
            {
                self.transform = self.transform.rotated(by: CGFloat(0))
            }
            else
            {
                self.transform = self.transform.rotated(by: CGFloat(Double.pi * 0.5))
            }

        }) { (comp) in
            
            self.fitSize()
            
            self.delegate?.tapEvent?(sender: sender, obj: self)
        }
        
    }
    
    
    ///サイズずれの修正
    func fitSize()
    {
        self.frame = fitFrame()
    }
    
    
    /// サイズずれの計算
    ///
    /// - Returns: 計算し直したRect
    func fitFrame()->CGRect
    {
        return CGRect(x: fitRound(cgfloat: self.frame.origin.x, n: Int(FFDraggableView.minMove))
            , y: fitRound(cgfloat: self.frame.origin.y, n: Int(FFDraggableView.minMove))
            , width: fitRound(cgfloat: self.frame.width, n: Int(FFDraggableView.minMove))
            , height: fitRound(cgfloat: self.frame.height, n: Int(FFDraggableView.minMove)))
        
    }
    
    //小数点の四捨五入
    func fitRound(double:Double,n:Int = Int(FFDraggableView.minMove))->Int
    {
       return Int( round(double) ) / n * n
    }
    
    func fitRound(cgfloat:CGFloat,n:Int = Int(FFDraggableView.minMove))->Int
    {
        return Int( round(cgfloat) ) / n * n
    }
    /// ポイント丸め
    ///
    /// - Parameters:
    ///   - p: ポイント
    ///   - n: 丸めの単位(180,190)
    /// - Returns: 新しい座標
    private func nearestPoint(p:CGPoint,n:Int)->CGPoint
    {
        let newX = fitRound(cgfloat:p.x,n:n)
        let newY = fitRound(cgfloat:p.y,n:n)
        
        return CGPoint(x: newX, y: newY)
    }
    
    
    /// はみ出し判定
    ///
    /// - Parameter p: 判定ポイント
    /// - Returns: はみ出し場合false,以外true
    private func checkMax(p:CGPoint)->Bool
    {
        //ガードsuperview存在、存在しない場合終了
        guard let inView = self.superview else
        {
            return false
        }
        
        //親viewからはみ出し
        if p.x < 0
            || round(p.x) + round(self.frame.width) > round(inView.frame.width)
            || p.y < 0
            || round(p.y) + round(self.frame.height) > round(inView.frame.height)
        {
            
            let distanceP = FFCore.distance(a: p, b: inView.center)
            let distanceC = FFCore.distance(a: self.frame.origin, b: inView.center)
            //中心への距離が縮めってあれば座標更新OK
            if distanceP < distanceC
            {
                //回転ではみ出し物を救い
                return true
            }
            
            return false
        }
        
        return true
    }
    
    
    /// フレーム記録用のデータ取得
    ///
    /// - Returns: フレーム状態[x,y,w(幅),h(高),t(回転数)]
    func getInfoDic()->Dictionary<String,String>
    {
        var dic = Dictionary<String,String>()
        
        let _fitFrame = self.fitFrame()
        
        dic["x"] = fitRound(cgfloat: _fitFrame.origin.x).toString()
        dic["y"] = fitRound(cgfloat: _fitFrame.origin.y).toString()
        dic["w"] = fitRound(cgfloat: _fitFrame.width).toString()
        dic["h"] = fitRound(cgfloat: _fitFrame.height).toString()
        dic["t"] = self.turns.toString()
        dic["type"] = self.type.toString()
        return dic
    }
    
    
}
