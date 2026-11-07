import Foundation

final class StorageModel {
    static let shared = StorageModel()
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    
    var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: hasSeenOnboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasSeenOnboardingKey) }
    }
    
    private init() {}
}
