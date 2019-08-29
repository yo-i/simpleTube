//
//  FFFileManager.swift
//  FFFWSample
//
//  Created by yo_i on 2017/11/02.
//  Copyright © 2017年 yo_i. All rights reserved.
//

import Foundation
import SSZipArchive
/// ファイル操作クラス
/// ファイルに出力、ファイルの読み込み、ファイルの圧縮、ファイルの解凍など行う
/// 既存FileManageの機能にpathのドメイン補完、画面側の負担を減らす
class FFFileManager
{
    ///  -fileDomainPath iTunesから参照できるのRootPath
    static let FILE_DOMAIN_PATH = NSSearchPathForDirectoriesInDomains(
        FileManager.SearchPathDirectory.documentDirectory
        , FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    
    /// FILE_DOMAIN_PATHをマスク後のルートパス、基本はブランク、ソース上""のパスは違和感を感じるので、定数として使う
    static let ROOT_PATH = ""
    
    
    /// pathにFileDomainを加える
    ///
    /// - Parameter path: path
    /// - Returns: ラッピングしたいpath
    static func wrapperPath(path:String)->String
    {
        return FILE_DOMAIN_PATH + "/" + path
    }
    
    /// 文字列をファイルに書き出し
    ///
    /// - Parameters:
    ///   - path: ファイルパス
    ///   - str: 対象文字列
    static func writeToFlie(path:String,str:String)
    {
        let filePath = FILE_DOMAIN_PATH + "/" + path
        do
        {
            try str.write(to: URL(fileURLWithPath: filePath)
                , atomically: true, encoding: .utf8)
        }
        catch
        {
            log.error("write to file error" + path)
        }
    }
    
    /// バイナリデータをファイルに書き出し
    ///
    /// - Parameters:
    ///   - path: ファイルパス
    ///   - data: バイナリデータ
    static func writeToFile(path:String,data:Data)
    {
        let filePath = FILE_DOMAIN_PATH + "/" + path
        do
        {
            try data.write(to: URL(fileURLWithPath: filePath))
        }
        catch
        {
            log.error("write to file error" + path)
        }
    }
    
    /// バイナリデータファイルの読み込み
    ///
    /// - Parameter path: ファイルパス
    /// - Returns: 成功した場合データを返却、失敗した場合nil
    static func readBinaryFile(path:String)->Data?
    {
        let filePath = FILE_DOMAIN_PATH + "/" + path
        do
        {
            return try Data(contentsOf: URL(fileURLWithPath: filePath))
        }
        catch
        {
            log.error("read file error" + path)
            return nil
        }
    }
    
    /// 文字列ファイルを読み込み
    ///
    /// - Parameter path: ファイルパス
    /// - Returns: 成功した場合文字列を返却、失敗した場合nil
    static func readTextFile(path:String)->String?
    {
        let filePath = FILE_DOMAIN_PATH + "/" + path
        do
        {
            return try String(contentsOf: URL(fileURLWithPath: filePath))
        }
        catch
        {
            log.error("read file error" + path)
            return nil
        }
    }
    
    /// ファイル確認
    ///
    /// - Parameter path: ファイル(又はフォルダ)パス
    /// - Returns: 存在する場合true、存在しない場合はfalse
    @discardableResult
    static func haveFileOrDirectory(path:String)->Bool
    {
        let filePath = FILE_DOMAIN_PATH + "/" + path
        return FileManager.default.fileExists(atPath:filePath)
    }
    
    
    /// ディレクトリ内のファイル名一覧取得
    ///
    /// - Parameter path: ディレクトリパス
    /// - Returns:　ファイル名一覧
    static func getFileList(path:String) -> [String]
    {
        let filePath = FILE_DOMAIN_PATH + "/" + path
        do
        {
            return try FileManager.default.contentsOfDirectory(atPath: filePath)
        }
        catch
        {
            return []
        }
        
    }
    
    
    
    /// ファイル更新日取得
    ///
    /// - Parameter path: ファイルパス
    /// - Returns: ファイルの更新日
    static func getUpdatedDate(path : String) -> Date?
    {
        let filePath = FILE_DOMAIN_PATH + "/" + path
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
            return attributes.fileModificationDate()!
        }
        catch let error as NSError {
            log.error("can't get fileUpdatedDate  filePath : " + filePath)
            log.error(error)
            return nil
            
        }
    }
    /// ファイル作成日取得
    ///
    /// - Parameter path: ファイルパス
    /// - Returns: ファイルの作成日
    static func getCreatedDate(path : String) -> Date?
    {
        let filePath = FILE_DOMAIN_PATH + "/" + path
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
            return attributes.fileCreationDate()!
        }
        catch let error as NSError {
            log.error("can't get fileCreatedDate  filePath : " + filePath)
            log.error(error)
            return nil
        }
    }
    
    /// ファイルサイズ取得
    ///
    /// - Parameter path: ファイルパス
    /// - Returns: ファイルサイズ
    static func getFileSize(path : String) -> UInt64?
    {
        let filePath = FILE_DOMAIN_PATH + "/" + path
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
            return attributes.fileSize()
        }
        catch let error as NSError {
            log.error("can't get fileUpdatedDate  filePath : " + filePath)
            log.error(error)
            return nil
        }
    }
    
    /// フォルダ作成(中間フォルダ自動作成)
    ///
    /// - Parameter path: フォルダパス
    /// - Returns: フォルダ作成成功ならtrue
    @discardableResult
    static func tryCreateDirectory(path:String)->Bool
    {
        let directoryPath = FILE_DOMAIN_PATH + "/" + path
        let directoryUrl = URL(fileURLWithPath: directoryPath, isDirectory: true)
        do
        {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
            return true
        }
        catch
        {
            log.error("create Directory error" + path)
            return false
        }
    }
    
    
    /// フォルダ作成(中間フォルダ自動作成)
    ///
    /// - Parameter path: フォルダパス
    /// - Returns: フォルダパス
    static func createDirectory(path:String)->(result:Bool,path:String)
    {
        let directoryPath = FILE_DOMAIN_PATH + "/" + path
        if !FileManager.default.fileExists(atPath: directoryPath)
        {
            if tryCreateDirectory(path: path)
            {
                return (true,"/" + path)
            }
            else
            {
                return (false,"")
            }
        }
        else
        {
            return (true,"/" + path)
        }
    }
    
    
    /// ファイル移動
    ///
    /// - Parameters:
    ///   - atPath: 元パス
    ///   - toPath: 移動先パス
    static func moveItem(atPath:String,toPath:String)
    {
        let atFullPath = FILE_DOMAIN_PATH + "/" + atPath
        let toFullPath = FILE_DOMAIN_PATH + "/" + toPath
        do
        {
            try FileManager.default.moveItem(atPath: atFullPath, toPath: toFullPath)
        }
        catch
        {
            log.error("move item error" + "atPath:" + atPath + "toPath:" + toPath)
        }
    }
    
    /// ファイルコピー
    ///
    /// - Parameters:
    ///   - atPath: 元パス
    ///   - toPath: コピー先パス
    static func copyItem(atPath:String,toPath:String)
    {
        let atFullPath = FILE_DOMAIN_PATH + "/" + atPath
        let toFullPath = FILE_DOMAIN_PATH + "/" + toPath
        do
        {
            try FileManager.default.copyItem(atPath: atFullPath, toPath: toFullPath)
        }
        catch
        {
            log.error("copy item error" + "atPath:" + atPath + "toPath:" + toPath)
        }
    }
    
    
    /// ファイル(フォルダ)削除
    ///
    /// - Parameter path: ファイルパス
    static func deleteItem(path:String)
    {
        let filePath = FILE_DOMAIN_PATH + "/" + path
        do
        {
            try FileManager.default.removeItem(atPath: filePath)
        }
        catch
        {
            log.error("delete file error" + path)
        }
        
    }
    
    /// zipファイル作成
    /// フォルダごとのzipはできないです、フォルダごと圧縮する場合createZipFile(withContentsOfDirectory:String,zipFilePath:String)を使用する
    ///
    /// - Parameters:
    ///   - filePaths: 対象ファイルパス（複数）
    ///   - zipFilePath: zipファイル出力パス
    static func createZipFile(filePaths:[String],zipFilePath:String)
    {
        //ドメインにマップ
        let mapPaths = filePaths.map({ FILE_DOMAIN_PATH + "/" + $0 })
        
        SSZipArchive.createZipFile(atPath: FILE_DOMAIN_PATH + "/" + zipFilePath
            , withFilesAtPaths: mapPaths)
    }
    
    
    /// zipファイル作成
    ///
    /// - Parameters:
    ///   - withContentsOfDirectory: 対象フォルダ
    ///   - zipFilePath: zipファイル出力パス
    static func createZipFile(withContentsOfDirectory:String,zipFilePath:String)
    {
        //ドメインにマップ
        let dirPath = FILE_DOMAIN_PATH + "/" + withContentsOfDirectory
        let zipPath = FILE_DOMAIN_PATH + "/" + zipFilePath
        
        SSZipArchive.createZipFile(atPath: zipPath, withContentsOfDirectory: dirPath)
    }
    
    /// zipファイル解凍
    ///
    /// - Parameters:
    ///   - zipFilePath: 解凍対象zipファイルパス
    ///   - toDestination: 解凍先(フォルダオーバーライドする)
    static func unzipFile(zipFilePath:String,toDestination:String)
    {
        let fullZipPath = FILE_DOMAIN_PATH + "/" + zipFilePath
        let fullDestiantionPath = FILE_DOMAIN_PATH + "/" + toDestination
        do
        {
            try SSZipArchive.unzipFile(atPath: fullZipPath, toDestination: fullDestiantionPath, overwrite: true, password: nil)
        }
        catch
        {
            log.error("unzip file error " + zipFilePath)
        }
    }
    
    /// サブパスを取得
    /// 例："^productRegist.*zip$" productRegist始まり + 任意文字 + zip終わりの正規表現
    /// 詳細はString のfunc isPredicateEvaluate(regex:String)->Boolのどこを参考
    ///
    /// - Parameters:
    ///   - atPath: フォルダパス
    ///   - filterStr: ファイル名フィルター(正規表現) 設定しない場合は制限なし
    ///
    /// - Returns: サブパス
    static func subPaths(atPath:String,filterStr:String = "")->[String]
    {
        if filterStr == ""
        {
            return (FileManager.default.subpaths(atPath: FFFileManager.FILE_DOMAIN_PATH + "/" + atPath) ?? [])
        }
        else
        {
            return (FileManager.default.subpaths(atPath: FFFileManager.FILE_DOMAIN_PATH + "/" + atPath) ?? [])
                .filter({$0.isPredicateEvaluate(regex: filterStr)})
        }
    }
    
    
    /// フォルダ判定
    ///
    /// - Parameter atPath: パス
    /// - Returns: true for directory false for file
    @discardableResult
    static func isDirectory(atPath:String)->Bool
    {
        var isDir:ObjCBool = false
        FileManager.default.fileExists(atPath: FFFileManager.FILE_DOMAIN_PATH + "/" + atPath, isDirectory: &isDir)
        return isDir.boolValue
    }
    
    /// 指定フォルダ内期限超えのファイルを削除
    ///
    /// - Parameters:
    ///   - limitDays: システム時間から計算X日を超えたら
    ///   - atDirPath: 対象フォルダ(フォルダ内ファイル再帰的取得)
    static func deleteFileInDirectory(limitDays:Int,directoryPath:String)
    {
        let subPaths = FFFileManager.subPaths(atPath: directoryPath).map({ directoryPath + "/" + $0})
        for subPath in subPaths
        {
            if FFFileManager.isDirectory(atPath: subPath)
            {
                //フォルダの場合何もしない
            }
            else
            {
                if let lastdate = FFFileManager.getCreatedDate(path: subPath)
                {
                    if Date().intervalDays(date: lastdate) >= limitDays
                    {
                        FFFileManager.deleteItem(path: subPath)
                        log.info("delete file at " + subPath + "after " + limitDays.toString() + "day(s)")
                    }
                }
            }
        }
    }
    
    
}



