//
//  FFFont.swift
//  Artemis
//
//  Created by yo_i on 2017/11/21.
//  Copyright © 2017年 Open Resource Corporation. All rights reserved.
//

import UIKit
let FF_FONT_NAME = "HelveticaNeue"
let FF_BOLD_FONT_NAME = "HelveticaNeue-Bold"

/// OSによってデフォルトフォントが変わることがあります
class FFFont
{
    
    /// 通常フォント
    ///
    /// - Parameter size: フォントサイズ デフォルト17
    /// - Returns: フォント
    static func systemFontOfSize(_ size:CGFloat = 17)->UIFont
    {
        return UIFont.init(name: FF_FONT_NAME, size: size)!
    }
    
    
    /// 通常フォント太字
    ///
    /// - Parameter size: フォントサイズ デフォルト17
    /// - Returns: フォント
    static func boldSystemFontOfSize(_ size:CGFloat = 17)->UIFont
    {
        return UIFont.init(name: FF_BOLD_FONT_NAME, size: size)!
    }
}
