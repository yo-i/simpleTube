//
//  FFRichSegmentedControl.swift
//  Artemis
//
//  Created by yo_i on 2017/12/08.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import HMSegmentedControl
//見た目リッチなSegmentedControl
class FFRichSegmentedControl:HMSegmentedControl
{
    var childViews:[UIView] = []
    override init(sectionTitles sectiontitles: [String])
    {
        super.init(sectionTitles: sectiontitles)!
        setSelfStyle()
    }
    
    override init(sectionImages: [UIImage]!, sectionSelectedImages: [UIImage]!)
    {
        super.init(sectionImages: sectionImages, sectionSelectedImages: sectionSelectedImages)!
        setSelfStyle()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func setSelfStyle()
    {
        self.selectionStyle = .fullWidthStripe
        self.selectionIndicatorLocation = .down
        self.selectionIndicatorColor = UIColor.actusBlue
        self.addTarget(self, action: #selector(self.valueChange(sender:)), for: .valueChanged)
    }
    
    
    @objc func valueChange(sender:FFRichSegmentedControl)
    {
        if sender.childViews.count == 0 || sender.selectedSegmentIndex < 0 { return }
        sender.superview?.bringSubview(toFront: sender.childViews[sender.selectedSegmentIndex])
    }
}
