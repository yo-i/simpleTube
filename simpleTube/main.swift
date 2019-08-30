//
//  main.swift
//  simpleTube
//
//  Created by yo_i on 2019/08/29.
//  Copyright © 2019年 yang. All rights reserved.
//

import Foundation
import UIKit
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//main関数は特殊な関数のため、絶対ファイル名を変更しないでください
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//公式ドキュメントhttps://developer.apple.com/documentation/swift/commandline
//main関数を実装
UIApplicationMain(
    CommandLine.argc,                                   //arge定数
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)     //swift更新後の型不一致
        .bindMemory(
            to: UnsafeMutablePointer<Int8>.self,
            capacity: Int(CommandLine.argc)),
    NSStringFromClass(FFApplication.self),              //UIApplicationから継承したクラス
    NSStringFromClass(AppDelegate.self)                 //AppDelegate又はAppDeleateから継承したクラス
)
