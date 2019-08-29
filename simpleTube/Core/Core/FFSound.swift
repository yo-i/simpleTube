//
//  FFSound.swift
//  FFFWSample
//
//  Created by yo_i on 2017/11/10.
//  Copyright © 2017年 yo_i. All rights reserved.
//

import Foundation
import AudioUnit


/// 音声を鳴らす
class FFSound
{
    
    /// システム音声
    ///
    /// - Parameter soundId: 音声ID
    static func playSound(soundId:UInt32)
    {
        AudioServicesPlaySystemSound(soundId)
    }
    
    
    //TODO: 未検証
    /// 音声ファイル再生
    ///
    /// - Parameter filePath: ファイルパス
    static func playSound(filePath:String)
    {
        var soundIdRing:SystemSoundID = 0
        let fileUrl = URL(fileURLWithPath: FFFileManager.wrapperPath(path: filePath))
        AudioServicesCreateSystemSoundID(fileUrl as CFURL, &soundIdRing)
        AudioServicesPlaySystemSound(soundIdRing)
        
    }
    
    
    /// パイプ(iphoneのみ有効)
    static func playVibrate()
    {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    /// ショットパイプ(iphoneのみ有効)
    static func playShortVibarte()
    {
        AudioServicesPlaySystemSound(1003)
    }
    
}
