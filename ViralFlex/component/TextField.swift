import UIKit

class TextField: UITextField {
    
    override func awakeFromNib() {
        
//        let centeredParagraphStyle = NSMutableParagraphStyle()
//        centeredParagraphStyle.alignment = .center
//        let attributedPlaceholder = NSAttributedString(string: "Placeholder", attributes: [NSAttributedString.Key.paragraphStyle: centeredParagraphStyle])
//        self.attributedPlaceholder = attributedPlaceholder
    }
    
    func getPadding(plusExtraFor clearButtonMode: ViewMode) -> UIEdgeInsets {
        var padding = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)
        
        // Add additional padding on the right side when showing the clear button
        if self.clearButtonMode == .always || self.clearButtonMode == clearButtonMode {
            padding.right = 28
        }
        
        return padding
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let padding = getPadding(plusExtraFor: .unlessEditing)
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let padding = getPadding(plusExtraFor: .unlessEditing)
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let padding = getPadding(plusExtraFor: .whileEditing)
        return bounds.inset(by: padding)
    }
}
