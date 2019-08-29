//
//  FFNumPadTextField.swift
//  Tiamat
//
//  Created by yo_i on 2018/01/30.
//  Copyright © 2018年 Open Resource Corporation. All rights reserved.
//

import UIKit

@objc protocol FFNumPadTextFieldDelegate : NSObjectProtocol
{
    @objc optional func clickEnter()
    @objc optional func didClickAnyKey()
}
class FFNumPadTextField:FFTextField,FFNumPadTextFieldDelegate
{
    var padDelegate:FFNumPadTextFieldDelegate?
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNumPadClick(_:)), name: NSNotification.Name(rawValue: FFNumPad.notificationName), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func removeFromSuperview() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func receiveNumPadClick(_ notification:Notification)
    {
        if self.isHidden == true || self.isEnabled == false || self.inUse == false{ return }
        let dictionary = notification.userInfo!.first
        let keyCode = dictionary!.value as! Int
        
        switch keyCode
        {
        case 0...9:
            if self.text!.count + 1 > maxLength{return}
            else { self.text! += keyCode.toString()}
        case FFNumPadKeyType.doubleZero.rawValue:
            if self.text!.count + 2 > maxLength{return}
            else { self.text! += "00"}
        case FFNumPadKeyType.backSpace.rawValue:
            if self.text!.count - 1 < 0{return}
            else { self.text?.removeLast()}
        case FFNumPadKeyType.clear.rawValue:
            self.text = ""
        case FFNumPadKeyType.enter.rawValue:
            padDelegate?.clickEnter?()
        case FFNumPadKeyType.dot.rawValue:
            if self.text!.count + 1 > maxLength{return}
            else if self.text!.count == 0 {return}
            else if self.text!.contains(".") {return}
            else { self.text! += "."}
        default:
            break
        }
        
        padDelegate?.didClickAnyKey?()
        
    }
    
    //編集始まる時キーボードを出さない
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        self.inUse = true
        return false
    }
    //クリアボタンがおされたら
    override func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        //クリア処理
        self.text = ""
        return true
    }
    
}

