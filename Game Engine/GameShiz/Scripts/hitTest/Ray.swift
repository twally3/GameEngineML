import simd

struct Ray {
    var origin: SIMD3<Float>
    var direction: SIMD3<Float>
    
    static func *(transform: float4x4, ray: Ray) -> Ray {
        let _originT = transform * SIMD4<Float>(ray.origin, 1)
        let originT = SIMD3<Float>(_originT.x, _originT.y, _originT.z)
        
        let _directionT = transform * SIMD4<Float>(ray.direction, 0)
        let directionT = SIMD3<Float>(_directionT.x, _directionT.y, _directionT.z)
        
        return Ray(origin: originT, direction: directionT)
    }
    
    func interpolate(_ point: SIMD4<Float>) -> Float {
        let _point = SIMD3<Float>(point.x, point.y, point.z)
        return length(_point - origin) / length(direction)
    }
}
