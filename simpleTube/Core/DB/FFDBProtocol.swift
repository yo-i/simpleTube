//
//  FFDataBaseProtocol.swift
//  Artemis
//
//  Created by yo_i on 2017/11/17.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
///実装必須なメッソド
protocol FFDataBaseProtocol
{
    func createTabel()->Bool                                //テーブル作成
    func dropTable()->Bool                                  //テーブルドロップ
    func updateTable(arguments:[String])->Bool                                //更新
    func deleteTable()->Bool                                //削除
    func insertTable(arguments:[String])->Bool              //インサート
    func selectAll()->Array<FFDataSetStringDictionary>      //全セレクト
}
