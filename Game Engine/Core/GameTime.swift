import MetalKit

class GameTime {
    private static var _totalGameTime: Float = 0.0
    private static var _deltaTime: Float = 0.0
    
    public static func updateTime(_ deltaTime: Float) {
        self._deltaTime = deltaTime
        self._totalGameTime += deltaTime
    }
}

extension GameTime {
    public static var totalGameTime: Float {
        return self._totalGameTime
    }
    
    public static var deltaTime: Float {
        return self._deltaTime
    }
}
