import simd
import MetalKit

class BoidManager: InstancedGameObject {
    let spawnRadius: Float = 10
    let perceptionRadius: Float = 15
    let avoidanceRadius: Float = 10
    let boidCount: Int = 50
    
    init() {
        super.init(meshType: .Cube_Custom, instanceCount: boidCount, generateNodes: false)
        for _ in 0..<boidCount {
            let position = normalize(SIMD3<Float>.random(in: -1...1)) * spawnRadius
            let forward = normalize(SIMD3<Float>.random(in: -1...1))
            
            let boid = Boid(pos: position, forward: forward)
            _nodes.append(boid)
        }
        
        var material = Material()
        material.colour = SIMD4<Float>(0,0,0,1)
        material.isLit = true
        useMaterial(material)
    }
    
    func updateBoids() {
//    override func doUpdate() {
        var boidData: [BoidData] = []

        for boid in _nodes as! [Boid] {
            let bd = BoidData(position: boid.pos, direction: boid.forward)
            boidData.append(bd)
        }
        
        let mapValuesBuffer = Engine.device!.makeBuffer(bytes: boidData,
                                                        length: MemoryLayout<BoidData>.stride * boidData.count,
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
        
        for i in 0..<_nodes.count {
            (_nodes as! [Boid])[i].avgFlockHeading = resultArrOut[i].flockHeading;
            (_nodes as! [Boid])[i].centreOfFlockmates = resultArrOut[i].flockCentre;
            (_nodes as! [Boid])[i].avgAvoidanceHeading = resultArrOut[i].avoidanceHeading;
            (_nodes as! [Boid])[i].numPerceivedFlockmates = resultArrOut[i].numFlockmates;
            (_nodes as! [Boid])[i].updateBoid()
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
