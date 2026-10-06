import Foundation

struct GeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    
    var paddingWidth: CGFloat {
        let sideInsets = leftInset + rightInset
        let interItemSpaces = cellSpacing * CGFloat(cellCount - 1)
        return sideInsets + interItemSpaces
    }
}
