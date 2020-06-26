import MetalKit

enum ClearColours {
    static let White = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let Green = MTLClearColor(red: 0.22, green: 0.55, blue: 0.34, alpha: 1.0)
    static let Grey = MTLClearColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    static let DarkGrey = MTLClearColor(red: 0.01, green: 0.01, blue: 0.01, alpha: 1.0)
    static let Black = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
    static let LimeGreen = MTLClearColor(red: 0.3, green: 0.7, blue: 0.3, alpha: 1)
}

class Preferences {
    public static var clearColour: MTLClearColor = ClearColours.DarkGrey
    
    public static var mainPixelFormat: MTLPixelFormat = MTLPixelFormat.bgra8Unorm
    
    public static var mainDepthPixelFormat: MTLPixelFormat = MTLPixelFormat.depth32Float
    
    public static var startingSceneType: SceneTypes = .Sandbox
}
