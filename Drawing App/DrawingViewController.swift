import UIKit

class DrawingViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SettingsVCDelegate {

    // MARK: Properties
    

    @IBOutlet weak var tempImageView: UIImageView! // image is transferred to mainImageView
    @IBOutlet weak var mainImageView: UIImageView! // stores image
    @IBOutlet weak var toolIcon: UIButton!
    
    var lastPoint = CGPoint.zero
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 1.0
    var brushWidth: CGFloat = 5.0
    
    var tool: UIImageView!
    var isDrawing = true
    var swiped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tool = UIImageView()
        tool.frame = CGRect(x: self.view.bounds.width, y: self.view.bounds.height, width: 38, height: 38)
        tool.image = #imageLiteral(resourceName: "paintBrush")
        self.view.addSubview(tool)
    }
    
    //MARK: Touch Methods

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            //Save the location of last point touched.
            lastPoint = touch.location(in: self.view)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: self.view)
            drawLines(fromPoint: lastPoint, toPoint: currentPoint)
            
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLines(fromPoint: lastPoint, toPoint: lastPoint)
        }
        
        // If user didn't swipe and only touched,
        // Merge tempImageView into mainImageView to preserve opacity.
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.height), blendMode: CGBlendMode.normal, alpha: 1.0)
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.height), blendMode: CGBlendMode.normal, alpha: alpha)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    //MARK: Draw Method
    
    func drawLines(fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        
        let context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        
        tool.center = CGPoint(x: toPoint.x + 15, y: toPoint.y - 20)
        
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        context?.setStrokeColor(UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor)
        context?.strokePath()
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = alpha
        UIGraphicsEndImageContext()
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set imageView to display the selected image.
        self.tempImageView.image = selectedImage
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: SettingsVCDelegate Method
    func settingsViewControllerDidFinish(_ settingsVC: SettingsVC) {
        self.red = settingsVC.red
        self.green = settingsVC.green
        self.blue = settingsVC.blue
        self.alpha = settingsVC.alpha
        self.brushWidth = settingsVC.brushSize
    }
    
    //MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Pass in our data to SettingsVC (to show current selected color in drawPreview)
        let settingsVC = segue.destination as! SettingsVC
        settingsVC.delegate = self
        settingsVC.red = red
        settingsVC.green = green
        settingsVC.blue = blue
        settingsVC.alpha = alpha
        settingsVC.brushSize = brushWidth
    }
    
    //MARK: Actions
    
    @IBAction func colorsPicked(_ sender: UIButton) {
        switch (sender.tag) {
        case 0:
            (red, green, blue, alpha) = (1.0, 0.0, 0.0, alpha)
            break
        case 1:
            (red, green, blue, alpha) = (0.0, 1.0, 0.0, alpha)
            break
        case 2:
            (red, green, blue, alpha) = (0.0, 0.0, 1.0, alpha)
            break
        case 3:
            (red, green, blue, alpha) = (1.0, 0.0, 1.0, alpha)
            break
        case 4:
            (red, green, blue, alpha) = (1.0, 1.0, 0.0, alpha)
            break
        case 5:
            (red, green, blue, alpha) = (0.0, 1.0, 1.0, alpha)
            break
        case 6:
            (red, green, blue, alpha) = (1.0, 1.0, 1.0, alpha)
            break
        case 7:
            (red, green, blue, alpha) = (0.0, 0.0, 0.0, alpha)
            break
        default:
            (red, green, blue, alpha) = (0.0, 0.0, 0.0, alpha)
        }

    }
    
    @IBAction func reset(_ sender: UIButton) {
        self.mainImageView.image = nil
    }
    
    @IBAction func save(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Pick your option", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Pick an image", style: .default, handler: { (_) in
            
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Save your drawing", style: .default, handler: { (_) in
            if let image = self.tempImageView.image {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }}))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func erase(_ sender: UIButton) {
        if (isDrawing) {
            (red, green, blue) = (1, 1, 1)
            tool.image = #imageLiteral(resourceName: "EraserIcon")
            toolIcon.setImage(#imageLiteral(resourceName: "EraserIcon"), for: .normal)
        } else {
            (red, green, blue) = (0, 0, 0)
            tool.image = #imageLiteral(resourceName: "paintBrush")
            toolIcon.setImage(#imageLiteral(resourceName: "paintBrush"), for: .normal)
        }
        isDrawing = !isDrawing
    }

}
