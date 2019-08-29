import Foundation

///タイムアウト既定値
let WEB_TIME_OUT:Int = 60
enum FFWebCoreTimeOutLevel:Int
{
    ///WEB_TIME_OUT * 1
    case short  = 1
    ///WEB_TIME_OUT * 2
    case normal = 2
    ///WEB_TIME_OUT * 3
    case long   = 3
    ///WEB_TIME_OUT * 4
    case veryLong = 4
    
    func getSecound()->Int
    {
        return WEB_TIME_OUT * self.rawValue
    }
}
/// web通信のコア
/// 同期通信や非同期通信のインターフェイスを提供する
/// アプリにおける全通信部分の元になる
class FFWebCore
{
    
    let sessionConfig = URLSessionConfiguration.default
    var session:URLSession = URLSession.shared
    init()
    {
        /// timeoutIntervalForResourceは、従来のNSURLRequestで使われていたtimeoutIntervalに近い機能を持つもので、URLで指定されたデータの取得処理が完了するまでの時間を指定するものです。これは、伝送速度が非常に遅い環境など、通信完了まで非常に長い時間を要してしまう状況を回避するために利用できます。
        session.configuration.timeoutIntervalForResource = TimeInterval(FFWebCoreTimeOutLevel.normal.getSecound())
    }
    init(timeoutLevel:FFWebCoreTimeOutLevel)
    {
        session.configuration.timeoutIntervalForResource = TimeInterval(timeoutLevel.getSecound())
    }
    
    /// get同期通信
    ///
    /// - Parameter urlStr: 対象URL
    /// - Returns: success通信成功かどうか、data通信成功時取得したいデータ
    func getSync(urlStr:String)->(success:Bool,data:Data?)
    {
        log.verbose("getSync urlStr" + urlStr)
        session = URLSession(configuration: sessionConfig)
        /// 開始時間
        let startTime = Date()
        /// URLから作られたリクエスト
        let req = URLRequest(url: URL(string: urlStr)!)
        //レスポンス用宣言
        var resData:Data? = nil
        /// 同期制御用セマフォ
        let semaphore = DispatchSemaphore(value: 0)
        
        var resumeError:Error? = nil
        
        var statusCode = 418 //I'm a teapot
        ///セッション通信開始
        session.dataTask(with: req, completionHandler: {
            (data,res,err) in
            
            //エラーではない場合
            if err == nil
            {
                resData = data
                statusCode = (res as? HTTPURLResponse)?.statusCode ?? 418
            }
            else
            {
                log.error(err)
                resumeError = err
            }
            //セマフォ終了信号を立つ
            semaphore.signal()
            //セッションメモリ解放
            self.session.finishTasksAndInvalidate()
        }).resume()
        
        //sessionでタイムアウトの設定を行う、セマフォのタイムアウトはdistantFuture(タイムアウトしない)
        let semaphoreResult = semaphore.wait(timeout: DispatchTime.distantFuture)
        //終了時間
        let endTime = Date()
        //開始時間と終了時間の差分(通信時間)
        let diff = endTime.timeIntervalSince(startTime)
        log.info("service cost : " + diff.description + "s")
        
        //通信にエラー
        if resumeError != nil
        {
            return (false,resData)
        }
        
        //通信成功
        if semaphoreResult == .success
        {
            //クライアントエラー又はサーバーエラーの場合
            if statusCode >= 400
            {
                return (false,resData)
            }
            
            return (true,resData)
        }
        else
        {
            log.verbose("semaphore timeout")
            return (false,resData)
        }
        
    }
    
    
    /// get非同期通信
    ///
    /// - attention: 注意点 completionHandler 中に finishTasksAndInvalidate()を呼び出してメモリ解放する
    /// - Parameters:
    ///   - url: リクエストurl
    ///   - completionHandler: 完了ハンドラー
    func getAsync(url:String,completionHandler:@escaping (Data?,URLResponse?,Error?) -> Void)
    {
        log.verbose("getAsync urlStr " + url)
        session = URLSession(configuration: sessionConfig)
        let urlStr = url
        let req = URLRequest(url: URL(string: urlStr)!)
        
        session.dataTask(with: req, completionHandler: completionHandler).resume()
        
    }
    
    
    
