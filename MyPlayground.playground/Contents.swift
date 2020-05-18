//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

let cLabel:[ParameterIndex:String] = [
    ParameterIndex.Red:"R",
    ParameterIndex.Green:"G",
    ParameterIndex.Blue:"B",
    ParameterIndex.Hue:"H",
    ParameterIndex.Sat:"S",
    ParameterIndex.Value:"V",
    ParameterIndex.Alpha:"A"
]

let cColor:[ParameterIndex:UIColor] = [
    ParameterIndex.Red:.red,
    ParameterIndex.Green:.green,
    ParameterIndex.Blue:.blue,
    ParameterIndex.Hue:.black,
    ParameterIndex.Sat:.black,
    ParameterIndex.Value:.black,
    ParameterIndex.Alpha:.black
]


class MyViewController : UIViewController {
    
    var imgView:UIImageView! = nil
    var mainView:UIView! = nil
   
    
    var slider:[UISlider]! = []
    var fieldValue:[UITextField]! = []
    var value:[Float] = Array(repeatElement(0, count: 7))
    
    var hexField:UITextField! = nil

    var controlView:[UIView]! = []
    
    var selectedTextField : UITextField! = nil
        
    var controlLabel:[UILabel] = []
    var collectionArray:[String] = []
    var collectionName:[String] = []
    var selectedTabItemIndex:Int! = nil
    
    override func loadView() {
        mainView = UIView()
        mainView.frame = CGRect(x: 0, y: 0, width: 375, height: 668)
        mainView.backgroundColor = .white
        
        let baseFrame = CGRect(x: 20, y: 0, width: mainView.frame.width - 40, height: 0)
        
        let label = UILabel()
        label.frame = CGRect(x: 75, y: 10, width: 300, height: 50)
        label.text = "COLOR PICKER"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textColor = .black
        mainView.addSubview(label)
        
        imgView = UIImageView()
        imgView.frame = CGRect(x: baseFrame.minX, y: 70,
                               width: baseFrame.width, height: 207)
        imgView.backgroundColor = .green
        mainView.addSubview(imgView)
        
        hexField = UITextField()
        hexField.borderStyle = .roundedRect
        hexField.textAlignment = .center
        hexField.frame = CGRect(x: baseFrame.minX, y: 300, width: baseFrame.width, height: 34)
        mainView.addSubview(hexField)
        
        let controlFrame = UIView()
        controlFrame.frame = CGRect(x: baseFrame.minX, y: 340, width: baseFrame.width, height: 298)
        mainView.addSubview(controlFrame)
        
        let controlIndexCount:Int = value.count
        let hDist:Int = 40
        for x in 0 ..< controlIndexCount
        {
            let xLabel:UILabel = UILabel()
            xLabel.tag = x
            xLabel.frame = CGRect(x: 0, y: 8 + x * hDist, width: 40, height: 34)
            xLabel.textColor = cColor[ParameterIndex.init(rawValue: x)!]
            xLabel.text = cLabel[ParameterIndex.init(rawValue: x)!]
            controlFrame.addSubview(xLabel)
            controlLabel.append(xLabel)
            
            let xSlider:UISlider = UISlider()
            xSlider.minimumValue = 0
            xSlider.maximumValue = 1
            xSlider.isContinuous = true
            xSlider.tag = x
            xSlider.frame = CGRect(x: 33, y: 10 + x * hDist, width: 240, height: 31)
            xSlider.tintColor = cColor[ParameterIndex.init(rawValue: x)!]
            xSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
            controlFrame.addSubview(xSlider)
            slider.append(xSlider)
            
            let xValue:UITextField = UITextField()
            xValue.tag = x
            xValue.frame = CGRect(x: Int(baseFrame.width) - 50, y: 8 + x * hDist, width: 50, height: 34)
            xValue.borderStyle = .roundedRect
            xValue.textAlignment = .center
            controlFrame.addSubview(xValue)
            fieldValue.append(xValue)
        }
        
        self.view = mainView
    }

    override func viewDidLoad()
    {
        
        imgView.tintColor = .none;
        setup()
    }
    
