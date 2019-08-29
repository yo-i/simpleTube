//
//  FFPopoverViewController.swift
//  testPhonePopover
//
//  Created by yo_i on 2017/11/30.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import UIKit

@objc protocol FFPopoverViewControllerDelegate : NSObjectProtocol
{
    @objc optional func popShouldDismiss()
}

/// 汎用Popoverコントローラー
class FFPopoverViewController: UIViewController,UIPopoverPresentationControllerDelegate
{
    //プレゼントするVC
    weak var fromViewController:UIViewController?
    //吹き出し元
    var showBaseView:UIView?
    //表示するサイズ、nilの場合、自分のviewのサイズを使用する
    var contentSize:CGSize? = nil
    
    weak var delegate : FFPopoverViewControllerDelegate?               //デリゲート
    
    
    /// 表示元のUIパーツとプレゼン元のViewController
    ///
    /// - Parameters:
    ///   - showFromView: 表示元のUIパーツ
    ///   - presenFromViewController: プレゼン元のViewController
    func setBaseView(showFromView:UIView,presenFromViewController:UIViewController)
    {
        self.showBaseView = showFromView
        self.fromViewController = presenFromViewController
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return .none
    }
    
    
    /// ポップアップで表示
    func presentPop()
    {
        //showBaseViewとfromViewController未設定時、処理終了
        guard let sourceView = showBaseView else
        {
            return
        }
        guard let sourceViewController = fromViewController else
        {
            return
        }
        
        self.modalPresentationStyle = .popover
        /// サイズ設定されてない
        if let size = self.contentSize
        {
            self.preferredContentSize = size
        }
        else
        {
            self.preferredContentSize = self.view.frame.size
        }
        
        if let popoverController = self.popoverPresentationController
        {
            popoverController.permittedArrowDirections = .any
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceView.bounds
            popoverController.delegate = self
        }
        sourceViewController.present(self, animated: true, completion: nil)
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController)
    {
        self.delegate?.popShouldDismiss?()
        self.dismiss(animated: false, completion: nil)
    }
    
}

