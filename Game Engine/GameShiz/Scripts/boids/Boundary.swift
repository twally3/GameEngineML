class Boundary {
    public var pos: SIMD3<Float>
    public var size: SIMD3<Float>
    
    init(pos: SIMD3<Float>, size: SIMD3<Float>) {
        self.pos = pos
        self.size = size
    }
    
    func containsPoint(point: SIMD3<Float>) -> Bool {
        return (point.x >= self.pos.x &&
                point.x < self.pos.x + self.size.x &&
                point.y >= self.pos.y &&
                point.y < self.pos.y + self.size.y &&
                point.z >= self.pos.z &&
                point.z < self.pos.z + self.size.z)
    }
    
    func intersectsBoundary(boundary: Boundary) -> Bool {
        return !(
            boundary.pos.x - boundary.size.x > self.pos.x + self.size.x ||
            boundary.pos.x + boundary.size.x < self.pos.x - self.size.x ||
            boundary.pos.y - boundary.size.y > self.pos.y + self.size.y ||
            boundary.pos.y + boundary.size.y < self.pos.y - self.size.y ||
            boundary.pos.z - boundary.size.z > self.pos.z + self.size.z ||
            boundary.pos.z + boundary.size.z < self.pos.z - self.size.z
        );
    }
}
