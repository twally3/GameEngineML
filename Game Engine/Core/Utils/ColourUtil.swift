import simd

class ColourUtil {
    public static var randomColour: SIMD4<Float> {
        return SIMD4<Float>(Float.randomZeroToOne, Float.randomZeroToOne, Float.randomZeroToOne, 1.0)
    }
}
