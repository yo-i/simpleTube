//
//  FFPadTextiew.swift
//  Albina
//
//  Created by yo_i on 2018/02/06.
//  Copyright © 2018年 Open Resource Corporation. All rights reserved.
//

import UIKit

class FFPadTextView: UITextView ,UITextViewDelegate
{
    var maxLength : Int = Int.max
    var minLength : Int = 0
    var shouldMoveMin:CGFloat = 510                         //親を上にスクロールする基準
    var notification = NotificationCenter.default                     //通知センター、キーボードの表示を監視する
    var superViewInitFrame:CGRect!                          //自分の親ビュー
    
    
    //使用中　背景色変更
    var inUse:Bool = false
    {
        didSet
        {
            self.updateSelfStyle()
        }
    }
    
    func updateSelfStyle()
    {
        if self.inUse == true
        {
            //アニメション付きの背景色変化
            UIView.animate(withDuration: 0.5
                , animations: {self.backgroundColor = .cellSelected}
                , completion: nil)
        }
        else
        {
            //アニメション付きの背景色変化
            UIView.animate(withDuration: 0.5
                , animations: {self.backgroundColor = .white}
                , completion: nil)
        }
    }
    
    /// 初期化
    ///
    /// - Parameters:
    ///   - frame: フレーム
    ///   - textContainer: テキスト中身
    override init(frame: CGRect, textContainer: NSTextContainer?)
    {
        super.init(frame: frame, textContainer: textContainer)
        self.font = FFFont.systemFontOfSize(20)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        self.delegate = self
        setSelfStyle()
    }
    override func didMoveToSuperview()
    {
        self.superViewInitFrame = self.superview?.frame
    }
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setSelfStyle()
    {
        
        self.layer.borderWidth = 1                               //枠の太さ
        self.layer.borderColor = UIColor.borderColor.cgColor     //枠の色
        self.layer.cornerRadius = 7.5
        self.backgroundColor = UIColor.white                     //背景色
        
        
        notification.addObserver(self, selector: #selector(self.keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)    //キーボードが表示される寸前を監視する、通知が来たらkeyBoardWillShow()を呼び出す
        notification.addObserver(self, selector: #selector(self.keyBoardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)    //キーボードが閉じられる寸前を監視する、通知が来たらkeyBoardWillHide()を呼び出す
    }
    
    //キーボード表示前の通知
    @objc func keyBoardWillShow(_ notification:NotificationCenter)
    {
        
    }
    //キーボード閉じる前の通知
    @objc func keyBoardWillHide(_ notification:NotificationCenter)
    {
        self.inUse = false
        self.superViewRollBack()                            //画面を元に戻る
    }
    //画面を上にスクロール
    func superViewRollUp(_ py:CGFloat)
    {
        UIView.animate(withDuration: 0.35                                     //0.35秒を掛かって
            , delay: 0                                                      //遅延0秒
            , options: UIViewAnimationOptions()                //アニメションオプション：加速で開始、減速で終了
            , animations: {self.superview!.frame.origin.y = 300 - py }      //アニメション処理
            , completion: nil)                                              //アニメション終了処理
    }
    //画面を元に戻す
    func superViewRollBack()
    {
        UIView.animate(withDuration: 0.35                                     //0.35秒を掛かって
            , delay: 0                                                      //遅延0秒
            , options: UIViewAnimationOptions()                //アニメションオプション：加速で開始、減速で終了
            , animations: {self.superview!.frame = self.superViewInitFrame} //アニメション処理
            , completion: nil)                                              //アニメション終了処理
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        self.inUse = true
        
        self.superViewInitFrame = self.superview?.frame
        
        if (convert(textView.frame.origin, to: self.window).y + textView.frame.height) > self.shouldMoveMin
        {
            self.superViewRollUp(textView.frame.origin.y + textView.frame.height)  //親ビューを上にスクロールする
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if self.text != nil
        {
            if self.text.characters.count > maxLength
            {
                self.text = (self.text as NSString).substring(to: maxLength)
            }
        }
    }
}

