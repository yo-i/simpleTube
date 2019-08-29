//
//  FFAesEncrypt.swift
//  FFFWSample
//
//  Created by yo_i on 2017/11/16.
//  Copyright © 2017年 yo_i. All rights reserved.
//

import Foundation
/// 暗号化キー
fileprivate let AES_KEY = "orc@Password0120orc@Password0120"
/// 暗号化ベクトル
fileprivate let AES_IV  = "orc@Password0120"


/// 暗号化、復号化
/// Stringのextensionに暗号化復号化用のメソッドを提供する
class FFAesEncrypt
{
    /// 暗号化
    /// (暗号化ルールはiPadPosと一致)
    ///
    /// - Parameter str: 対象文字列
    /// - Returns: 暗号化後文字列,空白暗号化しない
    class func encryptString(_ str:String)->String
    {
//        if str.count == 0
//        {
//            return ""
//        }
//
//        let encryptData:Data! = str.data(using: String.Encoding.utf8)!
//        let keyData:Data! = AES_KEY.data(using: String.Encoding.utf8)!
//        let ivData:Data! = AES_IV.data(using: String.Encoding.utf8)!
//
//        let data = FBEncryptorAES.encryptData(encryptData, key: keyData, iv: ivData)
//        return data!.base64EncodedString(options: .endLineWithLineFeed)
        return str
    }
    
    
    /// 複号化
    /// (複号化ルールはiPadPosと一致)
    ///
    /// - Parameter str: 対象文字列
    /// - Returns: 複号化後文字列 
    static func decryptString(_ str:String)->String
    {
//        let decryptData:Data! = Data(base64Encoded: str, options: [])
//        let keyData:Data! = AES_KEY.data(using: String.Encoding.utf8)!
//        let ivData:Data! = AES_IV.data(using: String.Encoding.utf8)!
//
//        let data = FBEncryptorAES.decryptData(decryptData, key: keyData, iv: ivData)
//
//        if data == nil
//        {
//            log.error("decryptString error")
//            return ""
//        }
//        else
//        {
//            if data!.count == 0
//            {
//                return ""
//            }
//            return String(data: data!, encoding: String.Encoding.utf8) ?? ""
//        }
        return str
    }
    
}
