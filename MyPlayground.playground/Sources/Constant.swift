import Foundation

public enum ParameterIndex : Int
{
    case Red = 0
    case Green = 1
    case Blue = 2
    case Hue = 3
    case Sat = 4
    case Value = 5
    case Alpha = 6
}

public let ALPHA_INDEX:Int = ParameterIndex.Alpha.rawValue

public let colorArrayKey:String = "collectionArray"
public let colorNameArrayKey:String = "collectionNameArray"

