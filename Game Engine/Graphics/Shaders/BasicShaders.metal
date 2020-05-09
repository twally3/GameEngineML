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

struct BoidData {
    float3 position;
    float3 direction;
    float3 flockHeading;
    float3 flockCentre;
    float3 avoidanceHeading;
    int numFlockmates;
};

kernel void compute_boid_positions(device BoidData *boidData [[ buffer(0) ]],
                                   constant int &numBoids [[ buffer(1) ]],
                                   constant float &viewRadius [[ buffer(2) ]],
                                   constant float &avoidanceRadius [[ buffer(3) ]],
                                   uint boidIdx [[thread_position_in_grid]]) {
    for (int i = 0; i < numBoids; i++) {
        if (((int)boidIdx) == i) { continue; }
        
        BoidData boidB = boidData[i];
        float3 offset = boidB.position - boidData[boidIdx].position;
        float sqrDst = offset.x * offset.x + offset.y * offset.y + offset.z * offset.z;
        
        if (sqrDst < viewRadius * viewRadius) {
            boidData[boidIdx].numFlockmates += 1;
            boidData[boidIdx].flockHeading += boidB.direction;
            boidData[boidIdx].flockCentre += boidB.position;
            
            if (sqrDst < avoidanceRadius * avoidanceRadius) {
                boidData[boidIdx].avoidanceHeading -= offset / sqrDst;
            }
        }
    }
}
