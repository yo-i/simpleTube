//
//  FFDrawerMenuButton.swift
//  Artemis
//
//  Created by Actus_03 on 2017/12/05.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

class FFDrawerMenuButton : FFButton
{
    var transitionVC : UIViewController!
    
    init(frameY : CGFloat,title : String,transitionVC : UIViewController)
    {
        super.init(frame: CGRect(x: 0, y: frameY, width: 250, height: 50))
        self.setTitle("   " + title, for: .normal)
        self.transitionVC = transitionVC
        self.titleLabel?.font = FFFont.systemFontOfSize(17)
        self.contentHorizontalAlignment = .left
        self.backgroundColor = UIColor.white
        self.setTitleColor(UIColor.black, for: .normal)
        self.addSubview(createArrowLabel())
    }
    
    func createArrowLabel() -> FFLabel
    {
        let arrowLabel = FFLabel(frame: CGRect(x: 210, y: 0, width: 40, height: 50)
            , text: ">"
            , textAlignment: .center
            , fontSize: 20)
        arrowLabel.textColor = UIColor.lightGray
        return arrowLabel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
