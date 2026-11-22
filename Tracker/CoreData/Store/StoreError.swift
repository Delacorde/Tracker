enum StoreError: Error {
    case decodingError
    case encodingError
    case contextSaveError
    case failedToInitializeContext
    case failedToInitializeTrackerProvider
}
