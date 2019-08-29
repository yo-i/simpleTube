//
//  FFReportCanvas.swift
//  FFFWSample
//
//  Created by yo_i on 2017/11/13.
//  Copyright © 2017年 yo_i. All rights reserved.
//

import Foundation
import UIKit
import PDFKit

/// A4帳票キャンパス幅
let REPORT_CANVAS_WIDTH = 580

/// A4帳票キャンパス高さ
let REPORT_CANVAS_HEIGHT = 840

//A4レポートキャンパス
class FFReportCanvas:UIView
{
    
    /// A4帳票の元
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: REPORT_CANVAS_WIDTH, height: REPORT_CANVAS_HEIGHT))
    }
    private override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: REPORT_CANVAS_WIDTH, height: REPORT_CANVAS_HEIGHT))
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
