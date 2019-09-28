//
//  SUSearchView.swift
//  simpleTube
//
//  Created by yo_i on 2019/09/28.
//  Copyright © 2019 yang. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift
import RxCocoa

class SUSearchView: FFBaseMainViewController,UITableViewDelegate,UITableViewDataSource {
    
    private let disposeBag = DisposeBag()
    let searchInterval = 0.5    //検索間隔
    var searchTextFile:FFTextField!
    var searchResultJson = BehaviorRelay<JSON>(value: JSON())
    var searchResultTable:UITableView!
    
    // 検索ボックスの値変化を監視対象にする（テキストが空っぽの場合はデータ取得を行わない）
    private var searchBarText: Observable<String>
    {
        // MEMO: 3文字未満のキーワードの場合は受け付けない & APIリクエストの際に0.5秒のバッファを持たせる
        return searchTextFile.rx.text
            .filter { $0 != nil }
            .map { $0! }
            .filter { $0.count >= 3 }
            .debounce(searchInterval, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "動画検索"
        navigationBarHomeButton.isHidden = true
    }
    
    override func initializeView()
    {
        searchTextFile = FFTextField(frame: CGRect(x: 0
            , y: 5
            , width: self.contentView.frame.width
            , height:  40))
        self.contentView.addSubview(searchTextFile)
        searchTextFile.placeholder = "検索キーワード"
        
        searchResultTable = UITableView(frame: CGRect(x: 0
            , y: 45
            , width: self.contentView.frame.width
            , height: self.contentView.frame.height - 45 ))
        searchResultTable.dataSource = self
        searchResultTable.delegate = self
        self.contentView.addSubview(searchResultTable)
    }
    
    override func initViewStatus()
    {
        //検索結果を更新
        searchBarText.subscribe(onNext: { (str) in
            let result =  SUSearchView.searchForKeyword(str: str)
            guard let res = result else { return }
            log.info("onNext")
            self.searchResultJson.accept(res)
        }).disposed(by: disposeBag)
        
        //検索結果更新されたらテーブルをリロードするドライバー
        searchResultJson.asDriver().drive(onNext: { (date) in
            log.info("drive on next")
            self.searchResultTable.reloadData()
        }).disposed(by: disposeBag)
    }
    
    static func searchForKeyword(str:String)->JSON?
    {
        //リクエスト
        let req = YTVideosRequest()
        req.apiType = .search
        req.maxResults = 50.toString()
        req.type = "video"
        req.q = str.replace(of: "　", with: " ")
            .split(separator: " ")
            .map({ String($0)})
            .map({ $0.percentEncoding()})
        
        let apiUrl = req.getFullUrl()
        log.info(apiUrl)
        let webCore = FFWebCore()
        //結果をGET
        let result = webCore.getSync(urlStr: apiUrl)
        if result.success
        {
            let sJson = try! JSON(data:result.data ?? Data())
            return sJson
        }
        else
        {
            return nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = FFAlert()
        alert.showAlert( message: "この動画を再生しますか？", type: .question, withNoButton: true,yesButtonTitle:"はい",noButtonTitle: "いいえ")
        alert.waitForAlert()
        
        let id = searchResultJson.value["items"][indexPath.row]["id"]["videoId"].string!
        if alert.result!
        {
            //プレイページに遷移
            let nextView = SUPlayerView()
            nextView.selectedIndex = 0
            nextView.videosIds = [id]
            moveToView(nextViewController: nextView)
        }
        else
        {
            let alert2 = FFAlert()
            alert2.showAlert( message: "この動画をリストに追加しますか？", type: .question, withNoButton: true,yesButtonTitle:"はい",noButtonTitle: "いいえ")
            alert2.waitForAlert()
            if alert2.result!
            {
                //idを追加してリストページに戻る
                _ = SUVideosDao.sheard.upsertTable(arguments: [id])
                self.navigationController?.popViewController(animated: true)
            }
            
        }

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultJson.value["items"].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SUListViewTableCell(style: .default, reuseIdentifier: "searchCell",titleLabelWidth : Int(tableView.frame.width))
        
        //ラベル自動改行
        cell.titleLabel.text = searchResultJson.value["items"][indexPath.row]["snippet"]["title"].string
        cell.titleLabel.sizeToFit()
        
        //画像の非同期読み込み
        cell.thumbnailView.asyncImgUrl = searchResultJson.value["items"][indexPath.row]["snippet"]["thumbnails"]["default"]["url"].string
        
        return cell
    }
}
