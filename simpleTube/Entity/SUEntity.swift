//
//  SUEntity.swift
//  simpleTube
//
//  Created by yo_i on 2019/08/30.
//  Copyright © 2019年 yang. All rights reserved.
//

import Foundation
import SwiftyJSON
let GoogleApiKey:String = "AIzaSyCr58GUWUuFoQ2ROgqLWe4i50FLkAqkwVg"
let GoogleApiBaseUrl:String = "https://www.googleapis.com/youtube/v3/"

/// エンティティベース
class YTEntityBase:NSObject
{
    var entitySelected:Bool = false
    var controlInfo:Dictionary<String,String> = [:]
    /// エンティティ中のパラメータの初期化が必須
    required override init(){}
    
    /// ディプコッピー、同じクラスのインターフェイスを作成
    ///
    /// - Returns: 自分のコッピー
    override func copy() -> Any
    {
        let newInstase = type(of: self).init()
        return newInstase
    }
    
    
    /// 該当エンティティはweb通信のパラメータとして使う場合、実装する
    ///
    /// - Returns: 通信パラメータのハッシュテーブル
    func getParamToDictionary()->FFDataSetDictionary
    {
        //デフォルトパラメータとサービスのパラメータ名一致することを想定している、じゃない場合、手動でkeyとvalueをセットするが必要です
        var resultDic = FFDataSetDictionary()
        let mirror = Mirror.init(reflecting: self)
        for m in mirror.children
        {
            guard let key = m.label else
            {
                continue
            }
            if m.value is String
            {
                if (m.value as! String).count > 0
                {
                    resultDic[key] = m.value
                }
            }
            else if m.value is [String]
            {
                resultDic[key] = (m.value as! [String]).joined(separator: ",")
            }
            
            
        }
        return resultDic
    }
    
    /// 該当エンティティはをjson文字列に変換
    ///
    /// - Returns: json文字列
    func getParamJsonString()->String
    {
        return String.init(data: FFCore.jsonSerialization(jsonObjec: self.getParamToDictionary()) ?? Data() , encoding: .utf8) ?? ""
    }
    
}

enum YTRequestType:String
{
    case videos     = "videos"
    case playLists  = "playlists"
    case search     = "search"
}

class YTVideosRequest:YTEntityBase
{
    var apiType:YTRequestType = .videos //apiタイプ
    var q:[String] = []                 //検索用key
    var id:[String] = []                //動画id
    var key:String = GoogleApiKey       //認証key
    var part:[String] = ["snippet"]     //レスポンスパラメータ
    var maxResults:String = ""
    var type:String = ""
    func getFullUrl() -> String
    {
        return GoogleApiBaseUrl + self.apiType.rawValue + "?" + self.getParamToDictionary().toUrlParam()
    }
}

