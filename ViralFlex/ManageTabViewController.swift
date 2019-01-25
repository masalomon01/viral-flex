import UIKit

class ManageTabViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = self.tabBar
        let color = UIColor(red: 31/255, green: 32/255, blue: 107/255, alpha: 1)
        tabBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: color, size: CGSize(width: tabBar.frame.width/CGFloat(tabBar.items!.count), height: tabBar.frame.height), lineHeight: 5.0)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 14)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 14)!], for: .selected)
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        self.tabBar.invalidateIntrinsicContentSize();
        let tabSize: CGFloat = 50.0
        
        var tabFrame = self.tabBar.frame;
        tabFrame.size.height = tabSize;
        tabFrame.origin.y = self.view.frame.origin.y;
        self.tabBar.frame = tabFrame;
        self.tabBar.isTranslucent = false;
        self.tabBar.isTranslucent = true;
    }
}


extension UIImage {
    func createSelectionIndicator(color: UIColor, size: CGSize, lineHeight: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint(x: 0,y :size.height - lineHeight), size: CGSize(width: size.width, height: lineHeight)))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