    /// post非同期通信
    ///
    /// - attention: 注意点 completionHandler 中に finishTasksAndInvalidate()を呼び出してメモリ解放する
    /// - Parameters:
    ///   - urlStr: リクエストurl
    ///   - contentType: コンテンツタイプ
    ///   - bodyData: ボディデータ
    ///   - completionHandler: 完了ハンドラー
    func postAsync(urlStr:String,contentType:String,bodyData:Data?,completionHandler:@escaping (Data?,URLResponse?,Error?) -> Void)
    {
        log.verbose("postAsync urlStr" + urlStr)
        session = URLSession(configuration: sessionConfig)
        var req = URLRequest(url: URL(string: urlStr)!)
        
        req.httpMethod = "POST"
        req.addValue(contentType, forHTTPHeaderField: "Content-Type")
        req.httpBody = bodyData
        
        session.dataTask(with: req, completionHandler: completionHandler)
        
    }
    
    
    /// Jsonデータの同期通信Post
    /// bodyDataに対してJsonシリアライズを行い、コンテンツをJsonを指定する
    ///
    /// - Parameters:
    ///   - urlStr: リクエストurl
    ///   - bodyData: ボディデータ
    /// - Returns: 通信結果と結果データ
    func postJson(urlStr:String,bodyData:Any)->(success:Bool,data:Data?)
    {
        let jsonData = FFCore.jsonSerialization(jsonObjec: bodyData)
        
        #if DEBUG
        let postLogDir = "debugPostLog"
        FFFileManager.tryCreateDirectory(path: postLogDir)
        let jsonstr = String.init(data: FFCore.jsonSerialization(jsonObjec: bodyData) ?? Data() , encoding: .utf8) ?? ""
        FFFileManager.writeToFlie(path: postLogDir + "/" + Date().toString("HHmmss") + "Post.json", str: jsonstr)
        #endif
        return self.postSync(urlStr: urlStr, contentType: "application/json", bodyData: jsonData)
    }
    
    
    
    /// post同期通信
    ///
    /// - Parameters:
    ///   - urlStr: リクエストurl
    ///   - contentType: コンテンツタイプ
    ///   - bodyData: ボディデータ
    /// - Returns: 通信結果と結果データ
    func postSync(urlStr:String,contentType:String,bodyData:Data?)->(success:Bool,data:Data?)
    {
        log.verbose("postSync urlStr" + urlStr)
        session = URLSession(configuration: sessionConfig)
        let startTime = Date()
        var resData:Data? = nil
        
        var resumeError:Error? = nil
        
        var req = URLRequest(url: URL(string: urlStr)!)
        
        req.httpMethod = "POST"
        req.addValue(contentType, forHTTPHeaderField: "Content-Type")
        req.httpBody = bodyData
        
        
        let semaphore = DispatchSemaphore(value: 0)
        
        session.dataTask(with: req, completionHandler: {
            (data,res,err) in
            
            if err == nil
            {
                resData = data
            }
            else
            {
                log.error(err)
                resumeError = err
            }
            
            semaphore.signal()
            self.session.finishTasksAndInvalidate()
        }).resume()
        
        //sessionでタイムアウトの設定を行う、セマフォのタイムアウトはdistantFuture(タイムアウトしない)
        let semaphoreResult = semaphore.wait(timeout: DispatchTime.distantFuture)
        let endTime = Date()
        
        let diff = endTime.timeIntervalSince(startTime)
        log.info("service cost : " + diff.description + "s")
        
        
        //通信にエラー
        if resumeError != nil
        {
            log.error(resumeError)
            return (false,resData)
        }
        
        if semaphoreResult == .success
        {
            return (true,resData)
        }
        else
        {
            return (false,resData)
        }
    }
}




