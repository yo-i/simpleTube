//
//  FFBaseMainViewController.swift
//  Artemis
//
//  Created by yo_i on 2017/11/20.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import UIKit


/// 現在表示されているメイン画面
var currentMainView:FFBaseMainViewController? = nil

class FFBaseMainViewController :UIViewController 
{
    
    /// サブバーメニュー高さ
    static let subMenuHeight = 50
    
    var subMenuBar:UIView!                  //サブメニューバー
    var subMenuBarButtons:[FFButton] = []   //サブボタン配列

    var contentView:UIView!                 //コンテンツエリア

    //ナビゲーションカスタマイズしやすいようにUIViewに置ける
    var navigationBarLeftArea:UIView!       //ナビゲーション左エリア
    var navigationBarRightArea:UIView!      //ナビゲーション右エリア
    
    var navigationBarBackButton:UIButton!   //戻るボタン
    var navigationBarNextButton:UIButton!   //次の画面ボタン
    var navigationBarHomeButton:UIButton!   //ホームボタン
    var navigationBarInfoButton:UIButton!   //インフォボタン
    //通知センター
    var notificationCenter = NotificationCenter.default
    
    var appearFromNavigationPoped = false
    
    var viewID :String { return String(describing: type(of: self)) }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.actusBlue
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.black]
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.navigationItem.hidesBackButton = true
        
        //ベースなるViewの初期化
        createContentView()
        self.view.sendSubview(toBack: self.contentView)
        createSubMenuBar()
        createNavigationBarCustomizeArea()
        
        //ナビゲーションのパーツを初期化
        createNavigationBarBackButton()
        createNavigationBarNextButton()
        createNavigationBarHomeButton()
        createNavigationBarInfoButton()
        

        //初期化メッソド
        initializeView()

        //UI設定反映
        initViewStatus()
        //データ反映
        loadEntity()
        
        self.notificationCenter.addObserver(self, selector: #selector(self.getTimeOut), name: NSNotification.Name("app.appTimeout"), object: nil)
        
    }
    
    deinit
    {
        //デストラクタを記録、メモリリークを監視する
        //もし特定のクラス常にdeinit呼ばれていない場合は、メモリリークの対策が必要になります
        log.debug("\(self.classForCoder)")
    }
    
    /// UIViewController標準関数,VC表示する直前呼び出す
    ///
    /// - Parameter animated: アニメションオプション
    override func viewWillAppear(_ animated: Bool)
    {
        //サブメニュー
        initLayoutSubMenu()
        
        controlAuthority()
    }
    
    
    /// UIViewController標準関数,VC表示する後
    ///
    /// - Parameter animated: アニメションオプション
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        currentMainView = self
        
        //空き容量は0.5GB以下の場合、画面遷移するたびにアラートを表示
        if FFDeviceManager.getFreeStorageSize() <= 0.5
        {

        }
    }
    
    //サマリー
    func initializeView(){ }
    
    //値の反映
    func initViewStatus(){ }
    
    
    /// エンティティデータの反映
    func loadEntity(){ }
    
    //エンティティデータの保存
    func saveEntity(){ }
    
    
    /// サブメニュー初期表示
    func initLayoutSubMenu() { }
    
    
    /// 権限管理
    ///
    /// - Parameters:
    ///   - division: 区分
    ///   - level: 階級
    func controlAuthority() { }
    /// サブメニューレイアウトメソッド
    ///
    /// - Parameter branchDivision: サブメニューボタンの区分
    func layoutSubMenuButtons(branchDivision:UInt)
    {
        self.layoutSubMenuButtons(branchDivision: branchDivision, startPx: 0, showRangWidth: Int(self.navigationController?.navigationBar.frame.width ?? 0) - 24)
    }
    
    
    /// サブメニューレイアウトメソッド
    ///
    /// - Parameters:
    ///   - branchDivision: サブメニューボタンの区分
    ///   - startPx: 開始のX軸位置
    ///   - showRangWidth: トータルの幅
    func layoutSubMenuButtons(branchDivision:UInt,startPx:Int,showRangWidth:Int)
    {
        //現在表示されているサブメニューボタンを全部消し
        for subMenuButton in self.subMenuBar.subviews.filter({$0 is FFButton})
        {
            subMenuButton.removeFromSuperview()
        }
        
        let startLayoutPx = 12
        let space = 10
        let toLayoutSubMenuButtons = self.subMenuBarButtons.filter({$0.subMenuBranchDivision == branchDivision})
        
        if toLayoutSubMenuButtons.count > 0
        {
            let buttonNewWidth = (showRangWidth - ( 10 * (toLayoutSubMenuButtons.count - 1 ))) / toLayoutSubMenuButtons.count
            for (index,button) in toLayoutSubMenuButtons.enumerated()
            {
                button.frame.size = CGSize(width: buttonNewWidth, height: FFButton.defHeight)
                button.frame.origin = CGPoint(x: startLayoutPx + startPx + index * buttonNewWidth + space * index
                    , y: (FFBaseMainViewController.subMenuHeight - FFButton.defHeight) / 2)
                subMenuBar.addSubview(button)
            }
        }
    }
    
    
    /// 指定したViewに戻る
    ///
    /// - Parameter viewClass: VCクラス
    func backToView(viewClass:AnyClass)
    {
        guard let viewControlls = self.navigationController?.viewControllers else
        {
            log.warning("have no navigationController?.viewControllers")
            return
        }
        
        for viewController in viewControlls.filter({$0.isKind(of: viewClass)})
        {
            self.navigationController?.popToViewController(viewController, animated: true)
            return
        }
    }
    
    
    /// 指定したViewに進む(初期値なし)
    ///
    /// - Parameter viewClass: VCクラス
    func moveToView(viewClass:FFBaseMainViewController.Type)
    {
        let nextViewController = viewClass.init()
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    
    /// 指定したViewに進む(初期値設定可)
    ///
    /// - Parameter nextViewController: 次の画面VCのインスタンス
    func moveToView(nextViewController:FFBaseMainViewController)
    {
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    
    /// ナビゲーション戻るボタンイベント、一個前の画面に戻る
    @objc func navigationControollerPopView()
    {
        self.navigationController?.popViewController(animated: true)
        self.view.removeFFDelegates()
        self.notificationCenter.removeObserver(self)
    }
    
    /// ナビゲーション次の画面に進むボタンイベント
    @objc func navigationControollerPushNextView()
    {

    }
    
    
    ///ナビゲーションホームボタンイベント
    @objc func clickNavigationBarHomeButton()
    {
        self.view.removeFFDelegates()
        self.notificationCenter.removeObserver(self)
    }
    ///ナビゲーションインフォボタンイベント
    @objc func clickNavigationBarInfoButton()
    {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getContenViewStartY()->Int
    {
        return Int ( UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.frame.size.height)! )
    }
    @objc func getTimeOut()
    {
        guard let cmv = currentMainView else {
            return
        }
        if cmv.isEqual(self)
        {
            //TODO: タイムアウトメッセージ内容
            let alert = FFAlert()
            alert.showAlert("", message: "タイムアウトしました。もう一度ログインしてください。", type: .error, withNoButton: false, yesButtonTitle: "OK", noButtonTitle: "", action: { (_) in
                log.info("view get timeout")
                self.closeAccessViews()
                self.willBackToMenu()
                self.backToMenu()
            })
            
        }
    }
    
    /// サブ画面などを閉じる
    func closeAccessViews()
    {
        //サブ画面を閉じる
        if currentSubView != nil
        {
            //サブ画面をのポップアップを閉じる
            currentSubView!.presentedViewController?.dismiss(animated: false, completion: nil)
            currentSubView!.closeFromMainView()
        }
        
        //ポップアップを閉じる
        self.presentedViewController?.dismiss(animated: false, completion: nil)
    }
    
    /// ログイン画面戻る前
    func willBackToMenu()
    {
        //NOP
    }
    
    
    /// ログイン画面戻る
    func backToMenu()
    {

    }
    
}

extension UIView
{
    func removeFFDelegates()
    {
        for v in self.subviews
        {
            if v.subviews.count > 0
            {
                v.removeFFDelegates()
            }
            
            if v is UITableView
            {
                (v as! UITableView).delegate = nil
                (v as! UITableView).dataSource = nil
            }
            
            if v is FFNumPadTextField
            {
                (v as! FFNumPadTextField).padDelegate = nil
            }
            
            if v is FFPadPullDownTextField
            {
                (v as! FFPadPullDownTextField).popDelegate = nil
            }
            
            if v is FFDraggableView
            {
                (v as! FFDraggableView).delegate = nil
            }
            
            if v is FFPopCalendar
            {
                (v as! FFPopCalendar).popDelegate = nil
            }
            
            if v is FFPopNumPadTextField
            {
                (v as! FFPopNumPadTextField).popDelegate = nil
            }
        }
    }
}

