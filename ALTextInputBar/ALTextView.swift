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
    
    - parameter textView: The text view that triggered the size change
    - parameter newHeight: The ideal height for the new text view
    */
    func textViewHeightChanged(textView: ALTextView, newHeight: CGFloat)
}

public class ALTextView: UITextView {
    
    override public var font: UIFont? {
        didSet {
            placeholderLabel.font = font
        }
    }
    
    override public var contentSize: CGSize {
        didSet {
            updateSize()
        }
    }
    
    /// The delegate object to be notified if the content size will change 
    /// The delegate should update handle text view layout
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
    
    /// The maximum number of lines that will be shown before the text view will scroll. 0 = no limit
    public var maxNumberOfLines: CGFloat = 0
    public var expectedHeight: CGFloat = 0
    public var minimumHeight: CGFloat {
        get {
            return ceil(font!.lineHeight) + textContainerInset.top + textContainerInset.bottom
        }
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
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
            maxHeight = (ceil(font!.lineHeight) * maxNumberOfLines) + textContainerInset.top + textContainerInset.bottom
        }

        let roundedHeight = roundHeight()
        expectedHeight = roundedHeight >= maxHeight ? maxHeight : roundedHeight
        
        if textViewDelegate != nil {
            textViewDelegate?.textViewHeightChanged(self, newHeight:expectedHeight)
        }
        
        ensureCaretDisplaysCorrectly()
    }
    
    /**
    Calculates the correct height for the text currently in the textview as we cannot rely on contentsize to do the right thing
    */
    private func roundHeight() -> CGFloat {
        var newHeight: CGFloat = 0
        
        if let font = font {
            let attributes = [NSFontAttributeName: font]
            let boundingSize = CGSizeMake(frame.size.width, CGFloat.max)
            let size = (text as NSString).boundingRectWithSize(boundingSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
            newHeight = ceil(size.height)
        }
        
        return newHeight + textContainerInset.top + textContainerInset.bottom
    }
    
    /**
    Ensure that when the text view is resized that the caret displays correctly withing the visible space
    */
    private func ensureCaretDisplaysCorrectly() {
        if let s = selectedTextRange {
            let rect = caretRectForPosition(s.end)
            UIView.performWithoutAnimation({ () -> Void in
                self.scrollRectToVisible(rect, animated: false)
            })
        }
    }
    
    //MARK: - Placeholder Layout -
    
    /**
    Determines if the placeholder should be hidden dependant on whether it was set and if there is text in the text view
    
    - returns: true if it should not be visible
    */
    private func shouldHidePlaceholder() -> Bool {
        return placeholder.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 || text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
    }
    
    /**
    Layout the placeholder label to fit in the rect specified
    
    - parameter rect: The constrained size in which to fit the label
    - returns: The placeholder label frame
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
        if let object = notification.object as? ALTextView {
            if object == self {
                placeholderLabel.hidden = shouldHidePlaceholder()
                layoutManager.invalidateLayoutForCharacterRange(NSMakeRange(0, text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)), actualCharacterRange: nil)
            }
        }
    }
}
