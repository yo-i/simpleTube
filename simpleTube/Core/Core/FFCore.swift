//
//  FFCore.swift
//  FFFWSample
//
//  Created by yo_i on 2017/11/10.
//  Copyright © 2017年 yo_i. All rights reserved.
//

import Foundation
import UIKit

//タイプ定義
///文字列key　任意タイプvalue
typealias FFDataSetDictionary       = Dictionary<String,Any>
///文字列key　文字列value
typealias FFDataSetStringDictionary = Dictionary<String,String>


/// airプリンターUrl用キー
let AIR_PRINTER_URL_KEY  = "airPrintUrl"
/// airプリンター表示名用キー
let AIR_PRINTER_NAME = "airPrintName"
///起動モード用キー
let BOOT_MODE = "bootMode"
///定義マスタ最終更新日用キー
let MASTER_LAST_UPDATE_DAY = "masterLastUpdateDay"
///受注情報マスタ最終更新日用キー
let ORDER_LAST_UPDATE_DAY = "orderLastUpdateDay"


/// 共通で使われている処理
class FFCore {
    
    /// ランダムのUUID生成
    ///
    /// - Returns: uuidストリング(例：A94CCB61-B87B-429B-9D2A-9AAE72AAC88F)
    static func uuid()->String
    {
        return UUID().uuidString
    }
    
    
    ///歯車の設定の読み込み又は軽量なデータ保持の読み込み
    ///
    /// - Parameter forKey: 取得するキー
    /// - Returns: バリュー文字列、キー存在しない場合ブランクを返却
    static func getUserDefaulte(forKey:String)->String
    {
        return UserDefaults.standard.string(forKey:forKey) ?? ""
    }
    
    
    /// 軽量なデータ保持
    ///
    /// - Parameters:
    ///   - forKey: 対象キー
    ///   - value: 対象バリュー
    static func setUserDefaulte(forKey:String,value:String)
    {
        UserDefaults.standard.setValue(value, forKey: forKey)
        UserDefaults.standard.synchronize()
    }
    
    
    /// airPrinterオブジェクト取得
    ///
    /// - Returns: airPrinter未設定時nil以外printerを返却
    static func getAirPrint()->UIPrinter?
    {
        let printUrlString = UserDefaults.standard.string(forKey:AIR_PRINTER_URL_KEY)
        if printUrlString == nil
        {
            return nil
        }
        else
        {
            let printUrl = URL(string: printUrlString!)!
            return UIPrinter(url: printUrl)
        }
        
    }
    

    
    /// Jsonデシリアライズ
    ///
    /// - Parameter jsondata: data
    /// - Returns: 戻り値をキャストして使う
    static func jsonDeserialization(jsondata:Data)->Any?
    {
        do
        {
            return try JSONSerialization.jsonObject(with: jsondata, options: .allowFragments)
        }
        catch
        {
            log.error("error jsonDeserialization")
            return nil
        }
    }
    
    
    /// Jsonシリアライズ
    ///
    /// - Parameter jsonObjec: シリアライズできるオブジェクト
    /// - Returns: jsonData
    static func jsonSerialization(jsonObjec:Any)->Data?
    {
        do
        {
            return try JSONSerialization.data(withJSONObject: jsonObjec, options: .prettyPrinted)
        }
        catch
        {
            log.error("error jsonSerialization")
            return nil
        }
    }
    
    //ポイントとポイントの距離計算
    static func distance(a:CGPoint, b:CGPoint) -> Double
    {
        return Double(sqrt(pow(b.x - a.x, 2) + pow(b.y - a.y, 2)))
    }
    
    /// ローカルファイルをシリアライズしたJson形式として読み込み
    ///
    /// - Parameter path: ファイルパス
    /// - Returns: Jsonデータ(辞書型)
    static func readFileToJsonData(path:String)->FFDataSetDictionary
    {
        if FFFileManager.haveFileOrDirectory(path: path)
        {
            return (FFCore.jsonDeserialization(jsondata: FFFileManager.readBinaryFile(path: path)!) as? FFDataSetDictionary) ?? FFDataSetDictionary()
        }
        else
        {
            return FFDataSetDictionary()
        }
        
    }
}

