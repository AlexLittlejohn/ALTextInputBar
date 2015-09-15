//
//  ALKeyboardObservingView.swift
//  ALTextInputBar
//
//  Created by Alex Littlejohn on 2015/05/14.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

public let ALKeyboardFrameDidChangeNotification = "ALKeyboardFrameDidChangeNotification"

public class ALKeyboardObservingView: UIView {

    private weak var observedView: UIView?
    private var defaultHeight: CGFloat = 44
    
    override public func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, defaultHeight)
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        
        removeKeyboardObserver()
        if let _newSuperview = newSuperview {
            addKeyboardObserver(_newSuperview)
        }
        
        super.willMoveToSuperview(newSuperview)
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if object as? NSObject == superview && keyPath == keyboardHandlingKeyPath() {
            keyboardDidChangeFrame(superview!.frame)
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    public func updateHeight(height: CGFloat) {
        if UIDevice.floatVersion() < 8.0 {
            frame.size.height = height
            
            setNeedsLayout()
            layoutIfNeeded()
        }
        
        for constraint in constraints {
            if constraint.firstAttribute == NSLayoutAttribute.Height && constraint.firstItem as! NSObject == self {
                constraint.constant = height < defaultHeight ? defaultHeight : height
            }
        }
    }
    
    private func keyboardHandlingKeyPath() -> String {
        if UIDevice.floatVersion() >= 8.0 {
            return "center"
        } else {
            return "frame"
        }
    }
    
    private func addKeyboardObserver(newSuperview: UIView) {
        observedView = newSuperview
        newSuperview.addObserver(self, forKeyPath: keyboardHandlingKeyPath(), options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    private func removeKeyboardObserver() {
        if observedView != nil {
            observedView!.removeObserver(self, forKeyPath: keyboardHandlingKeyPath())
            observedView = nil
        }
    }
    
    private func keyboardDidChangeFrame(frame: CGRect) {
        let userInfo = [UIKeyboardFrameEndUserInfoKey: NSValue(CGRect:frame)]
        NSNotificationCenter.defaultCenter().postNotificationName(ALKeyboardFrameDidChangeNotification, object: nil, userInfo: userInfo)
    }
    
    deinit {
        removeKeyboardObserver()
    }
}
