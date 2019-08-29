//
//  DataBaseManageBase.swift
//  FFFWSample
//
//  Created by yo_i on 2017/11/02.
//  Copyright © 2017年 yo_i. All rights reserved.
//

import Foundation
import FMDB


import Foundation
//DBインスタンス(sqliteデータファイル)
//DBインスタンスを増やす場合、case文を追加してください
enum FFDataBaseInstance:String
{
    case local           = "local.db"
    
    
    /// インスタンスファイルのpathに変更
    ///
    /// - Returns: インスタンスのパス
    func toPath()->String
    {
        return FFFileManager.FILE_DOMAIN_PATH + "/" + self.rawValue
    }
    
}


//DB操作の基本クラス
//クエリ基本のインターフェイスを提供する
class FFDataBaseManagerBase
{
    var dataBase:FMDatabase
    
    
    /// 初期化
    ///
    /// - Parameter db: 使用するDBインターフェイス（ファイル）を選択
    init(db:FFDataBaseInstance)
    {
        //データベースファイル
        let domianPath = FFFileManager.FILE_DOMAIN_PATH + "/"
        self.dataBase = FMDatabase(path: domianPath + db.rawValue)
    }
    
    func changeInstance(db:FFDataBaseInstance)
    {
        //データベースファイル
        let domianPath = FFFileManager.FILE_DOMAIN_PATH + "/"
        self.dataBase = FMDatabase(path: domianPath + db.rawValue)
    }
    
    /// テーブル確認
    ///
    /// - Parameter tableName: テーブル名
    /// - Returns: 存在する場合 true それ以外 false
    func tableExists(tableName:String)->Bool
    {
        return self.dataBase.tableExists(tableName)
    }
    
    /// sqlite ファイル最適化
    final func optimizeDatabase()
    {
        self.dataBase.open()
        self.dataBase.executeUpdate("vacuum", withArgumentsIn: [])
        self.dataBase.close()
    }
    
    
    /// sqlクエリ
    ///
    /// - Parameters:
    ///   - sqlString: sql文
    ///   - arguments: インジェクション
    /// - Returns: ハッシュテーブルで返却
    func executeQuery(sqlString:String,arguments:[String])->Array<FFDataSetStringDictionary>
    {
        var resultArray:[FFDataSetStringDictionary] = []
        self.dataBase.open()
        let result = self.dataBase.executeQuery(sqlString, withArgumentsIn: arguments) ?? FMResultSet()
        log.info(sqlString + arguments.description)
        while result.next()
        {
            var dic = FFDataSetStringDictionary()
            let columnamtoim = result.columnNameToIndexMap
            for i in columnamtoim
            {
                let key = String(describing: i.key)
                dic[key] = result.string(forColumn: key)
            }
            resultArray.append(dic)
        }
        defer
        {
            result.close()
            self.dataBase.close()
        }
        return resultArray
        
    }
    
    
    /// sqlクエリバイナリデータを取得
    ///
    /// - Parameters:
    ///   - sqlString: sql文
    ///   - arguments: インジェクション
    /// - Returns: ハッシュテーブルで返却
    func executeQueryData(sqlString:String,arguments:[String])->Array<FFDataSetDictionary>
    {
        var resultArray:[FFDataSetDictionary] = []
        self.dataBase.open()
        let result = self.dataBase.executeQuery(sqlString, withArgumentsIn: arguments)!
        log.info(sqlString + arguments.description)
        while result.next()
        {
            var dic = FFDataSetDictionary()
            let columnamtoim = result.columnNameToIndexMap
            for i in columnamtoim
            {
                let key = String(describing: i.key)
                dic[key] = result.data(forColumn: key)
            }
            resultArray.append(dic)
        }
        defer
        {
            result.close()
            self.dataBase.close()
        }
        return resultArray
        
    }
    
    /// 更新クエリ（毎回コミットするので、200件/s の速度ぐらい）
    ///
    /// - Parameters:
    ///   - sqlString: sql文
    ///   - arguments: インジェクション
    /// - Returns: 更新結果を返却
    func executeUpdate(sqlString:String,arguments:[Any])->Bool
    {
        log.info(sqlString + arguments.description)
        var isSucceeded = false
        autoreleasepool { () -> () in
            self.dataBase.open()
            self.dataBase.beginTransaction()
            //sql実行
            isSucceeded = self.dataBase.executeUpdate(sqlString, withArgumentsIn: arguments)
            
            if isSucceeded
            {
                self.dataBase.commit()
            }
            else
            {
                self.dataBase.rollback()
                log.error("executeUpdate error in sqlString: " + sqlString )
            }
            
            defer
            {
                self.dataBase.close()
            }
        }
        return isSucceeded
        
    }
    
    
    
    /// 更新系クエリの実行
    /// 実行前にopen() ,beginTran()
    /// 実行後にcommin()or rollback() ,close()
    ///
    /// - Parameters:
    ///   - sqlString: sql文
    ///   - arguments: sql引数
    /// - Returns: クエリの実行結果
    func executeUpdateManuelDBProcess(sqlString:String,arguments:[Any])->Bool
    {
        log.info(sqlString + arguments.description)
        return self.dataBase.executeUpdate(sqlString, withArgumentsIn: arguments)
    }
    
    /// 他のDBインスタンスにアタッチ
    ///
    /// - Parameters:
    ///   - db: dbインスタンス
    ///   - names: アタッチ後の物理名
    /// - Returns: アタッチ結果
    func attachDatabase(db:FFDataBaseInstance,names:String)->Bool
    {
        self.dataBase.open()
        
        return self.dataBase.executeStatements("ATTACH DATABASE '" + db.toPath() + "' AS " + names)
    }
    
    ///////以下data操作のラッピング
    func open()
    {
        log.info("dataBase open")
        self.dataBase.open()
    }
    
    func beginTran()
    {
        log.info("dataBase beginTransaction")
        self.dataBase.beginTransaction()
    }
    
    func close()
    {
        log.info("dataBase close")
        self.dataBase.close()
    }
    
    func rollback()
    {
        log.info("dataBase rollback")
        self.dataBase.rollback()
    }
    
    func commit()
    {
        log.info("dataBase commit")
        self.dataBase.commit()
    }
    
}



