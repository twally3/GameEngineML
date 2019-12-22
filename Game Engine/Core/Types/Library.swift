import MetalKit

class Library<T, K> {
    init() {
        fillLibrary()
    }
    
    func fillLibrary() {
        // Override this when filling a library with default values
    }
    
    subscript(_ type: T) -> K? {
        return nil
    }
}
