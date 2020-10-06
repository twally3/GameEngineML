#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

vertex RasterizerData instanced_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                              constant SceneConstants &sceneConstants [[ buffer(1) ]],
                                              constant ModelConstants *modelConstants [[ buffer(2) ]],
                                              uint instanceId [[ instance_id ]]) {
    RasterizerData rd;
    
    ModelConstants modelConstant = modelConstants[instanceId];
    
    float4 worldPosition = modelConstant.modelMatrix * float4(vIn.position, 1);
    
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
    rd.colour = vIn.colour;
    rd.textureCoordinate = vIn.textureCoordinate;
    rd.worldPosition = worldPosition.xyz;
    rd.toCameraVector = sceneConstants.cameraPosition - worldPosition.xyz;
    
    rd.surfaceNormal = normalize(modelConstant.modelMatrix * float4(vIn.normal, 0.0)).xyz;
    rd.surfaceTangent = normalize(modelConstant.modelMatrix * float4(vIn.tangent, 0.0)).xyz;
    rd.surfaceBitangent = normalize(modelConstant.modelMatrix * float4(vIn.bitangent, 0.0)).xyz;
    
    return rd;
}

