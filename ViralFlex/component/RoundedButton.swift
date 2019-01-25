import UIKit

@IBDesignable class RoundedButton: UIButton
{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCornerRadius()
    }
    
    @IBInspectable var radius: Int = 0 {
        didSet { updateCornerRadius() }
    }
    
    @IBInspectable var border: CGFloat = 0 {
        didSet { updateCornerRadius() }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.black {
        didSet { updateCornerRadius() }
    }
    
    func updateCornerRadius() {
        layer.cornerRadius = CGFloat(radius)
        
        layer.borderWidth = border
        layer.borderColor = borderColor.cgColor
    }
}
