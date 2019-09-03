//
//  AppInitial.swift
//  Tiamat
//
//  Created by yo_i on 2018/01/23.
//  Copyright © 2018年 Open Resource Corporation. All rights reserved.
//

import Foundation
import SVProgressHUD

/// 初期化設定、起動時一回のみ呼ぶ
func initApplication()
{
    FFLog.initLogObject()
    
    //プログレス設定
    SVProgressHUD.setDefaultStyle(.dark)
    SVProgressHUD.setDefaultMaskType(.black)
    SVProgressHUD.setForegroundColor(.actusBlue)
    
    //キャッシュ削除
    URLCache.shared.removeAllCachedResponses()
    

    guard let infoDic = Bundle.main.infoDictionary else {
        return
    }
    let gitHashStr = (infoDic["commitHash"] as? String ?? "")
    log.info("Ver:" + gitHashStr)
    
    _ = SUVideosDao.sheard.createTable()
    
}




