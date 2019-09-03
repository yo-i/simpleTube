//
//  SUListView.swift
//  simpleTube
//
//  Created by yo_i on 2019/08/30.
//  Copyright © 2019年 yang. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD

extension Array
{
    func split(num:Int)->Array<Array<Element>>
    {
        var workArray = self
        var result:Array<Array<Element>> = []
        while workArray.count > 0
        {
            let subArr = workArray.prefix(num).map({$0})
            result.append(subArr)
            workArray = workArray.dropFirst(num).map({$0})
        }
        
        return result
    }
}

class SUListView: FFBaseMainViewController,UITableViewDelegate,UITableViewDataSource
{

    var videosIds:[String] = []
    var resultObjs:[JSON] = []
    var listTable:UITableView!
    var viewRequest = YTVideosRequest()
    
    var subView = SUAppendIDView()
    var subButtonAdd:FFButton!
    var subButtonPlayAll:FFButton!
    let onceRequestMax = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTable = UITableView(frame: CGRect(x: 0, y: 60, width: self.view.frame.width, height:  self.view.frame.height - 70 - (self.navigationController?.navigationBar.frame.height)! ))
        listTable.dataSource = self
        listTable.delegate = self
        self.view.addSubview(listTable)
        

        videosIds = SUVideosDao.sheard.select().map({$0["id"]!})
        getVideosList(ids: videosIds)

        self.notificationCenter.addObserver(self, selector: #selector(self.getAppendIdViewOk), name: NSNotification.Name(subView.okNotificationName), object: nil)
        
        subButtonAdd = FFButton()
        subButtonAdd.setTitle("動画追加", for: .normal)
        subButtonAdd.subMenuBranchDivision = 0
        subButtonAdd.addTarget(self, action: #selector(self.showSubView), for: .touchUpInside)
        self.subMenuBarButtons.append(subButtonAdd)
        
        layoutSubMenuButtons(branchDivision: 0)
        
    }
    
    func getVideosList(ids:[String])
    {

        resultObjs = []
        viewRequest = YTVideosRequest()
        for workId in ids.split(num: onceRequestMax)
        {
            viewRequest.id = workId
            viewRequest.apiType = .videos
            
            
            let apiUrl = viewRequest.getFullUrl()
            log.info(apiUrl)
            let webCore = FFWebCore()
            let result = webCore.getSync(urlStr: apiUrl)
            if result.success
            {
                let sJson = try! JSON(data:result.data ?? Data())
                
                for ti in sJson["items"].map({ $0.1["snippet"]["title"]})
                {
                    log.info(ti)
                }
                
                resultObjs += sJson["items"].map({$0.1})
            }
        }
        
        self.listTable.reloadData()
    }

    
    /*
     */
    class func makeReceiveUrlToDictionary(_ url:URL)->Dictionary<String,String>
    {
        NSLog(#function)
        NSLog("makeReceiveUrlToDictionary url:" + url.description)
        let query = url.query
        var dic = Dictionary<String,String>()
        //&で区切り
        let pairs:[String] = query?.components(separatedBy: "&") ?? []//query!.components(separatedBy: "&")
        
        
        for pair in pairs
        {
            //=で左右分割
            let elements:[String] = (pair as NSString).components(separatedBy: "=")
            let key = elements[0]
            let val = elements[1]
            //辞書に要素追加
            dic[key] = val
        }
        return dic
    }
    
    override func initializeView() {

        self.navigationBarLeftArea.isHidden = true
        self.navigationBarRightArea.isHidden = true

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultObjs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SUListViewTableCell(style: .default, reuseIdentifier: "cell",titleLabelWidth : Int(tableView.frame.width))

        cell.titleLabel.text = resultObjs[indexPath.row]["snippet"]["title"].string
        cell.titleLabel.sizeToFit()
        
        cell.thumbnailView.asyncImgUrl = resultObjs[indexPath.row]["snippet"]["thumbnails"]["default"]["url"].string
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextView = SUPlayerView()
        nextView.apiReuest = viewRequest
        nextView.selectedIndex = indexPath.row
        nextView.videosIds = self.videosIds
        moveToView(nextViewController: nextView)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            
            let alert = FFAlert()
            alert.showAlert(message: "削除しますか？", type: .question, withNoButton: true)
            alert.waitForAlert()
            if alert.result ?? false
            {
                let id = self.resultObjs[indexPath.row]["id"].string ?? ""
                self.resultObjs.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                _ = SUVideosDao.sheard.delete(ID: id)
            }
            else
            {
                return
            }
            
        }
    }
    
    
    @objc func getAppendIdViewOk()
    {
        if self.subView.responseId.count > 0
        {
            _ = SUVideosDao.sheard.upsertTable(arguments: [self.subView.responseId])
            videosIds = SUVideosDao.sheard.select().map({$0["id"]!})
            getVideosList(ids: videosIds)
           
            
        }
    }
    
    @objc func showSubView()
    {
        subView.showInMainView()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


