#include <metal_stdlib>
#include "Lighting.metal"
#include "Shared.metal"
using namespace metal;

vertex RasterizerData basic_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                          constant SceneConstants &sceneConstants [[ buffer(1) ]],
                                          constant ModelConstants &modelConstants [[ buffer(2) ]]) {
    
//    float4 plane = float4(0, -1, 0, 50);
    float4 plane = sceneConstants.clippingPlane;
    
    RasterizerData rd;
    
    float4 worldPosition = modelConstants.modelMatrix * float4(vIn.position, 1);
    
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
    rd.colour = vIn.colour;
    rd.textureCoordinate = vIn.textureCoordinate;
    rd.worldPosition = worldPosition.xyz;
    rd.surfaceNormal = (modelConstants.modelMatrix * float4(vIn.normal, 0.0)).xyz;
    rd.toCameraVector = sceneConstants.cameraPosition - worldPosition.xyz;
    rd.clipDistance = dot(worldPosition, plane);
    
    return rd;
}

fragment half4 basic_fragment_shader(RasterizerData rd [[ stage_in ]],
                                     constant Material &material [[ buffer(1) ]],
                                     constant int &lightCount [[ buffer(2) ]],
                                     constant LightData *lightDatas [[ buffer(3)]],
                                     sampler sampler2d [[ sampler(0) ]],
                                     texture2d<float> baseColourMap [[ texture(0) ]]) {
    
    float2 textCoord = rd.textureCoordinate;
    
    float4 colour = material.colour;
    if (!is_null_texture(baseColourMap)) {
        colour = baseColourMap.sample(sampler2d, textCoord);
    }
    
    if (material.isLit) {
        float3 unitNormal = normalize(rd.surfaceNormal);
        float3 unitToCameraVector = normalize(rd.toCameraVector);
        
//        float3 phongIntensity = totalAmbient + totalDiffuse + totalSpecular;
        float3 phongIntensity = Lighting::getPhongIntensity(material, lightDatas, lightCount, rd.worldPosition, unitNormal, unitToCameraVector);
        colour *= float4(phongIntensity, 1.0);
    }
    
    return half4(colour.r, colour.g, colour.b, colour.a);
}

//public struct BoidData {
//    var position: SIMD3<Float>
//    var direction: SIMD3<Float>
//
//    var flockHeading: SIMD3<Float> = SIMD3<Float>(repeating: 0)
//    var flockCentre: SIMD3<Float> = SIMD3<Float>(repeating: 0)
//    var avoidanceHeading: SIMD3<Float> = SIMD3<Float>(repeating: 0)
//    var numFlockmates: Int = 0
//}

struct BoidData {
    float3 position;
    float3 direction;
    float3 flockHeading;
    float3 flockCentre;
    float3 avoidanceHeading;
    int numFlockmates;
};

kernel void compute_boid_positions(constant BoidData *boidData [[ buffer(0) ]],
                                   constant int &numBoids [[ buffer(1) ]],
                                   device float* result [[ buffer(2) ]],
                                   uint boidIdx [[thread_position_in_grid]]) {
    for (int i = 0; i < numBoids; i++) {
        result[i] = i;
    }
}

//kernel void compute_boid_positions(constant BoidData *boidData [[ buffer(0) ]],
//                                   constant int &numBoids [[ buffer(1) ]],
//                                   device float* result [[ buffer(2) ]],
//                                   uint boidIdx [[thread_position_in_grid]]) {
//    for (int i = 0; i < numBoids; i++) {
//        result[i] = i;
//    }
//}

//kernel void compute_boid_positions(texture2d<float, access::write> outputTexture [[texture(0)]],
//                                   constant float *heights [[ buffer(0) ]],
//                                   constant TerrainType *regions [[ buffer(1) ]],
//                                   constant int &regionCount [[ buffer(2) ]],
//                                   uint2 position [[thread_position_in_grid]]) {
//    float heightValue = heights[position.y * outputTexture.get_width() + position.x];
//
//    float4 heightColour = float4(0.0, 0.0, 0.0, 1.0);
//    for (int i = 0; i < regionCount; i++) {
//        if (heightValue >= regions[i].height) {
//            heightColour = regions[i].colour;
//        } else {
//            break;
//        }
//    }
//
//    outputTexture.write(heightColour, position);
//}
