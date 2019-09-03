//
//  SUAppendIDView.swift
//  simpleTube
//
//  Created by yo_i on 2019/08/30.
//  Copyright © 2019年 yang. All rights reserved.
//

import UIKit
import SwiftyJSON
class SUAppendIDView:FFBaseSubViewController
{
    override var okNotificationName     : String { return "sub.appendId.ok"}
    var responseId = ""
    var inputText:FFTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "動画URL又はID"
        self.contentSize = CGSize(width: 300, height: 200)
    }
    
    override func initializeView()
    {
        super.initializeView()

        inputText = FFTextField(frame: CGRect(x: 5, y: 60, width: 280, height: 40))
        inputText.font = FFFont.systemFontOfSize(12)
        self.contentView.addSubview(inputText)
        
    }
    
    override func initViewStatus()
    {
        super.initViewStatus()
    }
    
    override func clickOkButton()
    {
        //let sourceString = "https://www.youtube.com/watch?v=7lCDEYXw3mM"
        
        self.responseId = SUAppendIDView.searchForId(sourceStr: inputText.text ?? "")
        
        if self.responseId == ""
        {
            errorAlert()
            return
        }
        
        let viewRequest = YTVideosRequest()
        viewRequest.id = [self.responseId]
        viewRequest.apiType = .videos
        
        
        let apiUrl = viewRequest.getFullUrl()
        log.info(apiUrl)
        let webCore = FFWebCore()
        let result = webCore.getSync(urlStr: apiUrl)
        if result.success
        {
            let sJson = try! JSON(data:result.data ?? Data())
            if sJson["items"].count == 0
            {
                errorAlert()
                return
            }
        }
        else
        {
            errorAlert()
            return
        }
        
        super.clickOkButton()
        
    }
    
    class func searchForId(sourceStr:String)->String
    {
        //なんかIDが１１桁
        if sourceStr.count == 11
        {
            return sourceStr
        }
        else
        {
            let url = URL(string: sourceStr)
            if url != nil
            {
                switch url!.host ?? ""
                {
                    case "youtu.be":
                        
                    return url!.lastPathComponent
                    
                    case "www.youtube.com" :
                        let dic = SUListView.makeReceiveUrlToDictionary(url!)
                        let id = dic["v"] ?? ""
                        log.info(id)
                        return id
                    default :
                    return ""
                }
            }
            else
            {
                return ""
            }
            
        }
    }
    
    
    func errorAlert()
    {
        let alert = FFAlert()
        alert.showAlert(message: "URL又はIDが不正", type: .error, withNoButton: false)
    }
}
