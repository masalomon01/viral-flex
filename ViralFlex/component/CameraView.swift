import UIKit

class CameraView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var countCircle: UIImageView!
    @IBOutlet weak var count: UILabel!
    
    var controller: NewFormViewController!
    var imagePickerController: UIImagePickerController!
    var form: Form!
    var photoArray: [String] = []
    
    
//    override func awakeFromNib() {
//        updateCount()
//    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
        
        
        let fileManager = FileManager.default
        let docUrls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let docUrl = docUrls.first
        //檔名
        let interval = Date.timeIntervalSinceReferenceDate
        let name = "\(interval).jpg"
        let url = docUrl?.appendingPathComponent(name)
        //把圖片存在APP裡
        let data = image.jpegData(compressionQuality: 0.9)
        try! data?.write(to: url!)
        
        form.pictures.append((url?.path)!)
        

        imagePickerController.dismiss(animated: false, completion: nil)
        controller.showCamera(false)
    }
    
    @IBAction func onDoneClick(_ sender: Any) {
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onViewClick(_ sender: Any) {
        
        if let barcodePictureViewController = controller.storyboard?.instantiateViewController(withIdentifier: "barcodePictureViewController") {
            (barcodePictureViewController as! BarcodePictureViewController).form = controller.form
            imagePickerController.present(barcodePictureViewController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func onPickClick(_ sender: Any) {
        showPicker()
    }
    
//    func updateCount() {
////        countCircle.isHidden = form.pictures.count > 0
////        count.isHidden = form.pictures.count > 0
////        count.text = String(form.pictures.count)
//    }
    
    func showPicker() {
        
        let picker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
//            picker.allowsEditing = true // 可對照片作編輯
            //                picker.showsCameraControls = false
            
//            let myView = Bundle.main.loadNibNamed("CameraView", owner: nil, options: nil)?.first as? CameraView
//
//
//            let window = UIApplication.shared.keyWindow!
//
//            myView?.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height - 50)
            
            
            imagePickerController.present(picker, animated: true, completion: {
//                myView?.controller = self.controller
//                myView?.imagePickerController = picker
                picker.delegate = self
//                picker.cameraOverlayView = myView
            })
        }
    }
    
    
//    @IBAction func onPhotoLibraryClick(_ sender: Any) {
//
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
//            imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
//
//            imagePickerController.navigationBar.topItem!.rightBarButtonItem?.tintColor = UIColor.black
//
//            imagePickerController.allowsEditing = true
//            //            imagePickerController.delegate = self
//            //            controller.present(imagePickerController, animated: true, completion: nil)
//        }
//    }

}
