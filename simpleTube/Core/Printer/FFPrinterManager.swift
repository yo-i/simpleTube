//
//  FFPrinterManager.swift
//  FFFWSample
//
//  Created by yo_i on 2017/11/13.
//  Copyright © 2017年 yo_i. All rights reserved.
//

import Foundation
import UIKit

/// Airプリンター関連
/// pdfなどの関連
class FFPrinterManager
{
    
    /// プリンター設定
    ///
    /// - Returns: プリンター設定情報
    class func getPrintInfo()->UIPrintInfo
    {
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = FFCore.uuid()               //オリジナルID
        printInfo.duplex = .none                        //両面印刷 none->両面しない
        printInfo.orientation = .portrait               //縦印刷
        printInfo.outputType = .grayscale               //モノクロ
        return printInfo
    }
    
    /// プリンター設定
    ///
    /// - Returns: プリンター設定情報
    class func getPrintInfo(outputType:UIPrintInfoOutputType)->UIPrintInfo
    {
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = FFCore.uuid()               //オリジナルID
        printInfo.duplex = .none                        //両面印刷 none->両面しない
        printInfo.orientation = .portrait               //縦印刷
        printInfo.outputType = outputType               //モノクロ
        return printInfo
    }
    
    /// pdf作成
    ///
    /// - Parameter canvasArray: 帳票配列
    /// - Returns: pdfデータ
    class func createPdfData(canvasArray:Array<FFReportCanvas>)->Data
    {
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 15, width: REPORT_CANVAS_WIDTH, height: REPORT_CANVAS_HEIGHT), nil)
        
        UIGraphicsBeginPDFPage()
        
        let pdfcontext = UIGraphicsGetCurrentContext()
        
        let reversedArray = canvasArray.reversed()
        for page in reversedArray
        {
            page.layer.render(in: pdfcontext!)
            //ラストページ以外は改ページを入れる
            if !(page.isEqual(reversedArray.last) )
            {
                UIGraphicsBeginPDFPage()
            }
        }
        
        UIGraphicsEndPDFContext()
        
        return pdfData as Data
    }
    
    
    /// pdfファイルを作成
    ///
    /// - Parameter canvasArray: 帳票配列
    /// - Returns: pdfファイルパス
    class func saveToPdfFile(canvasArray:Array<FFReportCanvas>)->String
    {
        let pdfData = self.createPdfData(canvasArray: canvasArray)
        let uuidPath = FFCore.uuid() + ".pdf"
        FFFileManager.writeToFile(path: uuidPath, data: pdfData)
        
        return uuidPath
        
    }
    
    
    /// キャンパス配列を印刷
    ///
    /// - Parameter canvasArray: キャンパス配列
    class func printPdf(canvasArray:Array<FFReportCanvas>)
    {
        let pdfData = createPdfData(canvasArray: canvasArray)
        printPdf(pdfData: pdfData)
    }
    
    
    /// キャンパス配列を印刷カラー
    ///
    /// - Parameter canvasArray: キャンパス配列
    class func printColorPdf(canvasArray:Array<FFReportCanvas>)
    {
        let pdfData = createPdfData(canvasArray: canvasArray)
        printColorPdf(pdfData: pdfData)
    }
    
    
    /// pdf印刷
    ///
    /// - Parameters:
    ///   - pdfData: pdfデータ
    ///   - completionHandler: 完了ハンドリング
    class func printPdfWithHandler(pdfData:Data,printInfo:UIPrintInfo = FFPrinterManager.getPrintInfo(),completionHandler:UIPrintInteractionCompletionHandler? = nil)
    {
        let airPrint = FFCore.getAirPrint()
        if airPrint != nil
        {
            autoreleasepool{ () -> () in
                
                let printIntaractionController = UIPrintInteractionController.shared
                
                printIntaractionController.printInfo = printInfo
                printIntaractionController.printingItem = pdfData
                
                printIntaractionController.print(to: airPrint!, completionHandler: completionHandler)
            }
        }
        else
        {
            log.error("print error in not set airPrinter")
        }
    }
    
    
    /// pdf印刷カラー
    ///
    /// - Parameter pdfData:  pdfデータ
    class func printColorPdf(pdfData:Data)
    {
        FFPrinterManager.printPdf(pdfData: pdfData,printInfo:FFPrinterManager.getPrintInfo(outputType: .photo))
    }
    
    /// pdf印刷
    ///
    /// - Parameters:
    ///   - pdfData: pdfデータ
    class func printPdf(pdfData:Data,printInfo:UIPrintInfo = FFPrinterManager.getPrintInfo())
    {
        let airPrint = FFCore.getAirPrint()
        if airPrint != nil
        {
            autoreleasepool{ () -> () in
                
                let printIntaractionController = UIPrintInteractionController.shared
                
                printIntaractionController.printInfo = printInfo
                printIntaractionController.printingItem = pdfData
                
                
                printIntaractionController.print(to: airPrint!, completionHandler: { (controll, completed, error) in
                    
                    if error != nil
                    {
                        log.error("print error " + error.debugDescription)
                    }
                    else
                    {
                        if completed
                        {
                            log.info("print jobname :" + (controll.printInfo?.jobName ?? "") )
                        }
                        else
                        {
                            log.info("print not completed : " + (controll.printInfo?.jobName ?? ""))
                        }
                    }
                })
            }
        }
        else
        {
            log.error("print error in not set airPrinter")
        }
    }
    
    /// airPrint選択画面を表示、選択しプリンターの情報をUserDefaultsに保存
    ///　iPad上ではpopover
    ///  iphone上ではmodel
    ///
    /// - Parameters:
    ///   - from: 表示開始領域(popoverの矢印)
    ///   - view: 表示するview
    static func showPrinterPicker(from:CGRect,view:UIView,button:UIButton? = nil,label:FFLabel? = nil)
    {
        let printerPicker = UIPrinterPickerController(initiallySelectedPrinter: nil)
        
        printerPicker.present(from: from, in: view, animated: false) {  (printerPickerController, didSelect, error) in
            
            //エラーチェック
            if error != nil
            {
                log.error("airPrint select error" + error.debugDescription)
            }
            else
            {
                //選択されたら
                if didSelect
                {
                    if printerPickerController.selectedPrinter != nil
                    {
                        let airPrintUrl = printerPickerController.selectedPrinter!.url.absoluteString
                        let airPrintName = printerPickerController.selectedPrinter!.displayName
                        UserDefaults.standard.setValue(airPrintUrl, forKey: AIR_PRINTER_URL_KEY)
                        UserDefaults.standard.setValue(airPrintName, forKey: AIR_PRINTER_NAME)
                        log.info("airPrint did select url: " + airPrintUrl + "name: " + airPrintName)
                        UserDefaults.standard.synchronize()
                        
                        
                        if button != nil
                        {
                            button?.setTitle(airPrintName, for: .normal)
                            
                        }
                        
                        if label != nil
                        {
                            label?.text = airPrintName
                        }
                    }
                }
                else
                {
                    log.info("airPrint didn't be selected")
                }
                
            }
        }
        
    }
    
}

