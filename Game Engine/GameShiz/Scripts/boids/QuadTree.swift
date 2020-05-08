class QuadTree {
    var points: [Node] = []
    
    var frontnorthwest: QuadTree?
    var frontnortheast: QuadTree?
    var frontsouthwest: QuadTree?
    var frontsoutheast: QuadTree?
    var backnorthwest: QuadTree?
    var backnortheast: QuadTree?
    var backsouthwest: QuadTree?
    var backsoutheast: QuadTree?
    
    var capacity: Int
    var boundary: Boundary
    
    init(capacity: Int, boundary: Boundary) {
        self.capacity = capacity
        self.boundary = boundary
    }
    
    func insert(node: Node) -> Bool {
        if !self.boundary.containsPoint(point: node.getPosition()) { return false }

        if self.points.count < self.capacity && self.frontnorthwest !== nil {
            self.points.append(node)
            return true
        }
        
        if self.frontnorthwest === nil { self.subdivide() }
        
        if self.frontnorthwest!.insert(node: node) { return true }
        if self.frontnortheast!.insert(node: node) { return true }
        if self.frontsouthwest!.insert(node: node) { return true }
        if self.frontsoutheast!.insert(node: node) { return true }
        if self.backnorthwest!.insert(node: node) { return true }
        if self.backnortheast!.insert(node: node) { return true }
        if self.backsouthwest!.insert(node: node) { return true }
        if self.backsoutheast!.insert(node: node) { return true }

        return false;
    }
    
    func queryRange(boundary: Boundary) -> [Node] {
        var pointsInRange: [Node] = []
        
        if (!self.boundary.intersectsBoundary(boundary: self.boundary)) { return pointsInRange }
        
        for point in self.points {
            if (self.boundary.containsPoint(point: point.getPosition())) {
                pointsInRange.append(point)
            }
        }
        
        if self.frontnorthwest === nil { return pointsInRange }
        
        pointsInRange.append(contentsOf: self.frontnorthwest!.queryRange(boundary: boundary))
        pointsInRange.append(contentsOf: self.frontnortheast!.queryRange(boundary: boundary))
        pointsInRange.append(contentsOf: self.frontsouthwest!.queryRange(boundary: boundary))
        pointsInRange.append(contentsOf: self.frontsoutheast!.queryRange(boundary: boundary))
        pointsInRange.append(contentsOf: self.backnorthwest!.queryRange(boundary: boundary))
        pointsInRange.append(contentsOf: self.backnortheast!.queryRange(boundary: boundary))
        pointsInRange.append(contentsOf: self.backsouthwest!.queryRange(boundary: boundary))
        pointsInRange.append(contentsOf: self.backsoutheast!.queryRange(boundary: boundary))

        return pointsInRange
    }
    
    func subdivide() {
        self.frontnorthwest = QuadTree(
            capacity: self.capacity,
            boundary: Boundary(
                pos: SIMD3<Float>(
                    self.boundary.pos.x,
                    self.boundary.pos.y,
                    self.boundary.pos.z
                ),
                size: self.boundary.size / 2
            )
        )
        
        self.frontnortheast = QuadTree(
            capacity: self.capacity,
            boundary: Boundary(
                pos: SIMD3<Float>(
                    self.boundary.pos.x + self.boundary.size.x / 2,
                    self.boundary.pos.y,
                    self.boundary.pos.z
                ),
                size: self.boundary.size / 2
            )
        )
        
        self.frontsouthwest = QuadTree(
            capacity: self.capacity,
            boundary: Boundary(
                pos: SIMD3<Float>(
                    self.boundary.pos.x,
                    self.boundary.pos.y + self.boundary.size.y / 2,
                    self.boundary.pos.z
                ),
                size: self.boundary.size / 2
            )
        )
        
        self.frontsoutheast = QuadTree(
            capacity: self.capacity,
            boundary: Boundary(
                pos: SIMD3<Float>(
                    self.boundary.pos.x + self.boundary.size.x / 2,
                    self.boundary.pos.y + self.boundary.size.y / 2,
                    self.boundary.pos.z
                ),
                size: self.boundary.size / 2
            )
        )

        // --
        
        self.backnorthwest = QuadTree(
            capacity: self.capacity,
            boundary: Boundary(
                pos: SIMD3<Float>(
                    self.boundary.pos.x,
                    self.boundary.pos.y,
                    self.boundary.pos.z + self.boundary.size.z / 2
                ),
                size: self.boundary.size / 2
            )
        )
        
        self.backnortheast = QuadTree(
            capacity: self.capacity,
            boundary: Boundary(
                pos: SIMD3<Float>(
                    self.boundary.pos.x + self.boundary.size.x / 2,
                    self.boundary.pos.y,
                    self.boundary.pos.z + self.boundary.size.z / 2
                ),
                size: self.boundary.size / 2
            )
        )
        
        self.backsouthwest = QuadTree(
            capacity: self.capacity,
            boundary: Boundary(
                pos: SIMD3<Float>(
                    self.boundary.pos.x,
                    self.boundary.pos.y + self.boundary.size.y / 2,
                    self.boundary.pos.z + self.boundary.size.z / 2
                ),
                size: self.boundary.size / 2
            )
        )
        
        self.backsoutheast = QuadTree(
            capacity: self.capacity,
            boundary: Boundary(
                pos: SIMD3<Float>(
                    self.boundary.pos.x + self.boundary.size.x / 2,
                    self.boundary.pos.y + self.boundary.size.y / 2,
                    self.boundary.pos.z + self.boundary.size.z / 2
                ),
                size: self.boundary.size / 2
            )
        )
    }
}
