import MetalKit

public var X_AXIS: SIMD3<Float> {
    return SIMD3<Float>(1,0,0)
}

public var Y_AXIS: SIMD3<Float> {
    return SIMD3<Float>(0,1,0)
}

public var Z_AXIS: SIMD3<Float> {
    return SIMD3<Float>(0,0,1)
}

extension matrix_float4x4 {
    
    mutating func translate(direction: SIMD3<Float>) {
        var result = matrix_identity_float4x4
        
        let x: Float = direction.x
        let y: Float = direction.y
        let z: Float = direction.z
        
        result.columns = (
            SIMD4<Float>(1,0,0,0),
            SIMD4<Float>(0,1,0,0),
            SIMD4<Float>(0,0,1,0),
            SIMD4<Float>(x,y,z,1)
        )
        
        self = matrix_multiply(self, result)
    }
    
    mutating func scale(axis: SIMD3<Float>) {
        var result = matrix_identity_float4x4
        
        let x: Float = axis.x
        let y: Float = axis.y
        let z: Float = axis.z
        
        result.columns = (
            SIMD4<Float>(x,0,0,0),
            SIMD4<Float>(0,y,0,0),
            SIMD4<Float>(0,0,z,0),
            SIMD4<Float>(0,0,0,1)
        )
        
        self = matrix_multiply(self, result)
    }
    
    mutating func rotate(angle: Float, axis: SIMD3<Float>) {
        var result = matrix_identity_float4x4
        
        let x: Float = axis.x
        let y: Float = axis.y
        let z: Float = axis.z
        
        let c: Float = cos(angle)
        let s: Float = sin(angle)
        
        let mc: Float = (1 - c)
        
        let r1c1: Float = x * x * mc + c
        let r2c1: Float = x * y * mc + z * s
        let r3c1: Float = x * z * mc - y * s
        
        let r1c2: Float = y * x * mc - z * s
        let r2c2: Float = y * y * mc + c
        let r3c2: Float = y * z * mc + x * s
        
        let r1c3: Float = z * x * mc + y * s
        let r2c3: Float = z * y * mc - x * s
        let r3c3: Float = z * z * mc + c
        
        result.columns = (
            SIMD4<Float>(r1c1, r2c1, r3c1, 0.0),
            SIMD4<Float>(r1c2, r2c2, r3c2, 0.0),
            SIMD4<Float>(r1c3, r2c3, r3c3, 0.0),
            SIMD4<Float>(0.0,  0.0,  0.0,  1.0)
        )
        
        self = matrix_multiply(self, result)
    }
}
