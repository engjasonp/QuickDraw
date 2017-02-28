import UIKit

protocol SettingsVCDelegate: class {
    // To pass the RGBa values to DrawingViewController
    func settingsViewControllerDidFinish (_ settingsVC: SettingsVC)
}

class SettingsVC: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var brushSizeView: UIView!
    @IBOutlet weak var imageViewSliderDistance: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var brushSizeLabel: UILabel!
    @IBOutlet weak var opacity: UILabel!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var brushSizeSlider: UISlider!
    @IBOutlet weak var opacitySlider: UISlider!
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 1.0
    var brushSize: CGFloat!
    
    var delegate: SettingsVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        redSlider.value = Float(red)
        redLabel.text = String(Int(redSlider.value * 255))
        
        greenSlider.value = Float(green)
        greenLabel.text = String(Int(greenSlider.value * 255))
        
        blueSlider.value = Float(blue)
        blueLabel.text = String(Int(blueSlider.value * 255))
        
        // brushSize is not a value between 0 and 1, so divide by 50 (or whatever range you set for size)
        brushSizeSlider.value = Float(brushSize / 50)
        brushSizeLabel.text = String(Int(brushSizeSlider.value * 50))
        
        opacitySlider.value = Float(alpha)
        opacity.text = String(Int(opacitySlider.value * 100))
        
        imageView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 5.0
        imageView.layer.shadowOpacity = 1.0
        imageView.layer.shadowOffset = CGSize.zero
        imageView.layer.shadowRadius = 5
        imageView.layer.shadowColor = imageView.backgroundColor?.cgColor
        
        // Ask iOS to cache the rendered shadow so that it doesn't need to be redrawn:
        imageView.layer.shouldRasterize = true
        
        brushSizeView.frame = CGRect(
            x: view.frame.midX - (brushSize / 2.0),
            y: imageView.frame.maxY + ((imageViewSliderDistance.constant / 2.0) - (brushSize / 2.0)),
            width: brushSize,
            height: brushSize)
        brushSizeView.backgroundColor = UIColor.black
        brushSizeView.layer.cornerRadius = brushSizeView.frame.size.width / 2.0
        brushSizeView.layer.shouldRasterize = true
        
    }
    
    // Mark: Previews
    
    func drawPreview(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        imageView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func brushSizePreview(_ brushSize: CGFloat) {
        brushSizeView.frame = CGRect(
            x: view.frame.midX - (brushSize / 2.0),
            y: imageView.frame.maxY + ((imageViewSliderDistance.constant / 2.0) - (brushSize / 2.0)),
            width: brushSize,
            height: brushSize)
        brushSizeView.layer.cornerRadius = brushSizeView.frame.size.width / 2.0
    }

    // MARK: Actions
    
    @IBAction func brushSizeChanged(_ sender: UISlider) {
        brushSizeLabel.text = String(Int(brushSize))
        brushSize = CGFloat(sender.value * 50)
        brushSizePreview(brushSize)
    }
    
    @IBAction func opacityChanged(_ sender: UISlider) {
        opacity.text = String(Int(sender.value * 100))
        alpha = CGFloat(sender.value)
        imageView.layer.shadowColor = imageView.backgroundColor?.cgColor
        drawPreview(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    @IBAction func redSliderChanged(_ sender: UISlider) {
        redLabel.text = String(Int(sender.value * 255))
        red = CGFloat(sender.value)
        imageView.layer.shadowColor = imageView.backgroundColor?.cgColor
        drawPreview(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    @IBAction func greenSliderChanged(_ sender: UISlider) {
        greenLabel.text = String(Int(sender.value * 255))
        green = CGFloat(sender.value)
        imageView.layer.shadowColor = imageView.backgroundColor?.cgColor
        drawPreview(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    @IBAction func blueSliderChanged(_ sender: UISlider) {
        blueLabel.text = String(Int(sender.value * 255))
        blue = CGFloat(sender.value)
        imageView.layer.shadowColor = imageView.backgroundColor?.cgColor
        drawPreview(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        if delegate != nil {
            delegate?.settingsViewControllerDidFinish(self)
        }
        dismiss(animated: true, completion: nil)
    }

}
