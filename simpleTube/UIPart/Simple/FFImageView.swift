//
//  FFImageView.swift
//  Artemis
//
//  Created by yo_i on 2017/11/22.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import Foundation
import UIKit
import Photos
class FFImageView:UIImageView
{
    var allowNoImage = false
    /// 非同期画像読み込み
    public var asyncImgUrl:String?
    {
        didSet
        {
            loadImageAync()
        }
    }
    /// カメラロール非同期画像読み込み
    public var asyncLocalImgUUID:String?
    {
        didSet
        {
            loadLocalImageAync()
        }
    }
    
    //プレビュー可能パラメター
    //現在指２のタップで表示
    //isUserInteractionEnabledをtrueに必要があります
    public var isPreviewEnable:Bool = false
    {
        didSet
        {
            appendPreviewGesture()
        }
    }
    
    private var _window:UIWindow!
    private var _maskView:UIView!
    private var _imageView:UIImageView!
    private var _tapGesture:UITapGestureRecognizer!
    
    
    var accessoryButton:FFButton?
    /// 通信して読み込み
    private func loadImageAync()
    {
        guard let imgUrl = asyncImgUrl else
        {
            self.image = nil
            self.setNeedsLayout()
            return
        }
        
        let service = FFWebCore()
        
        service.getAsync(url: imgUrl, completionHandler: {
            
            (data,res,err) in
            
            if err == nil
            {
                //リソースが200(成功)以外
                if (res as? HTTPURLResponse)?.statusCode != 200
                {
                    DispatchQueue.main.async {

                        if self.allowNoImage
                        {
                            let image = UIImage(named: "NoImage.png")
                            self.image = image
                            self.setNeedsLayout()
                        }
                        else
                        {
                            self.image = nil
                        }
                        
                    }
                }
                else
                {
                    let image = UIImage(data: data!)
                    DispatchQueue.main.async {
                        self.image = image
                        self.setNeedsLayout()
                    }
                }

            }
            
            service.session.finishTasksAndInvalidate()

        })
        
    }
    
    func loadLocalImageAync()
    {
        guard let uuid = self.asyncLocalImgUUID else
        {
            self.image = nil
            return
        }
        let fetchR = PHAsset.fetchAssets(withLocalIdentifiers: [uuid], options: nil)
        if fetchR.count == 0
        {
            self.image = UIImage(named: "NoImage.png")
            return
        }
        
        let manager: PHImageManager = PHImageManager()
        manager.requestImage(for: fetchR.firstObject!
            , targetSize: self.frame.size
            , contentMode: .default
            , options: nil
            , resultHandler: { (image, info) in
                DispatchQueue.main.async {
                    self.image = image
                    self.setNeedsLayout()
                }
        })
    }
    
    
    /// タップイベントを追加
    private func appendPreviewGesture()
    {
        if isPreviewEnable
        {
            // 長押しを認識
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.showPreview(sender:)))
            // 長押し-最低1秒間は長押しする
            longPressGesture.minimumPressDuration = 1.0
            // 長押し-指のズレは15pxまで
            longPressGesture.allowableMovement = 150
            
            self.addGestureRecognizer(longPressGesture)
        }
    }
    
    
    /// プレビューウインドウ表示
    ///
    /// - Parameter sender: ジャスチャー
    @objc private func showPreview(sender:UITapGestureRecognizer)
    {
        //ロングタップの始まりだけ表示する
        if(sender.state == UIGestureRecognizerState.began) {
            if self.image == nil { return }
            
            _window = UIWindow()
            _window.backgroundColor = UIColor.clear
            _window.frame = UIScreen.main.bounds
            
            // myWindowをkeyWindowにする.
            _window.makeKey()
            
            // windowを表示する.
            self._window.makeKeyAndVisible()
            
            //グレーのマスク
            _maskView = UIView(frame: _window.frame)
            _maskView.backgroundColor = UIColor.lightGray
            _maskView.alpha = 0.5
            _window.addSubview(_maskView)
            
            //拡大されたイメージ
            _imageView = UIImageView(frame: _window.frame)
            _imageView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            _imageView.image = self.image
            _imageView.center = _maskView.center
            _imageView.contentMode = .scaleAspectFit
            
            _window.addSubview(_imageView)
            
            let closeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closePreviewView))
            _window.addGestureRecognizer(closeTapGestureRecognizer)
            
            UIView.animate(withDuration: 0.2)
            {
                self._imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
    }
    
    
    /// プレビューを閉じる
    @objc private func closePreviewView()
    {
        
        UIWindow.animate(withDuration: 0.2, animations:
            {
                self._imageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                self._window.alpha = 0.2
        })
        { end in
            //後片付け
            self._imageView = nil
            self._maskView = nil
            self._window.resignKey()
            self._window.removeFromSuperview()
            self._window = nil
        }
        
        
        
    }
}
