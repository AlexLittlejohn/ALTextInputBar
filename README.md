# ALTextInputBar
An auto growing text input bar for messaging apps. Written in Swift

---

ALTextInputBar is designed to solve a few issues that folks usually encounter when building messaging apps.

### Features
- Supports iOS 7
- Simple to use and configure
- Automatic resizing based on content
- Interactive dismiss gesture support

### Usage

This is the minimum configuration required to attach an input bar to the keyboard.
```swift
    class ViewController: UIViewController {

        let textInputBar = ALTextInputBar()
        
        // The magic sauce
        // This is how we attach the input bar to the keyboard
        override var inputAccessoryView: UIView? {
            get {
                return textInputBar
            }
        }
        
        // Another ingredient in the magic sauce
        override func canBecomeFirstResponder() -> Bool {
            return true
        }
    }
```
#### ALTextInputBar Configuration

Used for vertical padding and such.  
Also used for the intrinsic content size when using autolayout.
```swift
public var defaultHeight: CGFloat = 44
```
If true the right button will always be visible else it will only show when there is text in the text view.
```swift
public var alwaysShowRightButton = false
```
The horizontal padding between the input bar edges and its subviews.
```swift
public var horizontalPadding: CGFloat = 0
```
The horizontal spacing between subviews.
```swift
public var horizontalSpacing: CGFloat = 5
```
This view will be displayed on the left of the text view.  
If this view is nil nothing will be displayed, and the text view will fill the space.
```swift
public var leftView: UIView?
```
This view will be displayed on the right of the text view.  
If this view is nil nothing will be displayed, and the text view will fill the space.  
If alwaysShowRightButton is false this view will animate in from the right when the text view has content.
```swift
public var rightView: UIView?
```
The input bar's text view instance.
```swift
public let textView: ALTextView
```

#### ALTextView Configuration

The delegate object to be notified if the content size will change.   
The delegate should update handle text view layout.
```swift
public weak var textViewDelegate: ALTextViewDelegate?
```
The text that appears as a placeholder when the text view is empty.
```swift
public var placeholder: String = ""
```
The color of the placeholder text.
```swift
public var placeholderColor: UIColor!
```
The maximum number of lines that will be shown before the text view will scroll. 0 = no limit
```swift
public var maxNumberOfLines: CGFloat = 0
```
## License
ALTextInputBar is available under the MIT license. See the LICENSE file for more info.


