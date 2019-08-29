//
//  FFRedrawButton.swift
//  Tiamat
//
//  Created by yo_i on 2018/06/28.
//  Copyright © 2018年 Open Resource Corporation. All rights reserved.
//

import UIKit
class FFRedrawButton:FFButton
{
    var gradlayerColors = [UIColor.actusBlue,UIColor.white]
    var gradPoints = (start:CGPoint(x:1.0,y:0.5),end:CGPoint(x:0.0,y:0.5))
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.layer.cornerRadius = 0
        self.layer.masksToBounds = false
        self.type = .manual
    }
    
    convenience init(frame: CGRect,title:String)
    {
        self.init(frame: frame)
        setTitle(title, for: .normal)
        setTitleColor(.actusBlue, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect)
    {
        let customelayer = UIBezierPath()
        
        let wid:CGFloat = 3
        customelayer.move(to: CGPoint.init(x: rect.width - wid, y: 0))
        customelayer.addLine(to: CGPoint.init(x: rect.width - wid, y: rect.height - wid))
        customelayer.addLine(to: CGPoint.init(x: 0, y: rect.height - wid))
        customelayer.addLine(to: CGPoint.init(x: 0, y: rect.height))
        customelayer.addLine(to: CGPoint.init(x: rect.width, y: rect.height))
        customelayer.addLine(to: CGPoint.init(x: rect.width, y: 0))
        customelayer.close()
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = customelayer.cgPath
        
        let gradLayer = CAGradientLayer()
        gradLayer.frame = rect
        gradLayer.colors = self.gradlayerColors.map({$0.cgColor})
        gradLayer.mask = maskLayer
        gradLayer.startPoint = gradPoints.start
        gradLayer.endPoint = gradPoints.end
        self.layer.insertSublayer(gradLayer, below: self.titleLabel?.layer)
    }
}
