//
//  FFLog.swift
//  FFFWSample
//
//  Created by yo_i on 2017/11/06.
//  Copyright © 2017年 yo_i. All rights reserved.
//

import Foundation
import XCGLogger


let productionLog = XCGLogger(identifier: "production", includeDefaultDestinations: true)
let trainingLog = XCGLogger(identifier: "training", includeDefaultDestinations: true)
var log : XCGLogger {return productionLog}

/// ログ格納するフォルダ
///
/// - production: 本番
/// - tranning: トレーニング
enum FFLogDirectoryPath:String
{
    case production         = "Log/Production"          //本番
    case tranning           = "Log/Training"            //トレーニング
}

enum FFLogFileName:String
{
    case staticFileName = "log.txt"
}


/// ログライブラリ情報の初期化
class FFLog
{
    static func initLogObject()
    {
        let todayString = Date().toString("yyyyMMdd_")
        initLogObject(logFileName: todayString + FFLogFileName.staticFileName.rawValue)
    }
    static func initLogObject(logFileName:String)
    {
        setTrainingLog(logFileName:logFileName)
        setProductionLog(logFileName:logFileName)
    }
    
    private static func setProductionLog(logFileName:String)
    {
        //フォルダ存在しない場合自動作成
        let directoryProductionPath = FFFileManager.FILE_DOMAIN_PATH + FFFileManager.createDirectory(path: FFLogDirectoryPath.production.rawValue).path
        //ファイルパス
        let fileProductionPath = directoryProductionPath + "/" + logFileName
        //logファイル出力の設定
        let fileProductionDestination = FileDestination(writeToFile: fileProductionPath,shouldAppend:true)
        fileProductionDestination.outputLevel = .debug
        fileProductionDestination.showThreadName = true
        productionLog.add(destination: fileProductionDestination)
        //設定適応
        productionLog.logAppDetails()
    }
    private static func setTrainingLog(logFileName:String)
    {
        //フォルダ存在しない場合自動作成
        let directoryTrainingPath = FFFileManager.FILE_DOMAIN_PATH + FFFileManager.createDirectory(path: FFLogDirectoryPath.tranning.rawValue).path
        //ファイルパス
        let fileTrainingPath = directoryTrainingPath + "/" + logFileName
        //logファイル出力の設定
        let fileTrainingDestination = FileDestination(writeToFile: fileTrainingPath,shouldAppend:true)
        fileTrainingDestination.outputLevel = .debug
        fileTrainingDestination.showThreadName = true
        trainingLog.add(destination: fileTrainingDestination)
        //設定適応
        trainingLog.logAppDetails()
    }

}
