//
//  FFDeviceManager.swift
//  FFFWSample
//
//  Created by yo_i on 2017/11/07.
//  Copyright © 2017年 yo_i. All rights reserved.
//

import Foundation
import UIKit


/// 端末の固有情報やアプリの情報を取得する
class FFDeviceManager
{
    static let current:UIDevice = UIDevice.current
    /// 端末固有ID
    ///
    /// - Returns: 固有ID文字列（例:E621E1F8-C36C-495A-93FC-0C247A3E6E5F）
    static func getUUid()->String
    {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    
    /// iOSバージョン
    ///
    /// - Returns: iOSバージョン文字列
    static func getOSVersion()->String
    {
        return UIDevice.current.systemVersion
    }
    
    /// アプリ名
    ///
    /// - Returns: アプリ名文字列
    static func getAppName()->String
    {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    }
    /// アプリバージョン
    ///
    /// - Returns: アプリバージョン文字列
    static func getAppVersion()->String
    {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    
    /// 端末名
    ///
    /// - Returns: 端末名（歯車の設定から設定できのやつ）
    static func getDeviceName()->String
    {
        return UIDevice.current.name
    }
    
    /// 電源状況
    ///
    /// - Returns: ケーブル指してるかどうか
    static func getBatteryState()->UIDeviceBatteryState
    {
        return UIDevice.current.batteryState
    }
    
    
    /// 電池残量(0~100)
    ///
    /// - Returns: 電池残量
    static func getBatteryLevel()->Int
    {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return Int(UIDevice.current.batteryLevel * 100)
    }
    
    
    
    /// wifi ipアドイン
    ///
    /// - Returns: ipアドイン(xxx.xxx.xxx.xxx)
    static func getWiFiAddress() -> String?
    {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
    /// ストレージ残量
    ///
    /// - Returns: XX GB
    static func getFreeStorageSize()->Double
    {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectoryPath.last!) {
            
            if let freeSize = systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber {
                // GB単位で空き容量を取得 1024ではなく1000とする方が端末の表示に近い値になる
                let storageGB = freeSize.doubleValue / Double(1000 * 1000 * 1000)
                
                // 小数点第2位以下を四捨五入
                let freeStorage =  round(storageGB * 100) / 100
                
                //0.5GB以下の場合記録として残す
                if freeStorage <= 0.5
                {
                    // systemAttributes の値を全て出力
                    for value in systemAttributes
                    {
                        log.warning(value)
                    }
                }
                return freeStorage
            }
            else
            {
                log.warning("can't get systemAttributes[FileAttributeKey.systemFreeSize]")
                return 1.0
            }
        }
        else
        {
            log.warning("can't get FileManager.default.attributesOfFileSystem(forPath: documentDirectoryPath.last!)")
            return 1.0
        }
    }

    
}
