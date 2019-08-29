//
//  FFCalendar.swift
//  Artemis
//
//  Created by yo_i on 2017/11/29.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import UIKit

//日付セルのサイズ
let CALENDAR_CELL_SIZE = 40
//一行のセル数
let CALENDAR_ROW    = 7
//一ヶ月の行数
let CALENDAR_COLUMN = 6

class FFCalendar:UIView,UIScrollViewDelegate
{
    // 初期値2090年(2001年から 60秒　* 60分 * 24時間 * 365日 * 90年)
    var maxDate:Date = Date(timeIntervalSinceReferenceDate: 60 * 60 * 24 * 365 * 90)
    {
        didSet { clacDateLimit();refushCells() }
    }
    
    var minDate:Date = Date(timeIntervalSince1970: 0)
    {
        didSet { clacDateLimit();refushCells() }
    }
    
    var selectedDate:Date? = nil
    {
        didSet { refushCells() }
    }
    var startDate:Date? = nil
    var labelYearMonth:UILabel!
    var labelWeekDay:UILabel!
    var scrollMonths:UIScrollView!
    //自分自身のサイズ
    let viewSize = CGSize(width: CALENDAR_CELL_SIZE * CALENDAR_ROW
        , height: CALENDAR_CELL_SIZE * CALENDAR_COLUMN + 50)
    //計算用カレンダーオブジェクト
    var currentCalendar = Calendar(identifier: .gregorian)
    //月の相対原点
    var monthOrigin = 0
    
    var maxDateDecimal:Decimal!                                 //最大日付計算用パラメター
    var minDateDecimal:Decimal!                                 //最小日付計算用パラメター
    let dateFormartStr = "yyyyMMdd"                             //日付フォマット
    
    var isShowDelivery : Bool = false                           //定期便ラベル表示
    var isSelectedDeliveryDate : Bool = false                   //選択日付が定期便か
    var deliveryDateArray :Array<String> = []
    let displayKey:String    = "mainvalue"
    let objectCodeKey:String = "subkey1"
    let objectCodeSubKey:String = "subkey2"
    
    override init(frame: CGRect)
    {
        maxDateDecimal = maxDate.toString(dateFormartStr).decimal
        minDateDecimal = minDate.toString(dateFormartStr).decimal
        super.init(frame: frame)
        self.frame.size = viewSize
        self.currentCalendar.locale = Locale(identifier: "ja_JP")
        
        
        //ラベル初期化
        setLabelYearMonty()
        setLabelWeekDay()
        setScrollMonth()
        
        //初期データ
        startDate = Date()
        if selectedDate != nil
        {
            startDate = selectedDate
        }
        else
        {
            selectedDate = Date()
        }
        
        
        //画面描画
        setContent()
        
    }
    
    init(frame: CGRect,startDate:Date)
    {
        maxDateDecimal = maxDate.toString(dateFormartStr).decimal
        minDateDecimal = minDate.toString(dateFormartStr).decimal
        super.init(frame: frame)
        self.frame.size = viewSize
        self.currentCalendar.locale = Locale(identifier: "ja_JP")
        
        //ラベル初期化
        setLabelYearMonty()
        setLabelWeekDay()
        setScrollMonth()
        
        //初期データ
        self.selectedDate = Date()
        self.startDate = startDate
        
        //画面描画
        setContent()
    }
    
    init(frame: CGRect,selectedDate:Date)
    {
        maxDateDecimal = maxDate.toString(dateFormartStr).decimal
        minDateDecimal = minDate.toString(dateFormartStr).decimal
        super.init(frame: frame)
        self.frame.size = viewSize
        self.currentCalendar.locale = Locale(identifier: "ja_JP")
        
        //ラベル初期化
        setLabelYearMonty()
        setLabelWeekDay()
        setScrollMonth()
        
        //初期データ
        self.selectedDate = selectedDate
        self.startDate = selectedDate
        
        //画面描画
        setContent()
    }
    init(frame: CGRect,isShowDelivery:Bool)
    {
        maxDateDecimal = maxDate.toString(dateFormartStr).decimal
        minDateDecimal = minDate.toString(dateFormartStr).decimal
        super.init(frame: frame)
        self.frame.size = viewSize
        self.isShowDelivery = isShowDelivery
        self.currentCalendar.locale = Locale(identifier: "ja_JP")
        
        //ラベル初期化
        setLabelYearMonty()
        setLabelWeekDay()
        setScrollMonth()
        
        //初期データ
        startDate = Date()
        if selectedDate != nil
        {
            startDate = selectedDate
        }
        else
        {
            selectedDate = Date()
        }
        //定義マスタから定期便日付リストを取得
        setDueDateArray()
        //画面描画
        setContent()
    }
    
    
    
