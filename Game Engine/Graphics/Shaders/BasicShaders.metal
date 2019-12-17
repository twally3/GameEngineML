#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

vertex RasterizerData basic_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                          constant SceneConstants &sceneConstants [[ buffer(1) ]],
                                          constant ModelConstants &modelConstants [[ buffer(2) ]]) {
    RasterizerData rd;
    
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * modelConstants.modelMatrix * float4(vIn.position, 1);
    rd.colour = vIn.colour;
    rd.textureCoordinate = vIn.textureCoordinate;
    
    return rd;
}

fragment half4 basic_fragment_shader(RasterizerData rd [[ stage_in ]],
                                     constant Material &material [[ buffer(1) ]],
                                     constant int &lightCount [[ buffer(2) ]],
                                     constant LightData *lightDatas [[ buffer(3)]],
                                     sampler sampler2d [[ sampler(0) ]],
                                     texture2d<float> texture [[ texture(0) ]]) {
    
    float2 textCoord = rd.textureCoordinate;
    
    float4 colour;
    if (material.useTexture) {
        colour = texture.sample(sampler2d, textCoord);
    } else if (material.useMaterialColour) {
        colour = material.colour;
    } else {
        colour = rd.colour;
    }
    
    if (material.isLit) {
        float3 totalAmbient = float3(0, 0, 0);
        for (int i = 0; i < lightCount; i++) {
            LightData lightData = lightDatas[i];
            
            float3 ambientness = material.ambient * lightData.ambientIntensity;
            float3 ambientColour = ambientness * lightData.colour;
            totalAmbient += ambientColour;
        }
        
        float3 phongIntensity = totalAmbient; // + totalDiffuse + totalSpecular
        colour *= float4(phongIntensity, 1.0);
    }
    
    return half4(colour.r, colour.g, colour.b, colour.a);
}
