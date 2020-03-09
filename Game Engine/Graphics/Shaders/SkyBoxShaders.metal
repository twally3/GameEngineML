#include <metal_stdlib>
#include "Lighting.metal"
#include "Shared.metal"
using namespace metal;

struct SkyboxRasterizerData {
    float4 position [[ position ]];
    float3 texCoords;
};

vertex SkyboxRasterizerData skybox_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                                 constant SceneConstants &sceneConstants [[ buffer(1) ]],
                                                 constant ModelConstants &modelConstants [[ buffer(2) ]]) {
    SkyboxRasterizerData rd;
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * modelConstants.modelMatrix * float4(vIn.position, 1);
    rd.texCoords = vIn.position;
    return rd;
}

fragment half4 skybox_fragment_shader(SkyboxRasterizerData rd [[ stage_in ]],
                                      texturecube<half> cubeTexture [[ texture(0) ]],
                                      sampler cubeSampler [[ sampler(0) ]]) {
    
    float3 texCoords = float3(rd.texCoords.x, rd.texCoords.y, -rd.texCoords.z);
    return cubeTexture.sample(cubeSampler, texCoords);
}