    required init?(coder aDecoder: NSCoder)
    {
        maxDateDecimal = maxDate.toString(dateFormartStr).decimal
        minDateDecimal = minDate.toString(dateFormartStr).decimal
        super.init(coder: aDecoder)
    }
    
    
    
    //年月表すラベル
    func setLabelYearMonty()
    {
        labelYearMonth = UILabel(frame: CGRect(x: 0,y: 0,width: CALENDAR_CELL_SIZE * CALENDAR_ROW,height: 20))
        labelYearMonth.textAlignment = .center
        labelYearMonth.font = FFFont.systemFontOfSize()
        self.addSubview(labelYearMonth)
    }
    
    //曜日を表すラベル
    func setLabelWeekDay()
    {
        labelWeekDay = UILabel(frame: CGRect(x: 0,y: 25,width: CALENDAR_CELL_SIZE * CALENDAR_ROW,height: 20))
        
        for (i,day) in Date.weekDayString.enumerated()
        {
            let label = UILabel(frame: CGRect(x: 0 + i * CALENDAR_CELL_SIZE,y: 0,width: CALENDAR_CELL_SIZE,height: 20))
            label.text = day
            label.textAlignment = .center
            
            switch day
            {
            case "土":
                label.textColor = UIColor.holidayBlue
            case "日":
                label.textColor = UIColor.holidayRed
            default :
                break
            }
            
            labelWeekDay.addSubview(label)
        }
        
        self.addSubview(labelWeekDay)
    }
    
    //スクロールできるビュー(3ページ分)
    func setScrollMonth()
    {
        scrollMonths = UIScrollView(frame: CGRect(x: 0,y: 50,width: CGFloat(CALENDAR_CELL_SIZE * CALENDAR_ROW)
            ,height: CGFloat(CALENDAR_CELL_SIZE * CALENDAR_COLUMN)))
        scrollMonths.showsHorizontalScrollIndicator = false
        scrollMonths.isPagingEnabled = true
        scrollMonths.isUserInteractionEnabled = true
        scrollMonths.delegate = self
        scrollMonths.contentSize = CGSize(width: 3 * CGFloat(CALENDAR_CELL_SIZE * CALENDAR_ROW)
            , height: CGFloat(CALENDAR_CELL_SIZE * CALENDAR_COLUMN))
        
        self.addSubview(scrollMonths)
    }
    
    //定義マスタから定期便日付リスト取得
    func setDueDateArray()
    {

    }
    
