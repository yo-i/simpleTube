//
//  FFSegementedControl.swift
//  Artemis
//
//  Created by yo_i on 2017/11/22.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

class FFSegementedControl: UISegmentedControl
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSelfStyle()
    }
    override init(items: [Any]?)
    {
        super.init(items: items)
        setSelfStyle()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func setSelfStyle()
    {
        self.tintColor = UIColor.actusBlue
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 5
        //通常時の文字色
        let normalFont = NSDictionary(objects: [FFFont.boldSystemFontOfSize(20),UIColor.actusBlue]
            , forKeys: [NSAttributedStringKey.font as NSCopying ,NSAttributedStringKey.foregroundColor as NSCopying])
        //選択された時の文字色
        let selectedFont = NSDictionary(objects: [FFFont.boldSystemFontOfSize(20),UIColor.white]
            , forKeys: [NSAttributedStringKey.font as NSCopying ,NSAttributedStringKey.foregroundColor as NSCopying])
        //使用不可の文字色
        let disabledFont = NSDictionary(objects: [FFFont.boldSystemFontOfSize(20),UIColor.lightGray]
            , forKeys: [NSAttributedStringKey.font as NSCopying ,NSAttributedStringKey.foregroundColor as NSCopying])
        
        self.setTitleTextAttributes(normalFont as? [AnyHashable : Any], for: .normal)
        self.setTitleTextAttributes(selectedFont as? [AnyHashable : Any], for: .selected)
        self.setTitleTextAttributes(disabledFont as? [AnyHashable : Any], for: .disabled)
        
        self.addTarget(self, action: #selector(self.segeTaped), for: UIControlEvents.valueChanged)
    }
    
    func setFont(font:UIFont)
    {
        //通常時の文字色
        let normalFont = NSDictionary(objects: [font]
            , forKeys: [NSAttributedStringKey.font as NSCopying])
        //選択された時の文字色
        let selectedFont = NSDictionary(objects: [font]
            , forKeys: [NSAttributedStringKey.font as NSCopying ])
        //使用不可の文字色
        let disabledFont = NSDictionary(objects: [font]
            , forKeys: [NSAttributedStringKey.font as NSCopying])
        
        self.setTitleTextAttributes(normalFont as? [AnyHashable : Any], for: .normal)
        self.setTitleTextAttributes(selectedFont as? [AnyHashable : Any], for: .selected)
        self.setTitleTextAttributes(disabledFont as? [AnyHashable : Any], for: .disabled)
    }
    
    @objc func segeTaped()
    {
        FFSound.playSound(soundId: 1104)
    }
    
    
    
}




