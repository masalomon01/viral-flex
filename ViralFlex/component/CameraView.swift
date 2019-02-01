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

        let interval = Date().timeIntervalSince1970
        let name = "\(interval).jpg"
        let url = docUrl?.appendingPathComponent(name)
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
            
            imagePickerController.present(picker, animated: true, completion: {
                picker.delegate = self
            })
        }
    }
}
