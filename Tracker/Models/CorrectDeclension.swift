import Foundation

extension Int {
    func formatDaysCount() -> String {
        let mod10 = self % 10
        let mod100 = self % 100
        
        if mod100 >= 11 && mod100 <= 14 {
            return "\(self) дней"
        }
        
        switch mod10 {
        case 1:
            return "\(self) день"
        case 2...4:
            return "\(self) дня"
        default:
            return "\(self) дней"
        }
    }
}
