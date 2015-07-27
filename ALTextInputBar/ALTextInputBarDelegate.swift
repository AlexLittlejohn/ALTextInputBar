//
//  ALTextInputBarDelegate.swift
//  ALTextInputBar
//
//  Created by Alex Littlejohn on 2015/05/14.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

@objc
public protocol ALTextInputBarDelegate: NSObjectProtocol {
    optional func textViewShouldBeginEditing(textView: ALTextView) -> Bool
    optional func textViewShouldEndEditing(textView: ALTextView) -> Bool
    
    optional func textViewDidBeginEditing(textView: ALTextView)
    optional func textViewDidEndEditing(textView: ALTextView)
    
    optional func textViewDidChange(textView: ALTextView)
    optional func textViewDidChangeSelection(textView: ALTextView)
    
    optional func textViewShouldReturn(textView: ALTextView) -> Bool
    
    optional func inputBarDidChangeHeight(height: CGFloat)
}
