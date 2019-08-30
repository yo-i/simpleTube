//
//  SUListViewTableCell.swift
//  simpleTube
//
//  Created by yo_i on 2019/08/30.
//  Copyright © 2019年 yang. All rights reserved.
//

import UIKit

class SUListViewTableCell:UITableViewCell
{
    var thumbnailView:FFImageView!
    var titleLabel:FFLabel!
    var titleLabelWidth = 100
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?,titleLabelWidth:Int = 100)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.titleLabelWidth = titleLabelWidth
        initializeView()
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.clear
        self.selectedBackgroundView = selectedBackgroundView
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializeView()
    {
        thumbnailView = FFImageView(frame: CGRect(x: 5, y: 5, width: 80, height: 50))
        thumbnailView.isUserInteractionEnabled = true
        thumbnailView.isPreviewEnable = true
        thumbnailView.contentMode = .scaleAspectFit
        self.contentView.addSubview(thumbnailView)
        
        titleLabel = FFLabel(frame: CGRect(x: 85, y: 5, width: titleLabelWidth - 90, height: 20)
            , text: "")
        titleLabel.font = FFFont.systemFontOfSize(12)
        titleLabel.numberOfLines = 0
        self.contentView.addSubview(titleLabel)
        
    }
}
