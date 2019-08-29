//
//  FFSwitch.swift
//  Artemis
//
//  Created by yo_i on 2017/11/21.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit

/// 標準Swithの色指定
/// -attention valueChangedイベントは発火タイミングはタッチしたタイミングで発生する,valueChangedイベントのハンドリングは避けましょう
class FFSwitch:UISwitch
{
    // MARK: -
    override func willMove(toSuperview newSuperview: UIView?)
    {
        setSelfStyle()
    }
    // MARK: -　外観設定
    func setSelfStyle()
    {
        self.tintColor      = UIColor.disabledGrey          //off状態の色
        self.onTintColor    = UIColor.actusBlue             //on状態の色
        
        self.addTarget(self, action: #selector(self.playSound), for: .valueChanged)
    }
    @objc func playSound()
    {
        FFSound.playSound(soundId: 1104)
    }
}

