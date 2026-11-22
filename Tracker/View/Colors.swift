import UIKit

final class Colors{
    let viewBackground = UIColor {
        (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .dark {
            return UIColor.blackDay
        }else{
            return UIColor.white
        }
    }
    let headerColor = UIColor {
        (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .dark{
            return UIColor.white
        }else{
            return UIColor.black
        }
    }
    let textFieldBackground = UIColor {
        (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .dark{
            return UIColor.textFieldBackground
        }else{
            return UIColor.color
        }
    }
    
    let textField = UIColor {
        (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .dark{
            return UIColor.whiteDay
        }else{
            return UIColor.black
        }
    }
    let datePickerColor = UIColor {
        (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .dark{
            return UIColor.white
        }else{
            return UIColor.date
        }
    }
    let categoryLabelColor = UIColor {
        (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .dark{
            return UIColor.blackDay
        }else{
            return UIColor.white
        }
    }
    let categoryColor = UIColor {
        (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .dark{
            return UIColor.white
        }else{
            return UIColor.blackDay

        }
    }
    let underCategoryColor = UIColor {
        (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .dark{
            return UIColor.backgroundDay
        }else{
            return UIColor.blackDay

        }
    }
}