    //日付セルのセット
    func setCalendarCells(_ date:Date,inView:UIView,startPx:Int)
    {
        let components = (currentCalendar as NSCalendar).components([.year,.month,.day,.weekday], from: date)
        let countDays = (currentCalendar as NSCalendar).range(of: .day, in: .month, for: date)
        var monthFirstDay = DateComponents()
        monthFirstDay.day = 1
        monthFirstDay.month = components.month
        monthFirstDay.year = components.year
       
        
        let firstDayComponents = (currentCalendar as NSCalendar).components([.weekday], from: currentCalendar.date(from: monthFirstDay)!)
        let startDay = (firstDayComponents.weekday! + 6) % 7
        
        let monthDayMax = countDays.length
        
        
        for i in startDay ..< startDay + monthDayMax
        {
            let dayNumber = i - startDay + 1
            
            let cellFrame = CGRect(x: startPx + i % CALENDAR_ROW * CALENDAR_CELL_SIZE
                , y: i / CALENDAR_ROW * CALENDAR_CELL_SIZE
                , width: CALENDAR_CELL_SIZE, height: CALENDAR_CELL_SIZE)
            var cell : FFCalendarCell!

            var workDate = DateComponents()
            workDate.day = dayNumber
            workDate.month = components.month
            workDate.year = components.year
            
            let newDate = currentCalendar.date(from: workDate)
            
            if isShowDelivery
            {
                //定期便の日は定期便ラベル表示
                let dateString = newDate?.toString("yyyyMMdd")
                if deliveryDateArray.contains(dateString ?? "")
                {
                    cell = FFCalendarCell(frame: cellFrame, dayStr: dayNumber.toString(), isShowDelivery: isShowDelivery)
                }
                else
                {
                    cell = FFCalendarCell(frame: cellFrame
                        , dayStr: dayNumber.toString(), jpWeekDay: nil)
                }
            }
            else
            {
                cell = FFCalendarCell(frame: cellFrame
                    , dayStr: dayNumber.toString(), jpWeekDay: nil)
            }
            
            cell.date = newDate
            cell.addTarget(self, action: #selector(self.clickCell(sender:)), for: .touchUpInside)
            cell.weekDay = (startDay + i) % 7
            
            if cell.date?.isHoliday() ?? false
            {
                cell.labelDay.textColor = UIColor.holidayRed
            }
            else
            {
                if cell.date?.weekdayString() == "日"
                {
                    cell.labelDay.textColor = UIColor.holidayRed
                }
                else
                {
                    cell.labelDay.textColor = UIColor.black
                }
            }
            
            
            inView.addSubview(cell)
        }
        
        
    }
    
    
    //選択されたデータを反映
    func setSelectedDate(_ inView:UIView)
    {
        let selectedDateStr = selectedDate!.toString(dateFormartStr)
        for cell in inView.subviews.filter({$0 is FFCalendarCell})
            .map({$0 as! FFCalendarCell})
            .filter({$0.date?.toString(dateFormartStr) == selectedDateStr})
        {
            cell.setClick(cell)
        }
    }
    
    //セル状態の更新
    func refushCells()
    {
        
        guard let inView = scrollMonths else
        {
            return
        }
        setDateLimit(inView: inView)
        setSelectedDate(scrollMonths)
    }
    
    /// セルのクリック
    ///
    /// - Parameter sender: イベントのセンダー
    @objc func clickCell(sender:FFCalendarCell)
    {
        if sender.on
        {
            self.selectedDate = sender.date!
            
            self.isSelectedDeliveryDate = sender.isShowDelivery
        }
    }
    
    
    /// 現在選択されたらデートを取得
    ///
    /// - Returns: 選択されたらデート
    func getSelectedDate()->Date?
    {
        return self.selectedDate
    }
    
    //年月ラベルの更新
    func updateYearMonth()
    {
        labelYearMonth.text = startDate?.dateInterval(monthsInterval: monthOrigin).toString("yyyy年MM月")
    }
    
    //スクロールビュースクロールしたイベントのデリゲート
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        //ページ
        let pageNow = Int(scrollView.contentOffset.x) / (CALENDAR_ROW * CALENDAR_CELL_SIZE)
        
        //左にスワップ
        if pageNow == 0
        {
            //基準月-1
            monthOrigin -= 1
        }
        else if pageNow == 2
        {
            monthOrigin += 1
        }
        
        //ボタンクリア
        clearAllCell(inView: scrollView)
        //再描画
        setContent()
        //
        setDateLimit(inView: scrollView)
        
    }
    
    func setContent()
    {
        guard let scrollView = self.scrollMonths else
        {
            return
        }
        
        for (i,num) in [-1,0,1].enumerated()
        {
            let toCreateDate = startDate?.dateInterval(monthsInterval: num + monthOrigin)
            setCalendarCells(toCreateDate!, inView: scrollView, startPx: i * CALENDAR_ROW * CALENDAR_CELL_SIZE )
        }
        scrollView.setContentOffset(CGPoint(x: CALENDAR_ROW * CALENDAR_CELL_SIZE, y: 0) , animated: false)
        
        setSelectedDate(scrollView)
        updateYearMonth()
    }
    
    //日付セルを消し
    func clearAllCell(inView:UIView)
    {
        for cell in inView.subviews.filter({$0 is FFCalendarCell}).map({$0 as! FFCalendarCell})
        {
            cell.removeFromSuperview()
        }
    }
    
    func clacDateLimit()
    {
        maxDateDecimal = maxDate.toString(dateFormartStr).decimal
        minDateDecimal = minDate.toString(dateFormartStr).decimal
    }
    
