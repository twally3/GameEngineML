import simd

class Boid: GameObject {
    let material = Material(colour: SIMD4<Float>(1,0,0,1),
                           isLit: true,
                           ambient: SIMD3<Float>(repeating: 0.3),
                           diffuse: SIMD3<Float>(repeating: 1),
                           specular: SIMD3<Float>(repeating: 0),
                           shininess: 0)
    
    let bounds: Float = 20
    let maxSpeed: Float = 50
    var perceptionRadius: Float
    let maxForce: Float = 15
        
    var pos: SIMD3<Float>
    var vel: SIMD3<Float>
    var acc: SIMD3<Float>
    
    init(perceptionRadius: Float) {
        self.perceptionRadius = perceptionRadius
        
        self.pos = SIMD3<Float>.random(in: ClosedRange(uncheckedBounds: (lower: -self.bounds, upper: self.bounds)))
        self.vel = normalize(SIMD3<Float>.random(in: 0..<1)) * self.maxSpeed
        self.acc = SIMD3<Float>(repeating: 0)
        
        super.init(name: "Boid", meshType: .Cube_Custom)
        
        useMaterial(material)
        setPosition(self.pos)
        setScale(SIMD3<Float>(repeating: 0.5))
    }
    
    func update(boids: [Boid]) {
        self.edges()
        
        self.flock(boids: boids)
        
        self.pos += self.vel * GameTime.deltaTime
        self.vel += length(self.acc) > self.maxSpeed ? normalize(self.acc) * self.maxSpeed : self.acc
    }
    
    override func doUpdate() {
        setPosition(self.pos)
    }
    
    public func flock(boids: [Boid]) {
        self.acc *= 0
        self.acc += align(boids: boids)
        self.acc += cohesion(boids: boids)
        self.acc += separation(boids: boids)
    }
    
    func align(boids: [Boid]) -> SIMD3<Float> {
        var steeringForce = SIMD3<Float>(repeating: 0)
        var totalConsideredBoids: Float = 0
        
        for boid in boids {
            if boid === self { continue }
            if abs(distance(self.pos, boid.pos)) >= self.perceptionRadius { continue }
            
            steeringForce += boid.vel
            totalConsideredBoids += 1
        }
                
        if totalConsideredBoids == 0 { return steeringForce }
        
        steeringForce /= totalConsideredBoids
        steeringForce = normalize(steeringForce) * self.maxSpeed
        steeringForce -= self.vel
        
        if length(steeringForce) > self.maxForce {
            steeringForce = normalize(steeringForce) * self.maxForce
        }
        
        return steeringForce
    }
    
    func cohesion(boids: [Boid]) -> SIMD3<Float> {
        var steeringForce = SIMD3<Float>(repeating: 0)
        var totalConsideredBoids: Float = 0
        
        for boid in boids {
            if boid === self { continue }
            if abs(distance(self.pos, boid.pos)) >= self.perceptionRadius { continue }
            
            steeringForce += boid.pos
            totalConsideredBoids += 1
        }
        
        if totalConsideredBoids == 0 { return steeringForce }
        
        steeringForce /= totalConsideredBoids
        steeringForce -= self.pos
        steeringForce = normalize(steeringForce) * self.maxSpeed
        steeringForce -= self.vel
        
        if length(steeringForce) > self.maxForce {
            steeringForce = normalize(steeringForce) * self.maxForce
        }
        
        return steeringForce
    }
    
    func separation(boids: [Boid]) -> SIMD3<Float> {
        var steeringForce = SIMD3<Float>(repeating: 0)
        var totalConsideredBoids: Float = 0
        
        for boid in boids {
            if boid === self { continue }
            let dist = abs(distance(self.pos, boid.pos))
            if dist >= self.perceptionRadius { continue }
            
            let difference = (self.pos - boid.pos) / dist
            
            steeringForce += difference
            totalConsideredBoids += 1
        }
        
        if totalConsideredBoids == 0 { return steeringForce }
        
        steeringForce /= totalConsideredBoids
        steeringForce = normalize(steeringForce) * self.maxSpeed
        steeringForce -= self.vel
        
        if length(steeringForce) > self.maxForce {
            steeringForce = normalize(steeringForce) * self.maxForce
        }
        
        return steeringForce
    }
    
    public func edges() {
        if self.pos.x < -self.bounds {
            self.pos.x = self.bounds
        } else if self.pos.x > self.bounds {
            self.pos.x = -self.bounds
        }
        
        if self.pos.y < -self.bounds {
            self.pos.y = self.bounds
        } else if self.pos.y > self.bounds {
            self.pos.y = -self.bounds
        }
        
        if self.pos.z < -self.bounds {
            self.pos.z = self.bounds
        } else if self.pos.z > self.bounds {
            self.pos.z = -self.bounds
        }
    }
}
