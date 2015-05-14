//
//  ALKeyboardObservingInputBar.swift
//  ALTextInputBar
//
//  Created by Alex Littlejohn on 2015/05/14.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

public let InputAccessoryViewKeyboardFrameDidChangeNotification = "InputAccessoryViewKeyboardFrameDidChangeNotification"

public class ALKeyboardObservingInputBar: UIView {
    private weak var observedView: UIView?

    // MARK: - Keyboard Observing -
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        
        removeKeyboardObserver()
        if let _newSuperview = newSuperview {
            addKeyboardObserver(_newSuperview)
        }
        
        super.willMoveToSuperview(newSuperview)
    }
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if object as? NSObject == superview && keyPath == keyboardHandlingKeyPath() {
            keyboardDidChangeFrame(superview!.frame)
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
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
        NSNotificationCenter.defaultCenter().postNotificationName(InputAccessoryViewKeyboardFrameDidChangeNotification, object: nil, userInfo: userInfo)
    }
    
    deinit {
        removeKeyboardObserver()
    }
}
