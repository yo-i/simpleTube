//
//  FFBaseMainViewControllerDesigner.swift
//  Tiamat
//
//  Created by yo_i on 2018/01/24.
//  Copyright © 2018年 Open Resource Corporation. All rights reserved.
//

import UIKit
extension FFBaseMainViewController
{
    static let trainingImg = UIImage(named: "training_icon.png")
    func createNavigationBarCustomizeArea()
    {
        navigationBarLeftArea = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        navigationBarRightArea = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        
        let leftItem = UIBarButtonItem(customView: navigationBarLeftArea)
        let rightItem = UIBarButtonItem(customView: navigationBarRightArea)
        
        self.navigationItem.setLeftBarButton(leftItem, animated: true)
        self.navigationItem.setRightBarButton(rightItem, animated: true)
    }
    

    
    func createNavigationBarBackButton()
    {
        navigationBarBackButton = UIButton(frame: CGRect(x: 0, y: 0 , width: 100, height: 40))
        navigationBarBackButton.setTitle("＜ 戻る", for: .normal)
        navigationBarBackButton.setTitleColor(.actusBlue, for: .normal)
        navigationBarBackButton.setTitleColor(.actusBlueHighlight, for: .highlighted)
        navigationBarBackButton.setTitleColor(.liteGrey, for: .disabled)
        navigationBarBackButton.contentHorizontalAlignment = .left
        navigationBarBackButton.addTarget(self, action: #selector(self.navigationControollerPopView), for: .touchUpInside)
        self.navigationBarLeftArea.addSubview(navigationBarBackButton)
    }
    
    func createNavigationBarNextButton()
    {
        navigationBarNextButton = UIButton(frame: CGRect(x: 400 - 150, y: 0 , width: 150, height: 40))
        navigationBarNextButton.setTitle("次の画面", for: .normal)
        navigationBarNextButton.setTitleColor(.actusBlue, for: .normal)
        navigationBarNextButton.setTitleColor(.actusBlueHighlight, for: .highlighted)
        navigationBarNextButton.setTitleColor(.liteGrey, for: .disabled)
        navigationBarNextButton.contentHorizontalAlignment = .right
        navigationBarNextButton.addTarget(self, action: #selector(self.navigationControollerPushNextView), for: .touchUpInside)
        self.navigationBarRightArea.addSubview(navigationBarNextButton)
    }
    
    func createNavigationBarHomeButton()
    {
        navigationBarHomeButton = UIButton(type: UIButtonType.contactAdd)
        navigationBarHomeButton.frame.origin = CGPoint(x: 110, y: 10)
        navigationBarHomeButton.setImage(UIImage.init(named: "homeIcon") , for: .normal)
        navigationBarHomeButton.tintColor = UIColor.actusBlue
        navigationBarHomeButton.addTarget(self, action: #selector(self.clickNavigationBarHomeButton), for: .touchUpInside)
        self.navigationBarLeftArea.addSubview(navigationBarHomeButton)
    }
    
    func createNavigationBarInfoButton()
    {
        navigationBarInfoButton = UIButton(type: UIButtonType.infoLight)
        navigationBarInfoButton.frame.origin = CGPoint(x: 180, y: 10)
        navigationBarInfoButton.tintColor = UIColor.actusBlue
        navigationBarInfoButton.addTarget(self, action: #selector(self.clickNavigationBarInfoButton), for: .touchUpInside)
        self.navigationBarRightArea.addSubview(navigationBarInfoButton)
    }
    
    func createContentView()
    {
        contentView = UIView(frame: CGRect(x: 12
            , y: getContenViewStartY()
            , width: 1000
            , height: Int(self.view.frame.height) - getContenViewStartY() - FFBaseMainViewController.subMenuHeight))
        contentView.backgroundColor = UIColor.clear
        self.view.addSubview(contentView)
    }
    

    func createSubMenuBar()
    {
        let rect = CGRect(x: 0
            , y: self.view.frame.height - CGFloat(FFBaseMainViewController.subMenuHeight)
            , width: self.view.frame.width
            , height: CGFloat(FFBaseMainViewController.subMenuHeight))
        subMenuBar = UIView(frame: rect)
        subMenuBar.backgroundColor = .liteGrey
        self.view.addSubview(subMenuBar)
    }
    
}