    /// 限界
    ///
    /// - Parameter inView: 対象ビューに
    func setDateLimit(inView:UIView)
    {
        
        for cell in inView.subviews
            .filter({$0 is FFCalendarCell})
            .map({$0 as! FFCalendarCell})
        {
            
            let cellDecimal = cell.date!.toString(dateFormartStr).decimal
            let maxd = cellDecimal - maxDateDecimal
            let mind = cellDecimal - minDateDecimal
            
            
            if maxd > 0 || mind < 0
            {
                cell.on = false
                cell.isEnabled = false
            }
            else
            {
                cell.isEnabled = true
            }
            
        }
    }
    
}
//カレンダー用のセル
class FFCalendarCell:FFSwitchButton
{
    var labelDay:UILabel!                   //日付ラベル
    var labelJpWeekDay:UILabel!             //六曜ラベル
    var labelDelivery:UILabel!              //定期便ラベル
    
    var dayString:String? = nil             //日の文字列
    var jpWeekDay:Int? = nil                //六曜日のint値
    var weekDay:Int? = nil                  //曜日の
    var date:Date? = nil
    var isShowDelivery : Bool = false
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.switchBackgroundColor = (UIColor.cellSelected,UIColor.clear)
        
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 0
        
        self.frame.size = CGSize(width: CALENDAR_CELL_SIZE, height: CALENDAR_CELL_SIZE)
        self.alpha = 1
    }
    
    convenience init(frame: CGRect,dayStr:String?,jpWeekDay:Int?)
    {
        self.init(frame: frame)
        self.dayString = dayStr
        self.jpWeekDay = jpWeekDay
        
        if self.dayString != nil
        {
            setDayLabel()
        }
        
        if self.jpWeekDay != nil
        {
            setJpWeekDayLabel()
        }
        
    }
    convenience init(frame: CGRect,dayStr:String?,isShowDelivery:Bool = false)
    {
        self.init(frame: frame)
        self.dayString = dayStr
        self.isShowDelivery = isShowDelivery
        
        if self.dayString != nil
        {
            setDayLabel()
        }
        if isShowDelivery
        {
            
            setDeliveryLabel()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    /// クリックイベント
    ///
    /// - Parameter sender: イベントセンダー
    override func setClick(_ sender: AnyObject)
    {
        //オンの場合無視、オフの場合オンにする
        if self.on { return }
        else{ self.on = true }
        
        guard let pView = self.superview else
        {
            return
        }
        
        //親ビューに自分と同じ型のサブを抽出
        for v in pView.subviews.filter({$0 is FFCalendarCell}).map({$0 as! FFCalendarCell})
        {
            //自分以外のcellをオフにする
            if !v.isEqual(self)
            {
                if v.isEnabled { v.on = false}
            }
        }
    }
    
    override func setCancel(_ sender: AnyObject)
    {
        //NOP
    }
    
    override func setTouchDown()
    {
        //NOP
    }
    
    override func updateEnabled()
    {
        //NOP
    }
    
    private func setDayLabel()
    {
        labelDay = UILabel(frame: CGRect(x: 2,y: 2,width: 36,height: 20))
        labelDay.text = self.dayString
        labelDay.font = FFFont.boldSystemFontOfSize(18)
        labelDay.textAlignment = .center
        self.addSubview(labelDay)
        
    }
    
    
    /// 六曜ラベルをセット
    private func setJpWeekDayLabel()
    {
        if jpWeekDay == nil {return}
        labelJpWeekDay = UILabel(frame: CGRect(x: 2,y: 22,width: 36,height: 18))
        labelJpWeekDay.text = Date.jpWeekDayString[jpWeekDay!]
        labelJpWeekDay.font = FFFont.systemFontOfSize(10)
        labelJpWeekDay.textAlignment = .center
        self.addSubview(labelJpWeekDay)
        
        if self.jpWeekDay == 0
        {
            labelJpWeekDay.textColor = UIColor.holidayRed
        }
        else
        {
            labelJpWeekDay.textColor = UIColor.fontBlack
        }
    }
    //定期便ラベルをセット
    private func setDeliveryLabel()
    {
        labelDelivery = UILabel(frame: CGRect(x: 2,y: 22,width: 36,height: 18))
        labelDelivery.text = "定"
        labelDelivery.font = FFFont.systemFontOfSize(10)
        labelDelivery.textAlignment = .center
        self.addSubview(labelDelivery)
    }
}

