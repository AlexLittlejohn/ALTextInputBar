//
//  ALTextInputUtilities.swift
//  ALTextInputBar
//
//  Created by Alex Littlejohn on 2015/05/14.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

internal func defaultNumberOfLines() -> CGFloat {
    if (UIDevice.isIPad()) {
        return 8;
    }
    if (UIDevice.isIPhone4()) {
        return 4;
    }
    
    return 6;
}

internal extension UIDevice {
    internal class func isIPad() -> Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
    }
    
    internal class func isIPhone() -> Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone
    }
    
    internal class func isIPhone4() -> Bool {
        return UIDevice.isIPhone() && UIScreen.mainScreen().bounds.size.height < 568.0
    }
    
    internal class func floatVersion() -> Float {
        return (UIDevice.currentDevice().systemVersion as NSString).floatValue
    }
}
