//
//  SUVideosDao.swift
//  simpleTube
//
//  Created by yo_i on 2019/08/30.
//  Copyright © 2019年 yang. All rights reserved.
//

import Foundation
class SUVideosDao:FFDataBaseManagerBase
{
    let SELECT_MESSAGE = "SELECT * FROM videos;"
    let UPSERT_TABLE = "INSERT OR REPLACE INTO videos " + " (ID) " + " VALUES(?) "
    let CREATE_TABLE = "CREATE TABLE IF NOT EXISTS videos ('ID' TEXT ,PRIMARY KEY('ID') )"
    let DELETE_TABLE = "DELETE FROM videos WHERE ID = ?"
    let DELETE_ALL = "DELETE FROM videos"
    static var sheard = SUVideosDao()
    
    init()
    {
        super.init(db: .local)
    }
    
    func createTable()->Bool
    {
        return executeUpdate(sqlString: CREATE_TABLE, arguments: [])
    }
    
    func upsertTable(arguments: [String]) -> Bool
    {
        return executeUpdate(sqlString: UPSERT_TABLE, arguments: arguments)
    }
    
    func select()->Array<FFDataSetStringDictionary>
    {
        return executeQuery(sqlString: SELECT_MESSAGE, arguments: [])
    }
    
    func delete(ID:String = "")->Bool
    {
        if ID == ""
        {
            return executeUpdate(sqlString: DELETE_ALL, arguments: [])
        }
        return executeUpdate(sqlString: DELETE_TABLE, arguments: [ID])
    }
}
