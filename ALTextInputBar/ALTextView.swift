//
//  ALTextView.swift
//  ALTextInputBar
//
//  Created by Alex Littlejohn on 2015/04/24.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

public protocol ALTextViewDelegate: UITextViewDelegate {
    
    /**
    Notifies the receiver of a change to the contentSize of the textView
    
    The receiver is responsible for layout
    
    :param: textView The text view that triggered the size change
    :param: newHeight The ideal height for the new text view
    */
    func textViewHeightChanged(textView: UITextView, newHeight: CGFloat)
}

public class ALTextView: UITextView {
    
    override public var font: UIFont! {
        didSet {
            placeholderLabel.font = font
        }
    }
    
    override public var contentSize: CGSize {
        didSet {
            updateSize()
        }
    }
    
    /// The delegate object will be notified if the content size will change and should update the size of the text view to match
    public weak var textViewDelegate: ALTextViewDelegate? {
        didSet {
            delegate = textViewDelegate
        }
    }
    
    /// The text that appears as a placeholder when the text view is empty
    public var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    /// The color of the placeholder text
    public var placeholderColor: UIColor! {
        get {
            return placeholderLabel.textColor
        }
        set(newValue) {
            placeholderLabel.textColor = newValue
        }
    }
    
    private lazy var placeholderLabel: UILabel = {
        var _placeholderLabel = UILabel()
        
        _placeholderLabel.clipsToBounds = false
        _placeholderLabel.autoresizesSubviews = false
        _placeholderLabel.numberOfLines = 1
        _placeholderLabel.font = self.font
        _placeholderLabel.backgroundColor = UIColor.clearColor()
        _placeholderLabel.textColor = self.tintColor
        _placeholderLabel.hidden = true
        
        self.addSubview(_placeholderLabel)
        
        return _placeholderLabel
        }()
    
    /// The maximum number of lines before that will be shown. 0 = no limit
    public var maxNumberOfLines: CGFloat = 0
    
    private var numberOfLines: CGFloat {
        get {
            return fabs(contentSize.height/font.lineHeight)
        }
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textViewDidChange:", name:UITextViewTextDidChangeNotification, object: self)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        placeholderLabel.hidden = shouldHidePlaceholder()
        if !placeholderLabel.hidden {
            placeholderLabel.frame = placeholderRectThatFits(bounds)
            sendSubviewToBack(placeholderLabel)
        }
    }
    
    //MARK: - Sizing and scrolling -
    /**
    Notify the delegate of size changes if necessary
    */
    private func updateSize() {
        var maxHeight = CGFloat.max
        
        if maxNumberOfLines > 0 {
            maxHeight = font.lineHeight * maxNumberOfLines
        }
        
        let newHeight = contentSize.height > maxHeight ? maxHeight : contentSize.height
        
        if textViewDelegate != nil && newHeight != frame.size.height {
            textViewDelegate?.textViewHeightChanged(self, newHeight:newHeight)
        }
        
        ensureCaretDisplaysCorrectly()
    }
    
    /**
    Ensure that when the text view is resized that the caret displays correctly withing the visible space
    */
    private func ensureCaretDisplaysCorrectly() {
        let rect = caretRectForPosition(selectedTextRange?.end)
        UIView.performWithoutAnimation({ () -> Void in
            self.scrollRectToVisible(rect, animated: false)
        })
    }
    
    //MARK: - Placeholder Layout -
    
    /**
    Determines if the placeholder should be hidden dependant on whether it was set and if there is text in the text view
    
    :returns: true if it should not be visible
    */
    private func shouldHidePlaceholder() -> Bool {
        return placeholder.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 || text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
    }
    
    /**
    Layout the placeholder label to fit in the rect specified
    
    :param: rect The constrained size in which to fit the label
    :returns: The placeholder label frame
    */
    private func placeholderRectThatFits(rect: CGRect) -> CGRect {
        
        var placeholderRect = CGRectZero
        placeholderRect.size = placeholderLabel.sizeThatFits(rect.size)
        placeholderRect.origin = UIEdgeInsetsInsetRect(rect, textContainerInset).origin
        
        let padding = textContainer.lineFragmentPadding
        placeholderRect.origin.x += padding
        
        return placeholderRect
    }
    
    //MARK: - Notifications -
    
    func textViewDidChange(notification: NSNotification) {
        if notification.object == self {
            placeholderLabel.hidden = shouldHidePlaceholder()
            layoutManager.invalidateLayoutForCharacterRange(NSMakeRange(0, text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)), actualCharacterRange: nil)
        }
    }
}
