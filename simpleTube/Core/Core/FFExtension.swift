//
//  EXAppleLibrarys.swift
//  Atropos
//
//  Created by yo_i on 2017/10/13.
//  Copyright (c) 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit
import Darwin
import Photos
import CoreImage
extension UIColor
{
    
    /// init with rgba in Int
    ///
    /// - Parameters:
    convenience init(red:Int,green:Int,blue:Int,alpha:Int)
    {
        self.init(red: CGFloat(red) / 255.0
            , green: CGFloat(green) / 255.0
            , blue:  CGFloat(blue) / 255.0
            , alpha: CGFloat(alpha) / 255.0)
    }
    
    /// init with rgba in Int
    ///
    /// - Parameters:
    convenience init(red:Int,green:Int,blue:Int)
    {
        self.init(red: CGFloat(red) / 255.0
            , green: CGFloat(green) / 255.0
            , blue:  CGFloat(blue) / 255.0
            , alpha: 1)
    }
    
    func withAlphaComponent(_ alpha: Int) -> UIColor
    {
        return self.withAlphaComponent(CGFloat(alpha) / 255.0)
    }
    /// アクタステーマ色
    //{ return UIColor(red: Int(arc4random() % 200), green: Int(arc4random() % 200), blue: Int(arc4random() % 200), alpha: 255) }
    //{ return UIColor(red: 14, green: 160, blue: 173, alpha: 255) }
    static var actusBlue:UIColor {  return UIColor(red: 14, green: 160, blue: 173, alpha: 255) }
    static var actusBlueHighlight:UIColor { return self.actusBlue.withAlphaComponent(100) }
    /// muji良品テーマ色
    static var mujiRed:UIColor{ return  UIColor(red: 126, green: 3, blue: 28, alpha: 255)}
    ///ボタンなど使用不可色
    static var disabledGrey:UIColor { return UIColor(red: 215, green: 215, blue: 215, alpha: 255) }
    ///セル選択色な
    static var cellSelected:UIColor{ return self.actusBlue.withAlphaComponent(100)}
    
    static var holidayRed:UIColor{ return UIColor(red: 200, green: 0, blue: 0, alpha: 255) }
    
    static var holidayBlue:UIColor{ return UIColor(red: 25, green: 181, blue: 252, alpha: 255) }
    
    static var fontBlack:UIColor{ return UIColor(red: 60, green: 60, blue: 60, alpha: 255) }
    ///背景に使うグレイカラー
    static var backgroundGray : UIColor { return UIColor(red: 0, green: 0, blue: 0, alpha: 25)}
    //UIの枠の色
    static var borderColor : UIColor { return UIColor(red: 208, green: 208, blue: 208, alpha: 255)}
    //バッジの背景色
    static var badgeColor : UIColor { return UIColor(red: 255, green: 38, blue: 0, alpha: 255)}
    ///ピッカーテキストフィールドの背景色
    static var pickerTextFieldColor : UIColor { return UIColor(red: 94, green: 94, blue: 94, alpha: 255)}
    
    static var liteGrey : UIColor { return UIColor(red: 215, green: 215, blue: 215, alpha: 215)}
    
    static var alertInfo : UIColor { return UIColor(red: 208, green: 231, blue: 247, alpha: 150)}
    static var alertError : UIColor { return UIColor(red: 250, green: 214, blue: 210, alpha: 150)}
    static var alertWarning : UIColor { return UIColor(red: 250, green: 238, blue: 210, alpha: 150)}
    static var alertQuestion : UIColor { return UIColor(red: 202, green: 237, blue: 202, alpha: 150)}
    
}

// MARK: - UIImage
extension UIImage
{
    enum FFImageType
    {
        case png
        case jpg
    }

