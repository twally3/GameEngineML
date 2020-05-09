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
        
        if isHeadingForCollision() {            
            let dir = self.headingDir()
            let collisionForce = steerTowards(vector: dir) * 5
            
            acc += collisionForce
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
        let _v = normalize(vector)
        let _len = length(_v)
        let isBroke = _len == Float.nan || _len == -Float.nan
        
        let newV = isBroke ? SIMD3<Float>(0,0,0) : vector
        
        let v = newV * maxSpeed - vel
        
        let len = length(v)
        var multiplier: Float = 1
        if len > maxSteerForce {
            multiplier = maxSteerForce / len
        }
        return v * multiplier
    }
    
    func isHeadingForCollision() -> Bool {
        let dstThreshold: Float = 3
        
        if self.pos.x - dstThreshold < -self.bounds {
            return true
        } else if self.pos.x + dstThreshold > self.bounds {
            return true
        }
        
        if self.pos.y - dstThreshold < -self.bounds {
            return true
        } else if self.pos.y + dstThreshold > self.bounds {
            return true
        }
        
        if self.pos.z - dstThreshold < -self.bounds {
            return true
        } else if self.pos.z + dstThreshold > self.bounds {
            return true
        }
        
        return false
    }
    
    func headingDir() -> SIMD3<Float> {
        let dstThreshold: Float = 10
        var dir = SIMD3<Float>(0, 0, 0)
        
        if self.pos.x - dstThreshold < -self.bounds {
            dir.x = -self.pos.x
        } else if self.pos.x + dstThreshold > self.bounds {
            dir.x = -self.pos.x
        }

        if self.pos.y - dstThreshold < -self.bounds {
            dir.y = -self.pos.y
        } else if self.pos.y + dstThreshold > self.bounds {
            dir.y = -self.pos.y
        }

        if self.pos.z - dstThreshold < -self.bounds {
            dir.z = -self.pos.z
        } else if self.pos.z + dstThreshold > self.bounds {
            dir.z = -self.pos.z
        }
        
        return dir
    }
}
