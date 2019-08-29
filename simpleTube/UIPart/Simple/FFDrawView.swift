//
//  FFDrawView.swift
//  Artemis
//
//  Created by yo_i on 2017/11/21.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

/// 手書きView
class FFDrawView:DrawView
{
    
    /// 初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - penColor: 手書きの色
    ///   - backImage: 背景画像 設定しなければクリアの背景になる
    init(frame: CGRect,penColor:UIColor,backImage:UIImage? = nil)
    {
        super.init(frame: frame)
        self.color = penColor
        self.backgroundColor = .clear
        if backImage != nil
        {
            setBackgroundImage(img: backImage!)
        }
        self.setBorder(borderWidth: 1, borderColor: .actusBlue)
        let trTapGesture = UITapGestureRecognizer(target: self, action: #selector(tripTap))
        trTapGesture.numberOfTapsRequired = 3
        self.addGestureRecognizer(trTapGesture)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    @objc func tripTap()
    {
        self.lines = []
        self.setNeedsDisplay()
    }
    /// 背景画像をセット
    ///
    /// - Parameter img: 画像
    func setBackgroundImage(img:UIImage)
    {
        let imgView = UIImageView(frame: self.frame)
        imgView.image = img
        imgView.contentMode = .scaleAspectFit
        self.backgroundColor = UIColor(patternImage: imgView.toImage())
    }
    
    
    
}
