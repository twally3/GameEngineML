import simd

class Boid: GameObject {
    var pos: SIMD3<Float>
    var forward: SIMD3<Float>
    var vel: SIMD3<Float>
    
    var avgFlockHeading: SIMD3<Float> = SIMD3<Float>(repeating: 0)
    var centreOfFlockmates: SIMD3<Float> = SIMD3<Float>(repeating: 0)
    var avgAvoidanceHeading: SIMD3<Float> = SIMD3<Float>(repeating: 0)
    var numPerceivedFlockmates: Int = 0
    
    let maxSpeed: Float = 30
    let minSpeed: Float = 10
    let maxSteerForce: Float = 50
    
    let bounds: Float = 40
    
    init(pos: SIMD3<Float>, forward: SIMD3<Float>) {
        self.pos = pos
        self.forward = forward
        let startSpeed = (self.minSpeed + self.maxSpeed) / 2
        self.vel = forward * startSpeed;
        
        super.init(name: "Boid", meshType: .Cube_Custom)
        
        setPosition(pos)
        setRotation(forward)
    }
    
    func updateBoid() {
        var acc = SIMD3<Float>(repeating: 0)
                
        if numPerceivedFlockmates != 0 {
            centreOfFlockmates /= Float(numPerceivedFlockmates)
            
            let offsetToFlockmatesCentre = centreOfFlockmates - pos
            
            let alignmentForce = steerTowards(vector: avgFlockHeading)
            let cohesionForce = steerTowards(vector: offsetToFlockmatesCentre)
            let seperationForce = steerTowards(vector: avgAvoidanceHeading)
            
            acc += (alignmentForce + cohesionForce + seperationForce)
        }
        
        vel += acc * GameTime.deltaTime
        var speed: Float = length(vel)
        let dir = vel / speed
        speed = min(max(speed, self.minSpeed), self.maxSpeed)
        vel = dir * speed
        
        pos += vel * GameTime.deltaTime
        forward = dir
        
        setPosition(pos)
        setRotation(dir)
    }
    
    func steerTowards(vector: SIMD3<Float>) -> SIMD3<Float> {
        let v = normalize(vector) * maxSpeed - vel
        return clamp(v, min: 0, max: maxSteerForce)
    }
    
    override func doUpdate() {
        self.edges()
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
