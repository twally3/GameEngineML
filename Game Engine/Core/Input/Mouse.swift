enum MOUSE_BUTTON_CODES: Int {
    case LEFT = 0
    case RIGHT = 1
    case CENTER = 2
}

class Mouse {
    
    private static var MOUSE_BUTTON_COUNT = 12
    private static var mouseButtonList = [Bool].init(repeating: false, count: MOUSE_BUTTON_COUNT)
    
    private static var overallMousePosition = SIMD2<Float>(repeating: 0)
    private static var mousePositionDelta = SIMD2<Float>(repeating: 0)
    
    private static var scrollWheelPosition: Float = 0.0
    private static var lastWheelPosition: Float = 0.0
    private static var scrollWheelChange: Float = 0.0
    
    public static func setMouseButtonPressed(button: Int, isOn: Bool) {
        mouseButtonList[button] = isOn
    }
    
    public static func isMouseButtonPressed(button: MOUSE_BUTTON_CODES) -> Bool {
        return mouseButtonList[button.rawValue]
    }
    
    public static func setOverallMousePosition(position: SIMD2<Float>) {
        self.overallMousePosition = position
    }
    
    public static func setMousePositionChange(overallPosition: SIMD2<Float>, deltaPosition: SIMD2<Float>) {
        self.overallMousePosition = overallPosition
        self.mousePositionDelta += deltaPosition
    }
    
    public static func scrollMouse(deltaY: Float) {
        scrollWheelPosition += deltaY
        scrollWheelChange += deltaY
    }
    
    public static func getMouseWindowPosition() -> SIMD2<Float> {
        return overallMousePosition
    }
    
    public static func getDWheel() -> Float {
        let position = scrollWheelChange
        scrollWheelChange = 0
        return position
    }
    
    public static func getDY() -> Float {
        let result = mousePositionDelta.y
        mousePositionDelta.y = 0
        return result
    }
    
    public static func getDX() -> Float {
        let result = mousePositionDelta.x
        mousePositionDelta.x = 0
        return result
    }
    
    public static func GetMouseViewportPosition() -> SIMD2<Float> {
        let x = (overallMousePosition.x - Renderer.screenSize.x * 0.5) / (Renderer.screenSize.x * 0.5)
        let y = (overallMousePosition.y - Renderer.screenSize.y * 0.5) / (Renderer.screenSize.y * 0.5)
        return SIMD2<Float>(x, y)
    }
    
}