    func setup()
    {
        collectionArray = (UserDefaults.standard.array(forKey: colorArrayKey) ?? []) as! [String]
        collectionName = (UserDefaults.standard.array(forKey: colorNameArrayKey) ?? []) as! [String]
        
        for i in 0...2
        {
            value[i] = Float.random(in: 0.0 ... 1.0)
            slider[i].value = value[i]
            fieldValue[i].text = "\(Int(roundf(value[i]*255)))"
        }
        
        value[ALPHA_INDEX] = Float.random(in: 0.4 ... 1.0)
        slider[ALPHA_INDEX].value = value[ALPHA_INDEX]
        fieldValue[ALPHA_INDEX].text = "\(Int(roundf((value[ALPHA_INDEX] )*100)))"
        
        changeBGColorRGB()
        

    }

    func changeBGColor(parameterType:ParameterIndex.RawValue)
    {
        
        switch parameterType {
            case ParameterIndex.Hue.rawValue,
                 ParameterIndex.Sat.rawValue,
                 ParameterIndex.Value.rawValue:
                changeBGColorHSV()
            default:
                changeBGColorRGB()
        }
    }
    
    func changeBGColorRGB()
    {
        
        let currentColor = UIColor(
            red: CGFloat(value[ParameterIndex.Red.rawValue]),
            green: CGFloat(value[ParameterIndex.Green.rawValue]),
            blue: CGFloat(value[ParameterIndex.Blue.rawValue]),
            alpha: CGFloat(value[ParameterIndex.Alpha.rawValue] )
        )
        
        imgView.backgroundColor = currentColor
        
        hexField.text = hexStringFromColor(color: currentColor)
                
        updateHSVSlider()
    }
    
    func updateHSVSlider()
    {
        var hue:CGFloat = 0
        var saturation:CGFloat = 0
        var brightness:CGFloat = 0
        var alphaCGFloat:CGFloat = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.imgView.backgroundColor?.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alphaCGFloat)
            
            self.value[ParameterIndex.Hue.rawValue] = Float(hue)
            self.value[ParameterIndex.Sat.rawValue] = Float(saturation)
            self.value[ParameterIndex.Value.rawValue] = Float(brightness)
        
            DispatchQueue.main.async {
                for i in ParameterIndex.Hue.rawValue...ParameterIndex.Value.rawValue
                {
                    self.slider[i].value = self.value[i]
                    if i == ParameterIndex.Hue.rawValue
                    {
                        let value = "\(Int(roundf(self.value[i] * 359)))"
                        if self.fieldValue[i].text != value
                        {
                            self.fieldValue[i].text = value
                        }
                    }
                    else
                    {
                        let value = "\(Int(roundf(self.value[i] * 100)))"
                        
                        if self.fieldValue[i].text != value
                        {
                            self.fieldValue[i].text = value
                        }
                    }
                }
                
                self.value[ALPHA_INDEX] = Float(alphaCGFloat)
                self.slider[ALPHA_INDEX].value = self.value[ALPHA_INDEX]
                
                let value = "\(Int(roundf((self.value[ALPHA_INDEX])*100)))"
                
                if self.fieldValue[ALPHA_INDEX].text != value
                {
                    self.fieldValue[ALPHA_INDEX].text = value
                }
                
            }
        }
        
        
    }
    
    func changeBGColorHSV()
    {
        imgView.backgroundColor = UIColor(
            hue: CGFloat(value[ParameterIndex.Hue.rawValue]),
            saturation: CGFloat(value[ParameterIndex.Sat.rawValue]),
            brightness: CGFloat(value[ParameterIndex.Value.rawValue]),
            alpha: CGFloat(value[ALPHA_INDEX])
        )

        let currentColor = UIColor(
            red: CGFloat(value[ParameterIndex.Red.rawValue]),
            green: CGFloat(value[ParameterIndex.Green.rawValue]),
            blue: CGFloat(value[ParameterIndex.Blue.rawValue]),
            alpha: CGFloat(value[ALPHA_INDEX])
        )
        let value = hexStringFromColor(color: currentColor)
        if hexField.text != value
        {
            hexField.text = value
        }
        
        
        updateRGBSlider()
    }
    
    func updateRGBSlider()
    {
        var red:CGFloat = 0
        var green:CGFloat = 0
        var blue:CGFloat = 0
        var alphaCGFloat:CGFloat = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.imgView.backgroundColor?.getRed(&red, green: &green, blue: &blue, alpha: &alphaCGFloat)
            
            self.value[ParameterIndex.Red.rawValue] = Float(red)
            self.value[ParameterIndex.Green.rawValue] = Float(green)
            self.value[ParameterIndex.Blue.rawValue] = Float(blue)
        
            DispatchQueue.main.async {
                for i in ParameterIndex.Red.rawValue...ParameterIndex.Blue.rawValue
                {
                    self.slider[i].value = self.value[i]
                    let value = "\(Int(roundf(self.value[i] * 255)))"
                    
                    if self.fieldValue[i].text != value
                    {
                       self.fieldValue[i].text = value
                    }
                }
                self.value[ALPHA_INDEX] = Float(alphaCGFloat)
                
                
                self.slider[ALPHA_INDEX].value = self.value[ALPHA_INDEX]
                
                let value = "\(Int(roundf((self.value[ALPHA_INDEX])*100)))"
                if self.fieldValue[ALPHA_INDEX].text != value
                {
                   self.fieldValue[ALPHA_INDEX].text = value
                }
            }
        }
        
        
        
    }
    
    @objc func sliderValueChanged(_ sender: UISlider)
    {
        let sliderValue = sender.value
        let sliderTAG = sender.tag
        value[sliderTAG] = sliderValue
        var parameterValue:Int = 0
        switch sliderTAG
        {
            case ParameterIndex.Alpha.rawValue,
                 ParameterIndex.Sat.rawValue,
                 ParameterIndex.Value.rawValue:
                parameterValue = 100
            case ParameterIndex.Hue.rawValue:
                parameterValue = 359

            default:
                parameterValue = 255
        }
        fieldValue[sliderTAG].text = "\(Int(roundf(sliderValue * Float(parameterValue))))"

        changeBGColor(parameterType:sliderTAG)
        
    }
    
    
    
}

