import simd
import MetalKit

class BoidManager {
    public var boids: [Boid] = []
    
    let spawnRadius: Float = 10
    let perceptionRadius: Float = 15
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
        
        let mapValuesBuffer = Engine.device!.makeBuffer(bytes: boidData,
                                                        length: MemoryLayout<BoidData>.size * boidData.count,
                                                        options: [])
                
        let computePipelineState = self.createComputePipelineState()
        
        let commandQueue = Engine.commandQueue
        let commandBuffer = commandQueue!.makeCommandBuffer()
        let computeCommandEncoder = commandBuffer?.makeComputeCommandEncoder()
        computeCommandEncoder?.setComputePipelineState(computePipelineState)

        computeCommandEncoder?.setBuffer(mapValuesBuffer, offset: 0, index: 0)
        
        var numBoids = boidData.count
        computeCommandEncoder?.setBytes(&numBoids, length: Int32.size, index: 1)
        
        var perceptionRadius = self.perceptionRadius
        computeCommandEncoder?.setBytes(&perceptionRadius, length: Float.size, index: 2)
        
        var avoidanceRadius = self.avoidanceRadius
        computeCommandEncoder?.setBytes(&avoidanceRadius, length: Float.size, index: 3)
        
        let gridSize = MTLSizeMake(numBoids, 1, 1)
        var threadGroupSize = computePipelineState.maxTotalThreadsPerThreadgroup
        if threadGroupSize > numBoids {
            threadGroupSize = numBoids;
        }
        let threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
        
        computeCommandEncoder?.dispatchThreads(gridSize, threadsPerThreadgroup: threadgroupSize)
        
        computeCommandEncoder?.endEncoding()
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
        
        let ptr = mapValuesBuffer?.contents().bindMemory(to: BoidData.self, capacity: numBoids)
        let floatBuffer = UnsafeBufferPointer(start: ptr, count: numBoids)
        let resultArrOut = Array(floatBuffer)
        
        for i in 0..<boids.count {
            boids[i].avgFlockHeading = resultArrOut[i].flockHeading;
            boids[i].centreOfFlockmates = resultArrOut[i].flockCentre;
            boids[i].avgAvoidanceHeading = resultArrOut[i].avoidanceHeading;
            boids[i].numPerceivedFlockmates = resultArrOut[i].numFlockmates;
            boids[i].updateBoid()
        }
    }
    
    private func createComputePipelineState() -> MTLComputePipelineState {
        do {
            return try Engine.device!.makeComputePipelineState(function: Graphics.shaders[.ComputeBoidPositions])
        } catch let error as NSError {
            fatalError(error.localizedDescription)
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
