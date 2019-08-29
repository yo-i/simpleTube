//
//  FFLabel.swift
//  Artemis
//
//  Created by yo_i on 2017/11/21.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import UIKit


/// 標準UILableの拡張
class FFLabel: UILabel
{
    private var lineLayer:CAShapeLayer?
    var redStarView:UILabel? = nil
    var isRequired:Bool = false
    {
        didSet
        {
           controlStar()
        }
        
    }
    /// 書式付き初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - text: テキスト
    ///   - textAlignment: テキスト寄せ
    ///   - fontSize: フォントサイズ
    ///   - color: 色
    init(frame: CGRect,text: String,textAlignment: NSTextAlignment,fontSize: CGFloat,color:UIColor)
    {
        super.init(frame: frame)
        self.font = FFFont.systemFontOfSize(fontSize)
        self.text = text
        self.textAlignment = textAlignment
        self.textColor = color
    }
    
    
    /// 書式付き初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - text: テキスト
    ///   - textAlignment: テキスト寄せ
    ///   - fontSize: フォントサイズ
    convenience init(frame: CGRect,text: String,textAlignment: NSTextAlignment,fontSize: Int)
    {
        self.init(frame: frame, text: text, textAlignment: textAlignment, fontSize: CGFloat(fontSize),color:.black)
    }
    
    
    /// テキスト付き初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - text: テキスト
    convenience init(frame: CGRect,text: String)
    {
        self.init(frame: frame, text: text, textAlignment: .left, fontSize: CGFloat(17),color:.black)
    }
    
    
    /// テキスト色付き初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - text: テキスト
    ///   - color: <#color description#>
    convenience init(frame: CGRect,text: String,color:UIColor)
    {
        self.init(frame: frame, text: text, textAlignment: .left, fontSize: CGFloat(17),color:color)
    }
    /// 初期化
    ///
    /// - Parameter frame: フレーム
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.font = FFFont.systemFontOfSize()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.font = FFFont.systemFontOfSize()
    }
    
    /// 必須の★を付けるメソッド
    /// UIパーツを20px左にずらし★付で表示する
    /// このメソッドの後に、textColorでの色変更すると★も変わるから注意
    
    func requiredStar()
    {
//        let textr:String = "★ " + self.text!
//
//        //指定位置から20ピクセル左に拡張し表示する
//        frame = CGRect(x: frame.origin.x - 20, y: frame.origin.y, width: frame.size.width + 20, height: frame.size.height)
//
//        //★を赤く塗る
//        let attrText = NSMutableAttributedString(string: textr)
//        attrText.addAttribute(.foregroundColor,
//                              value: UIColor.red, range: NSMakeRange(0, 1))
//        self.attributedText = attrText
        
        self.isRequired = true
    }
    
    func controlStar()
    {
        if isRequired
        {
            showStar()
        }
        else
        {
            hiddenStar()
        }
    }
    
    
    func showStar()
    {
        if redStarView != nil
        {
            redStarView!.removeFromSuperview()
        }
        redStarView = UILabel(frame: CGRect(x: -15, y: 0, width: 20, height: frame.height)   )
        redStarView?.text = "★"
        redStarView?.textColor = .red
        self.addSubview(redStarView!)
    }
    func hiddenStar()
    {
        redStarView?.removeFromSuperview()
    }
    

    
    /// アンダーラインを描く
    func drawUnderLine(lineWidth:Int = 1,color:UIColor = .black)
    {
        self.lineLayer?.removeFromSuperlayer()
        
        var frame = self.frame
        frame.origin.x = 0
        frame.size = CGSize(width: self.frame.width, height: CGFloat(lineWidth))
        frame.origin.y = self.frame.height - CGFloat(lineWidth)
        
        let linePath = UIBezierPath(rect: frame)
        linePath.move(to: CGPoint.init(x: 0, y: 0))
        linePath.addLine(to: CGPoint.init(x: self.frame.size.width, y: 0))
        linePath.close()
        
        let maskLayer = CAShapeLayer()
        maskLayer.fillColor = color.cgColor
        maskLayer.path = linePath.cgPath
        self.layer.insertSublayer(maskLayer, at: 100000)
        self.layoutIfNeeded()
        
        self.lineLayer = maskLayer
    }
    
    
    
    /// アンダーラインを消す
    func removeUnderLine()
    {
        self.lineLayer?.removeFromSuperlayer()
    }
    
}

