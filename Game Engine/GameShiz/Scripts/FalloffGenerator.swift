import Foundation

class FalloffGenerator {
    static func generateFalloffMap(size: Int) -> [[Float]] {
        var map: [[Float]] = Array(repeating: Array(repeating: Float(0), count: size), count: size)
        
        for i in 0..<size {
            for j in 0..<size {
                let x = Float(i) / Float(size) * 2 - 1
                let y = Float(j) / Float(size) * 2 - 1
                
                let value = max(abs(x), abs(y))
                
                map[i][j] = self.evaluate(value)
            }
        }
        
        return map
    }
    
    static func evaluate(_ x: Float) -> Float {
        let a: Float = 3
        let b: Float = 2.2
        
        return pow(x, a) / (pow(x, a) + pow(b - b * x, a))
    }
}