    /// UIImagePNGRepresentation,UIImageJPEGRepresentationでdataへ変換
    ///
    /// - Parameters:
    ///   - type: pngがjpgが
    ///   - compressionQuality: jpgの場合、圧縮率デフォルト:1(圧縮しない) 0~1範囲
    /// - Returns: バイナリーデータ
    func data(type:FFImageType = .png,compressionQuality:CGFloat = 1)->Data?
    {
        switch type
        {
            case .png:
            return UIImagePNGRepresentation(self)
            case .jpg:
            return UIImageJPEGRepresentation(self, compressionQuality)
        }
        
    }
    
    /// カラーイメージ取得
    ///
    /// - Parameters:
    ///   - color: 色指定
    ///   - size: サイズ指定
    /// - Returns: カラーイメージ
    class func getColorImage(color:UIColor,size:CGSize) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
        
    }
    
    ///カメラロールからUUID指定、同期取得
    class func getImageFromLocalwithUUID(UUID:String)->UIImage?
    {
        let fetchR = PHAsset.fetchAssets(withLocalIdentifiers: [UUID], options: nil)
        if fetchR.count == 0 { return nil }     //fetchデータなっかたらnilで返却
        var resultImage:UIImage? = nil
        let requestOP = PHImageRequestOptions()
        requestOP.isSynchronous = true          //同期取得
        let manager: PHImageManager = PHImageManager()  //phimageManager経由で画像を取得
        manager.requestImage(for: fetchR.firstObject!
            , targetSize: PHImageManagerMaximumSize
            , contentMode: .aspectFit
            , options: requestOP
            , resultHandler: {  (image, info) in
                resultImage = image
        })
        return resultImage
    }
    
    ///カメラロールからUUID指定、同期取得
    class func getImageFromLocalwithUUID(UUIDs:[String])->[UIImage]
    {
        let fetchR = PHAsset.fetchAssets(withLocalIdentifiers: UUIDs, options: nil)
        if fetchR.count == 0 { return [] }     //fetchデータなっかたらnilで返却
        
        let requestOP = PHImageRequestOptions()
        requestOP.isSynchronous = true          //同期取得
        
        var imageArray:[UIImage] = []
        let manager: PHImageManager = PHImageManager()  //phimageManager経由で画像を取得
        
        fetchR.enumerateObjects({ (asset, index, stop) in
            manager.requestImage(for: asset
                , targetSize: PHImageManagerMaximumSize
                , contentMode: .aspectFit
                , options: requestOP
                , resultHandler: { (image, info) in
                    if image != nil
                    {
                        imageArray.append(image!)
                    }
            })
        })
        
        return imageArray
    }
    
    class func placeholdImageUrl(str:String = "")->String
    {
        let ffffff:UInt32 = 0xffffff
        let ran = arc4random() % ffffff
        
        return "https://placehold.jp/" + String.init(format: "%06x", ran) + "/ffffff/200x150.png"
        + (str.count > 0 ? "?text=\(str)" : "")
    }
    
}
// MARK: - Dictionary
extension Dictionary
{
    ///辞書形をurl用パラメータに変換
    ///
    /// - Returns: URL用パラメータ文字列
    func toUrlParam()->String
    {
        //<string,string>の場合のみ、実行
        if self is Dictionary<String,String>
        {
            var resultString:[String] = []
            for e in self.keys.enumerated()
            {
                let oneParam = String(describing: e.element) + "=" + String(describing: self[e.element]!)
                resultString.append(oneParam)
            }
            //&マークでjoin
            return resultString.joined(separator: "&")
        }
        else    //それ以外のDictionaryの場合の
        {
            return ""
        }
    }
}

// MARK: - URL
extension URL
{
    ///URLパラメータを辞書に変換
    func toDictionary()->Dictionary<String,String>
    {
        let query = self.query ?? ""
        var dic = Dictionary<String,String>()
        //&で区切り
        let pairs:[String] = query.components(separatedBy: "&")
        
        for pair in pairs
        {
            let elements:[String] = (pair).components(separatedBy: "=")
            let key = elements[0]
            let val = elements[1]
            
            dic[key] = val
        }
        return dic
        
    }
    
}

