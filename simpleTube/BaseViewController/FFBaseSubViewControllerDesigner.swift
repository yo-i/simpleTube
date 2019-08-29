//
//  FFBaseSubViewControllerDesigner.swift
//  Tiamat
//
//  Created by yo_i on 2018/01/24.
//  Copyright © 2018年 Open Resource Corporation. All rights reserved.
//

import UIKit
extension FFBaseSubViewController
{
    func createMaskView()
    {
        maskView = UIView(frame: UIScreen.main.bounds)
        maskView.backgroundColor = UIColor.lightGray
        maskView.alpha = 0.5
        maskView.isUserInteractionEnabled = true
        self.view.addSubview(maskView)
    }
    
    func createContentView()
    {
        contentView = UIView(frame:UIScreen.main.bounds)
        contentView.backgroundColor = UIColor.white
        contentView.frame.size = (contentSize == nil) ? defContentSize : contentSize!
        contentView.center.x = maskView.center.x
        contentView.frame.origin.y = -(contentView.frame.height + 20)
        self.view.addSubview(contentView)
    }
    
    func createTitleLabel()
    {
        let titleLabelFrame = CGRect(x: 20 , y: 10, width: contentView.frame.size.width - 20 * 2, height: 40)
        titleLabel = FFLabel(frame: titleLabelFrame, text: self.title ?? "")
        titleLabel.font = FFFont.systemFontOfSize(20)
        titleLabel.textColor = UIColor.actusBlue
        self.contentView.addSubview(titleLabel)
        
        let line = UIView(frame: CGRect(x: 20 , y: titleLabel.frame.origin.y + titleLabel.frame.height + 1, width: contentView.frame.size.width - 20 * 2, height: 1))
        line.backgroundColor = UIColor.liteGrey
        self.contentView.addSubview(line)
        
    }
    
    func createOkButton()
    {
        let okButtonFrame = CGRect(x: Int(contentView.frame.width) - FFButton.defWidth - 10 , y: Int(contentView.frame.height) - 50, width: FFButton.defWidth, height: FFButton.defHeight)
        if okButtonTitle.count > 0
        {
            okButton = FFButton(frame: okButtonFrame , title: okButtonTitle)
        }
        else
        {
            okButton = FFButton(frame: okButtonFrame , title: "OK")
        }
        okButton.type = .mainProcess
        okButton.addTarget(self, action: #selector(self.clickOkButton), for: .touchUpInside)
        if withOkButton
        {
            self.contentView.addSubview(okButton)
        }
    }
    
}
