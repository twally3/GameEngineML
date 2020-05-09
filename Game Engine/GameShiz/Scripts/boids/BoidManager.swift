import simd
import MetalKit

class BoidManager {
    public var boids: [Boid] = []
    
    let spawnRadius: Float = 10
    let perceptionRadius: Float = 10
    let avoidanceRadius: Float = 1
    
    init() {
        for _ in 0..<50 {
            let position = normalize(SIMD3<Float>.random(in: -1...1)) * spawnRadius
            let forward = normalize(SIMD3<Float>.random(in: -1...1))
            
            let boid = Boid(pos: position, forward: forward)
            boids.append(boid)
        }
    }
    
    func update() {
        var boidData: [BoidData] = []

        for boid in boids {
            let bd = BoidData(position: boid.pos, direction: boid.forward)
            boidData.append(bd)
        }
        
        for i in 0..<boids.count {
            calc(boidIdx: i, boidData: &boidData, viewRadius: perceptionRadius, avoidanceRadius: avoidanceRadius)
        }
        
        for i in 0..<boids.count {
            boids[i].avgFlockHeading = boidData[i].flockHeading;
            boids[i].centreOfFlockmates = boidData[i].flockCentre;
            boids[i].avgAvoidanceHeading = boidData[i].avoidanceHeading;
            boids[i].numPerceivedFlockmates = boidData[i].numFlockmates;
            boids[i].updateBoid()
        }
    }
    
    func calc(boidIdx: Int, boidData: inout [BoidData], viewRadius: Float, avoidanceRadius: Float) {
        for i in 0..<boidData.count {
            if boidIdx == i { continue }
            
            let boidB = boidData[i]
            let offset = boidB.position  - boidData[boidIdx].position
            let sqrDst = offset.x * offset.x + offset.y * offset.y + offset.z * offset.z
            
            if sqrDst < viewRadius * viewRadius {
                boidData[boidIdx].numFlockmates += 1
                boidData[boidIdx].flockHeading += boidB.direction
                boidData[boidIdx].flockCentre += boidB.position
                
                if sqrDst > avoidanceRadius * avoidanceRadius { continue }
                
                boidData[boidIdx].avoidanceHeading -= offset / sqrDst
            }
        }
    }
}

public struct BoidData {
    var position: SIMD3<Float>
    var direction: SIMD3<Float>

    var flockHeading: SIMD3<Float> = SIMD3<Float>(repeating: 0)
    var flockCentre: SIMD3<Float> = SIMD3<Float>(repeating: 0)
    var avoidanceHeading: SIMD3<Float> = SIMD3<Float>(repeating: 0)
    var numFlockmates: Int = 0
}