// MARK: - Int
extension Int
{
    /// 文字列に変換
    ///
    /// - Returns: 文字列
    func toString()->String
    {
        return String(self)
    }
    
    /// カンマ区切
    ///
    /// - Returns: 3桁カンマ区切文字列
    func toFormatString()->String
    {
        let num = NSNumber(integerLiteral: self)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.string(from: num)!
    }
    
    /// ¥マーク付き、3桁カンマ区切り
    ///
    /// - Returns: マイナス記号前置
    func toFormatStringWithEnmark()->String
    {
        return self < 0 ? "-¥" + abs(self).toFormatString() : "¥" + self.toFormatString()
    }
    
    /// decimalにキャスト
    var decimal:Decimal{
        get{
            return Decimal(self)
        }
    }
    
    /// boolにキャスト,0の場合false、以外true
    var bool:Bool
    {
        get
        {
            return self == 0 ? false : true
        }
    }
    
}

// MARK: - Double
extension Double
{
    /// decimalにキャスト
    var decimal:Decimal{
        get{
            return Decimal(self)
        }
    }
    
    
}

// MARK: - Decimal
extension Decimal
{
    ///
    /// Intにキャスト
    var intValue:Int{
        get{
            return (self as NSDecimalNumber).intValue
        }
    }
    
    ///
    /// Doubleにキャスト
    var doubleValue:Double
    {
        get{
            return (self as NSDecimalNumber).doubleValue
        }
    }
    
    
    /// カンマ区切
    ///
    /// - Returns: 3桁カンマ区切文字列
    func toFormatString()->String
    {
        let num = NSDecimalNumber(decimal: self)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        return formatter.string(from: num) ?? ""
    }
    ///四捨五入
    ///
    /// - Parameters:
    ///   - roundingMode: 四捨五入モード デフォルト四捨五入
    ///   - scale: 小数点以下桁数  デフォルト0
    /// - Returns: 四捨五入後の値
    func round(roundingMode:NSDecimalNumber.RoundingMode = .plain,scale:Int16 = 0)->Decimal
    {
        let handel = NSDecimalNumberHandler(roundingMode: roundingMode
            , scale: scale
            , raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        
        return NSDecimalNumber(decimal: self).rounding(accordingToBehavior: handel).decimalValue
    }
    
    func toString()->String
    {
        return self.description
    }
}

// MARK: - UIView
extension UIView
{
    /// UIViewからUIImageに変換
    ///
    /// - Returns: UIViewの画像
    func toImage()->UIImage
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0.0, y: 0.0)
        self.layer.render(in: context!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    
    
    /// 枠線をセットする
    ///
    /// - Parameters:
    ///   - borderWidth: 枠線太さ
    ///   - borderColor: 枠線色
    func setBorder(borderWidth:Int,borderColor:UIColor)
    {
        self.layer.borderWidth = CGFloat(borderWidth)
        self.layer.borderColor = borderColor.cgColor
    }
    
    /// 枠線をセットする
    ///
    /// - Parameters:
    ///   - borderWidth: 枠線太さ
    ///   - borderColor: 枠線色
    func setBorder(borderWidth:Double,borderColor:UIColor)
    {
        self.layer.borderWidth = CGFloat(borderWidth)
        self.layer.borderColor = borderColor.cgColor
    }
    
    
    /// 自分のsubviewを消す
    func removeSubViews()
    {
        for subView in self.subviews
        {
            subView.removeFromSuperview()
        }
    }
}

// MARK: - String
extension String
{
    
