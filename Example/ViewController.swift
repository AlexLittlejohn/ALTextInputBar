//
//  ViewController.swift
//  ALTextInputBar
//
//  Created by Alex Littlejohn on 2015/04/24.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let textInputBar = ALTextInputBar()
    let keyboardObserver = ALKeyboardObservingView()
    
    let scrollView = UIScrollView()
    
    // This is how we observe the keyboard position
    override var inputAccessoryView: UIView? {
        get {
            return keyboardObserver
        }
    }
    
    // This is also required
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureScrollView()
        configureInputBar()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardFrameChanged(_:)), name: ALKeyboardFrameDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.frame = view.bounds
        textInputBar.frame.size.width = view.bounds.size.width
    }

    func configureScrollView() {
        view.addSubview(scrollView)
        
        let contentView = UIView(frame: CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height * 2))
        contentView.backgroundColor = UIColor(white: 0.8, alpha: 1)
        
        scrollView.addSubview(contentView)
        scrollView.contentSize = contentView.bounds.size
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        scrollView.backgroundColor = UIColor(white: 0.6, alpha: 1)
    }
    
    func configureInputBar() {
        let leftButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        let rightButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        
        leftButton.setImage(UIImage(named: "leftIcon"), forState: UIControlState.Normal)
        rightButton.setImage(UIImage(named: "rightIcon"), forState: UIControlState.Normal)
        
        keyboardObserver.userInteractionEnabled = false
        
        textInputBar.showTextViewBorder = true
        textInputBar.leftView = leftButton
        textInputBar.rightView = rightButton
        textInputBar.frame = CGRectMake(0, view.frame.size.height - textInputBar.defaultHeight, view.frame.size.width, textInputBar.defaultHeight)
        textInputBar.backgroundColor = UIColor(white: 0.95, alpha: 1)
        textInputBar.keyboardObserver = keyboardObserver
        
        view.addSubview(textInputBar)
    }

    func keyboardFrameChanged(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            textInputBar.frame.origin.y = frame.origin.y
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            textInputBar.frame.origin.y = frame.origin.y
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            textInputBar.frame.origin.y = frame.origin.y
        }
    }
    
}

