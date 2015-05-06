//
//  ALTextInputBar.swift
//  ALTextInputBar
//
//  Created by Alex Littlejohn on 2015/04/24.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

public typealias ALSubmitTextAction = (text: String) -> Void
public typealias ALButtonAction = () -> Void

public let InputAccessoryViewKeyboardFrameDidChangeNotification = "InputAccessoryViewKeyboardFrameDidChangeNotification"

private func defaultNumberOfLines() -> CGFloat {
    if (UIDevice.isIPad()) {
        return 8;
    }
    if (UIDevice.isIPhone4()) {
        return 4;
    }

    return 6;
}

/// A private extension to help determine how many lines of text to display by default
private extension UIDevice {
    class func isIPad() -> Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
    }
    
    class func isIPhone() -> Bool {
        return UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone
    }
    
    class func isIPhone4() -> Bool {
        return UIDevice.isIPhone() && UIScreen.mainScreen().bounds.size.height < 568.0
    }
    
    class func floatVersion() -> Float {
        return (UIDevice.currentDevice().systemVersion as NSString).floatValue
    }
}

public class ALTextInputBar: UIView, ALTextViewDelegate {
    
    /// Used for the intrinsic content size for autolayout
    public var defaultHeight: CGFloat = 44
    
    /// If true the right button will always be visible else it will only show when there is text in the text view
    public var alwaysShowRightButton = false
    
    /// The horizontal padding between the view edges and its subviews
    public var horizontalPadding: CGFloat = 0
    
    /// The horizontal spacing between subviews
    public var horizontalSpacing: CGFloat = 5
    
    /// Set and retrieve the text view text
    public var text: String! {
        get {
            return textView.text
        }
        set(newValue) {
            textView.text = newValue
        }
    }
    
    /** 
    This view will be displayed on the left of the text view.
    
    If this view is nil nothing will be displayed, and the text view will fill the space
    */
    public var leftView: UIView? {
        willSet(newValue) {
            if newValue == nil {
                if let view = leftView {
                    view.removeFromSuperview()
                }
            }
        }
        didSet {
            if let view = leftView {
                addSubview(view)
            }
        }
    }
    
    /**
    This view will be displayed on the right of the text view.
    
    If this view is nil nothing will be displayed, and the text view will fill the space
    If alwaysShowRightButton is false this view will animate in from the right when the text view has content
    */
    public var rightView: UIView? {
        willSet(newValue) {
            if newValue == nil {
                if let view = rightView {
                    view.removeFromSuperview()
                }
            }
        }
        didSet {
            if let view = rightView {
                addSubview(view)
            }
        }
    }
    
    /// The text view instance
    public let textView: ALTextView = {
        
        let _textView = ALTextView()
        
        _textView.textContainerInset = UIEdgeInsetsMake(1, 0, 1, 0);
        _textView.textContainer.lineFragmentPadding = 0
        
        _textView.maxNumberOfLines = defaultNumberOfLines()
        
        _textView.placeholder = "Type here"
        _textView.placeholderColor = UIColor.lightGrayColor()
        
        _textView.font = UIFont.systemFontOfSize(14)
        _textView.textColor = UIColor.darkGrayColor()

        _textView.backgroundColor = UIColor.clearColor()
        
        // This changes the caret color
        _textView.tintColor = UIColor.lightGrayColor()
        
        return _textView
        }()
    
    private var showRightButton = false
    private var showLeftButton = false
    
    private weak var observedView: UIView?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(textView)
        
        textView.textViewDelegate = self
        
        backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    // MARK: - View positioning and layout -

    override public func intrinsicContentSize() -> CGSize {
        return CGSizeMake(UIViewNoIntrinsicMetric, defaultHeight)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let size = frame.size
        let height = floor(size.height)
        
        var leftViewSize = CGSizeZero
        var rightViewSize = CGSizeZero
        
        if let view = leftView {
            leftViewSize = view.bounds.size
            
            let leftViewX: CGFloat = horizontalPadding
            let leftViewVerticalPadding = (defaultHeight - leftViewSize.height) / 2
            let leftViewY: CGFloat = height - (leftViewSize.height + leftViewVerticalPadding)
            view.frame = CGRectMake(leftViewX, leftViewY, leftViewSize.width, leftViewSize.height)
        }

        if let view = rightView {
            rightViewSize = view.bounds.size
            
            let rightViewVerticalPadding = (defaultHeight - rightViewSize.height) / 2
            var rightViewX = size.width
            let rightViewY = height - (rightViewSize.height + rightViewVerticalPadding)
            
            if showRightButton || alwaysShowRightButton {
                rightViewX -= (rightViewSize.width + horizontalPadding)
            }
            
            view.frame = CGRectMake(rightViewX, rightViewY, rightViewSize.width, rightViewSize.height)
        }
        
        let textViewPadding = (defaultHeight - textView.minimumHeight) / 2
        var textViewX = horizontalPadding
        let textViewY = textViewPadding
        let textViewHeight = textView.expectedHeight
        var textViewWidth = size.width - (horizontalPadding + horizontalPadding)
        
        if leftViewSize.width > 0 {
            textViewX += leftViewSize.width + horizontalSpacing
            textViewWidth -= leftViewSize.width + horizontalSpacing
        }
        
        if (showRightButton || alwaysShowRightButton) && rightViewSize.width > 0 {
            textViewWidth -= (horizontalSpacing + rightViewSize.width)
        }
        
        textView.frame = CGRectMake(textViewX, textViewY, textViewWidth, textViewHeight)
    }
    
    public func updateViews(animated: Bool) {
        if animated {
            // :discussion: Honestly not sure about the best way to calculated the ideal spring animation duration
            // however these values seem to work for Slack
            // possibly replace with facebook/pop but that opens another can of worms
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .CurveEaseInOut, animations: {
                self.setNeedsLayout()
                self.layoutIfNeeded()
                }, completion: nil)
            
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - ALTextViewDelegate -
    
    public final func textViewHeightChanged(textView: ALTextView, newHeight: CGFloat) {
        
        let padding = defaultHeight - textView.minimumHeight
        let height = padding + newHeight
        
        if UIDevice.floatVersion() < 8.0 {
            frame.size.height = height
            
            setNeedsLayout()
            layoutIfNeeded()
        }
        
        for c in constraints() {
            var constraint = c as! NSLayoutConstraint
            if constraint.firstAttribute == NSLayoutAttribute.Height && constraint.firstItem as! NSObject == self {
                constraint.constant = height < defaultHeight ? defaultHeight : height
            }
        }
    }
    
    public final func textViewDidChange(textView: UITextView) {
        var shouldShowButton = textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
        
        if showRightButton != shouldShowButton && !alwaysShowRightButton {
            showRightButton = shouldShowButton
            updateViews(true)
        }
    }
    
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
