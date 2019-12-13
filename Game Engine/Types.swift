import simd

protocol sizeable {
    static func size(_ count: Int) -> Int
    static func stride(_ count: Int) -> Int
}

extension sizeable {
    static func size() -> Int {
        return MemoryLayout<Self>.size
    }
    
    static func stride() -> Int {
        return MemoryLayout<Self>.stride
    }
    
    static func size(_ count: Int) -> Int {
        return MemoryLayout<Self>.size * count
    }
    
    static func stride(_ count: Int) -> Int {
        return MemoryLayout<Self>.stride * count
    }
}

struct Vertex: sizeable {
    var position: SIMD3<Float>
    var colour: SIMD4<Float>
}

extension SIMD3: sizeable where Scalar == Float {}
