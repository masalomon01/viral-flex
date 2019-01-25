import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var imageCircle: UIImageView!
    @IBOutlet weak var buttonManualAdd: UIButton!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var alertController: UIAlertController!
    
    var previousViewController: UIViewController!
    var form: Form!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelTitle.text = form.name

        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        
        captureSession.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        
        updateCount()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BarcodePictureViewController {
            vc.form = self.form
        }
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//        captureSession.stopRunning()
        
        if (alertController != nil) {return}
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        //        dismiss(animated: true)
    }
    
    
    var okAction:UIAlertAction? = nil
    @IBAction func textFieldEditingDidChange(_ sender: UITextField) {
        okAction?.isEnabled = sender.text!.count>0
    }
    
    func found(code: String) {
        
        alertController = UIAlertController(title: "Your Barcode", message: "Keep barcode as it, edit the number, or discard this scan.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = code
            textField.keyboardType = .numberPad
            textField.addTarget(self, action: #selector(self.textFieldEditingDidChange(_:)), for: .editingChanged)
        }
        
        self.alertController?.addAction(UIAlertAction(title: "Keep", style: .default) { (action) in
            
            let textField = self.alertController.textFields![0] as UITextField
            self.form.barCodes.append(BarCode(code: textField.text!, time: Date()))
            
            self.updateCount()
            self.alertController = nil
        })
        self.alertController?.addAction(UIAlertAction(title: "Discard", style: .cancel) { (action) in self.alertController = nil})
        
        self.present(self.alertController!, animated: true)
    }
    
    func updateCount() {
        let barcodeCount = form.barCodes.count
        if barcodeCount > 0 {
            imageCircle.isHidden = false
            count.isHidden = false
            count.text = String(barcodeCount)
        }
        else {
            imageCircle.isHidden = true
            count.isHidden = true
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func onCancelClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDoneClick(_ sender: Any) {
        
        if (previousViewController is NewFormViewController) {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "newFormViewController") {
                
                (controller as! NewFormViewController).form = form
                previousViewController.dismiss(animated: false, completion: nil)
                previousViewController.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onManualAddClick(_ sender: Any) {
        found(code: "")
    }
    
    @IBAction func onViewClick(_ sender: Any) {
        
    }
}