    /// 文字列長(Swift4.0からcountが追加されている,名前互換だけとして残す)
    ///
    /// - Returns: 文字列長
    @available(*, deprecated: 1.0, message: "Use self.count.")
    func length() -> Int
    {
        return self.count//self.characters.count
    }
    
    
    /// トリミング
    ///
    /// - Returns: 前後空白を抜いた文字列
    func trim() -> String
    {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// サブストリング
    ///
    /// - Parameters:
    ///   - location: 開始文字
    ///   - length: 長さ
    /// - Returns: サブストリング
    func substring(_ location:Int, length:Int) -> String
    {
        return (self as NSString).substring(with: NSMakeRange(location, length))
    }
    
    /// StringをNSStringにキャスト
    ///
    /// - Returns: NSString文字列
    func toNSString()->NSString
    {
        return NSString(string: self)
    }
    
    
    ///文字列をDate形にキャスト
    /// - parameter dateFormart: 日付フォマット 例:yyyy/MM/dd
    /// - return 文字列から変換した日付
    func parseStringToDate(_ dateFormart:String)->Date?
    {
        if self.count == 0 { return nil}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormart
        return dateFormatter.date(from: self)
    }
    
    /// 文字列からスラッシュを削除
    ///
    /// - Returns: スラッシュが削除された文字列
    func deleteSlash() -> String
    {
        return self.replacingOccurrences(of: "/", with: "")
    }
    
    
    /// URL用エンコード
    ///
    /// - Returns: URL用文字列を返却
    func percentEncoding()->String
    {
        return self.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    }
    
    func percentDecoding()->String
    {
        return self.removingPercentEncoding ?? ""
    }
    
    /// 半角カタカナのみ全角に変換
    ///
    /// - Returns: 半角カタカナを全角に変換後の文字列
    func parseKatakanaHalfToWidth()->String
    {
        var resultString = ""
        for c in self.characters
        {
            if c < "ｧ" || c > "ﾝ"
            {
                resultString += String(c)
            }
            else
            {
                resultString += String(c).parseHalfToWidth()
            }
            
        }
        return resultString
    }
    
    
    /// 全角に変換
    ///
    /// - Returns: 全角に変換後の文字列
    func parseHalfToWidth()->String
    {
        let workstr = NSMutableString(string: self) as CFMutableString
        CFStringTransform(workstr, nil, kCFStringTransformFullwidthHalfwidth, true)
        return workstr as String
    }
    
    
    /// 半角に変換
    ///
    /// - Returns: 半角に変換後の文字列
    func parseWidthToHalf()->String
    {
        let workstr = NSMutableString(string: self) as CFMutableString
        CFStringTransform(workstr, nil, kCFStringTransformFullwidthHalfwidth, false)
        return workstr as String
    }
    
    
    /// 正規表現（マッチ）
    /// [正規表現参考](https://qiita.com/fubarworld2/items/9da655df4d6d69750c06)
    ///
    /// - Parameter regex: 正規表現表示文字
    /// - Returns: 正規表現にマッチした文字列の場合true,以外false
    func isPredicateEvaluate(regex:String)->Bool
    {
        let predicate = NSPredicate(format:"SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    /// ひらかな判定
    ///
    /// - Returns: 全部ひらかなの場合true,以外false
    func isHirakana()->Bool
    {
        let regex = "^[ぁ-ゞ]+$"
        return self.isPredicateEvaluate(regex: regex)
    }
    
    
    /// カタカナ判定
    ///
    /// - Returns: 全部カタカナの場合true,以外false
    func isKatakana()->Bool
    {
        let regex = "^[ァ-ヾ]+$"
        return self.isPredicateEvaluate(regex: regex)
    }
    
    
    /// 数字判定
    ///
    /// - Returns: 全部数字の場合true,以外false
    func isNumber()->Bool
    {
        let regex = "^[-]?[0-9]+(.[0-9]+)?$"
        return self.isPredicateEvaluate(regex: regex)
    }
    
    func isNumberOrAlphabet()->Bool
    {
        let regex = "^[a-zA-Z0-9]+$"
        return self.isPredicateEvaluate(regex: regex)
    }
    
    /// 半角判定
    ///
    /// - Returns: 全部数字の場合true,以外false
    func isAllHalfChara()->Bool
    {
        return self.canBeConverted(to: .ascii)
    }
    
    /// decimalにキャスト
    var decimal:Decimal{
        get{
            return Decimal(string: self) ?? 0
        }
    }
    
    /// Intにキャスト
    var intValue:Int{
        get{
            return self.decimal.intValue
        }
    }
    
    /// 文字列の復号化
    ///
    /// - Returns: 復号化した文字列
    func decrypt()->String
    {
        return FFAesEncrypt.decryptString(self)
    }
    
    /// 文字列の暗号化
    ///
    /// - Returns: 暗号化した文字列
    func encrypt()->String
    {
        return FFAesEncrypt.encryptString(self)
    }
    
    /// リプレース
    ///
    /// - Returns: リプレースした文字
    func replace(of:String,with:String)->String
    {
        return self.toNSString().replacingOccurrences(of: of, with: with)
    }
    
    /// カンマ区切
    ///
    /// - Returns: 3桁カンマ区切文字列
    func toFormatString()->String
    {
        return self.decimal.toFormatString()
    }
    
    /// ¥ + カンマ区切
    ///
    /// - Returns: 3桁カンマ区切文字列
    func toFormatStringWithYen()->String
    {
        return "¥" + self.decimal.toFormatString()
    }
    
    /// 漢字第二水準
    ///  参考URL　http://www.eonet.ne.jp/~kotobukispace/ddt/jisx0213/sjis8xxx.html
    ///  参考URL　https://www.kishugiken.co.jp/cn/code04c.html
    ///
    /// - Returns: 全部漢字第二水準の場合true,以外false
    func isJISLevel2Kanji()->Bool
    {
        for (_,s) in self.enumerated()
        {
            //全角変換可能性な文字は全角として判定
            let toComperChar = String(s).parseHalfToWidth()
            
            if let strByte = toComperChar.data(using: String.Encoding.shiftJIS)
            {
                //シフトJIS文字の場合、文字コードまで落とします
                let strByteToJISStr = String(format: "%@", strByte as CVarArg)
                    .replace(of: "<", with: "")
                    .replace(of: ">", with: "")
                    .replace(of: " ", with: "")
                
                let scanner = Scanner(string: strByteToJISStr)
                var result:UInt32 = 0
                scanner.scanHexInt32(&result)
                
                switch result
                {
                //許可領域
                case 0x8140...0x81AC:
                    continue
                    
                case 0x81B8...0x81BF:
                    continue
                    
                case 0x81C8...0x81CE:
                    continue
                    
                case 0x81DA...0x81E8:
                    continue
                    
                case 0x81F0...0x81FF:
                    continue
                    
                case 0x824F...0x8258:
                    continue
                    
                case 0x8260...0x8279:
                    continue
                    
                case 0x8281...0x829A:
                    continue
                    
                case 0x829F...0x82F1:
                    continue
                    
                case 0x8340...0x8396:
                    continue
                    
                case 0x839F...0x83B6:
                    continue
                    
                case 0x83BF...0x83D6:
                    continue
                    
                case 0x8440...0x8460:
                    continue
                    
                case 0x8470...0x8491:
                    continue
                    
                case 0x849F...0x84BE:
                    continue
                    
                    /* 第一水準ですが、使用不可
                     ① ② ③ ④ ⑤ ⑥ ⑦ ⑧ ⑨ ⑩ ⑪ ⑫ ⑬ ⑭ ⑮
                     ⑯ ⑰ ⑱ ⑲ ⑳ Ⅰ Ⅱ Ⅲ Ⅳ Ⅴ Ⅵ Ⅶ Ⅷ Ⅸ Ⅹ
                     ㍉ ㌔ ㌢ ㍍ ㌘ ㌧ ㌃ ㌶ ㍑ ㍗ ㌍ ㌦ ㌣ ㌫ ㍊ ㌻
                     ㎜ ㎝ ㎞ ㎎ ㎏ ㏄ ㎡
                     case 0x8740...0x8775:
                     return true
                     */
                //第一水準漢字
                case 0x889F...0x9872:
                    continue
                    
                //第二水準漢字
                case 0x989F...0xEAA4:
                    continue
                    
                default:
                    log.debug(toComperChar)
                    return false
                    
                }
                
            }
            else
            {
                log.debug(toComperChar)
                //SHIFTJIS文字コードではない
                return false
            }
        }
        return true
    }
    
    func encodeNewLineChar()->String
    {
        return self.replace(of: "\n", with: ";")
    }
    
    func decodeNewLineChar()->String
    {
        return self.replace(of: ";", with: "\n")
    }
    
    func QRCodeImage()->UIImage?
    {
        guard let ciFilter = CIFilter(name: "CIQRCodeGenerator") else
        {
            return nil
        }
        ciFilter.setDefaults()
        
        //QRコード設定
        ciFilter.setValue(self.data(using: .utf8), forKey: "inputMessage")
        //誤り訂正レベル
        ciFilter.setValue("M", forKey: "inputCorrectionLevel")
        
        if let outputImage = ciFilter.outputImage {
            // 作成されたQRコードのイメージが小さいので拡大する
            let sizeTransform = CGAffineTransform(scaleX: 10, y: 10)
            let zoomedCiImage = outputImage.transformed(by: sizeTransform)
            return UIImage(ciImage: zoomedCiImage, scale: 1.0, orientation: .up)
        }
        
        return nil
    }
    
    func tryGetFormatedIntString()->String
    {
        return Int(self) == nil ? self : Int(self)?.toFormatString() ?? ""
    }
    
}

// MARK: - NSDictionary
extension NSDictionary
{
    /// 指定keyから文字列を取り出す
    ///
    /// - Parameter key: 対象key
    /// - Returns: 成功する場合文字列を返却、存在しない又は文字列にキャストできない場合ブランクを返却
    func tryToString(_ key:String) -> String
    {
        return (self.object(forKey: key) as? String) ?? ""
    }
    
}


// MARK: - UITableView
extension UITableView
{
    open override func didMoveToSuperview() {
        if #available(iOS 9.0, *) {
            self.cellLayoutMarginsFollowReadableWidth = false
        } else {
            // Fallback on earlier versions
        }
    }
}

fileprivate var gHoildays:[String] = []
// MARK: - 日付
extension Date
{
    static var tryGetHolidayMasterFlag = false
    static var weekDayString:[String] { return ["日","月","火","水","木","金","土"]}
    static var jpWeekDayString:[String] {return ["大安","赤口","先勝","友引","先負","仏滅"]}
    /// 日付の文字列変換
    ///
    /// - Returns: yyyyMMddHHmmss形式の文字列
    func toString()->String
    {
        return self.toString("yyyyMMddHHmmss")
    }
    
    /// 日付の文字列変換
    ///
    /// - Parameter format: 文字列フォマット(eg: yyyyMMdd)
    /// - Returns: formatに従う日付文字列
    func toString(_ format:String)->String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    
    /// 曜日色付け、文字列変更
    ///
    /// - Parameter format: 文字列フォマット(eg: yyyyMMdd)
    /// - Returns: formatに従う日付文字列
    func toAttributedWeekDayString(_ format:String)->NSAttributedString
    {
        let str = self.toString(format)
        //曜日のEを検索
        let indexOfWeekDay = format.index(of: "E")
        //見つからない場合、
        if indexOfWeekDay != nil
        {
            let index = format.distance(from: format.startIndex, to: indexOfWeekDay!)
            
            let attributedText = NSMutableAttributedString(string: str)
            var color = UIColor.black
            let weekDay = self.weekday()
            if self.isHoliday() || weekDay == 1
            {
                color = UIColor.holidayRed
            }
            else if weekDay == 7
            {
                color = UIColor.holidayBlue
            }
            attributedText.addAttribute(NSAttributedStringKey.foregroundColor
                , value: color
                , range: NSMakeRange(index, 1))
            return attributedText
        }
        else
        {
            return NSAttributedString(string: str)
        }
    }
    
    /// 曜日
    ///
    /// - Returns: 1-日 2-月
    func weekday()->Int
    {
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let components = (cal as NSCalendar).components(.weekday, from: self)
        return components.weekday!
    }
    
    /// 曜日の漢字
    ///
    /// - Returns: "日","月","火","水","木","金","土"からいずれ
    func weekdayString()->String
    {
        return self.toString("E")
    }
    
    /// 日付計算
    ///
    /// - Parameter daysInterval: 日数
    /// - Returns: 日数から計算した日付
    func dateInterval(daysInterval:Int)->Date
    {
        let dateComponents = NSDateComponents()
        dateComponents.day = daysInterval
        let calendar:NSCalendar = NSCalendar.current as NSCalendar
        let nowDateAddComponents = calendar.date(byAdding: dateComponents as DateComponents, to: self, options: NSCalendar.Options())!
        return nowDateAddComponents
    }
    
    
    func dateInterval(monthsInterval:Int)->Date
    {
        let dateComponents = NSDateComponents()
        dateComponents.month = monthsInterval
        let calendar:NSCalendar = NSCalendar.current as NSCalendar
        let nowDateAddComponents = calendar.date(byAdding: dateComponents as DateComponents, to: self, options: NSCalendar.Options())!
        return nowDateAddComponents
    }
    
    func dateInterval(yearsInterval:Int)->Date
    {
        let dateComponents = NSDateComponents()
        dateComponents.year = yearsInterval
        let calendar:NSCalendar = NSCalendar.current as NSCalendar
        let nowDateAddComponents = calendar.date(byAdding: dateComponents as DateComponents, to: self, options: NSCalendar.Options())!
        return nowDateAddComponents
    }
    
    
    func intervalDays(date:Date)->Int
    {
        return (self.timeIntervalSince(date) / (60.0 * 60.0 * 24.0)).decimal.round(roundingMode: .up, scale: 0).intValue
    }
    
    func isHoliday()->Bool
    {
        if gHoildays.count == 0
        {
            Date.getHolidayMaster()
        }
        //要素探す
        if gHoildays.index(of: self.toString("yyyyMMdd")) != nil
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    static func getHolidayMaster()
    {
//                //外部サービス頼り
//                let wc = FFWebCore()
//                let url = "https://holidays-jp.github.io/api/v1/date.json"
//                wc.getAsync(url: url) { (data, res, err) in
//                    if err == nil
//                    {
//                        let jasonData = FFCore.jsonSerialization(jsonObjec: data ?? Data())
//                        let dic = jasonData as! Dictionary<String,String>
//                        gHoildays = dic.keys.map({$0.replacingOccurrences(of: "-", with: "")})
//                    }
//                    wc.session.finishTasksAndInvalidate()
//                }
//        autoreleasepool(invoking: {
//
//            if tryGetHolidayMasterFlag
//            {
//                return                      //祝日取得できませんのため、何もしないで終了
//            }
//            else
//            {
//                let masterDao = FFCodeMasterDAO()
//                let hoildays = masterDao.selectTable(masterCategorise: .holidays)
//                    .filter({$0["mainkey"] != nil})
//                    .map({$0["mainkey"]!})
//                gHoildays = hoildays
//                tryGetHolidayMasterFlag = true  //祝日マスター取得を試しました
//            }
//
//
//        })
    }
    
    func minutesFrom() -> Int
    {
        return Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
    }
    
}

extension UIApplication
{
    
    /// 最前面のVC取得
    ///
    /// - Parameter controller: 現在のルートビューコントローラー
    /// - Returns: 最前面のVC
    class func topViewController(controller : UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?
    {
        if let navigationController = controller as? UINavigationController
        {
            return topViewController(controller:navigationController.visibleViewController)
        }
        else
        {
            return controller
        }
    }
}