extension MyViewController : UITextFieldDelegate
{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        selectedTextField = textField
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        return validInput(textField, inputCharacter: string)
    }
    
    func validInput(_ textField:UITextField, inputCharacter:String) -> Bool
    {
        if textField == hexField
        {
            if textField.text!.count == 1 && inputCharacter == "" {return false}
            if textField.text!.count == 9 && inputCharacter != "" {return false}
            if inputCharacter == "" {return true}
            let inputRegex = "[A-F0-9a-f]"
            let inputValidation = NSPredicate(format: "SELF MATCHES %@", inputRegex)
            let value = inputValidation.evaluate(with: inputCharacter)
            return value
        }
        else
        {
            if textField.text!.count == 3 && inputCharacter != "" {return false}
            if inputCharacter == "" {return true}
            
            let inputRegex = "[0-9]"
            let inputValidation = NSPredicate(format: "SELF MATCHES %@", inputRegex)
            let value = inputValidation.evaluate(with: inputCharacter)
            return value
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if textField != hexField
        {
            let textFieldTAG = textField.tag
            guard let stringValue = textField.text else { return false }
            let inputValue = (stringValue as NSString).intValue
            switch textFieldTAG
            {
                case ParameterIndex.Alpha.rawValue,
                     ParameterIndex.Sat.rawValue,
                     ParameterIndex.Value.rawValue:
                    let isMaxValue:Bool = (inputValue >= 100)
                    value[textFieldTAG] = isMaxValue ? 1.0 : Float(inputValue)/100.0
                    if isMaxValue {textField.text = "100"}
                case ParameterIndex.Hue.rawValue:
                    let isMaxValue:Bool = (inputValue >= 359)
                    value[textFieldTAG] = inputValue >= 359 ? 1.0 : Float(inputValue)/359
                    if isMaxValue {textField.text = "359"}
                default : // RGB
                    let isMaxValue:Bool = (inputValue >= 255)
                    value[textFieldTAG] = inputValue >= 255 ? 1.0 : Float(inputValue)/255
                    if isMaxValue {textField.text = "255"}
                
            }
            slider[textFieldTAG].value = value[textFieldTAG]
            
                        
            changeBGColor(parameterType:textFieldTAG)
        }
        else
        {
            let color = colorWithHexString(hexString: textField.text ?? "#000000FF")
            imgView.backgroundColor = color
            updateHSVSlider()
            updateRGBSlider()
        }
        
        textField.resignFirstResponder()
        
        return true
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
