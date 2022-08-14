#include <metal_stdlib>
#include "Lighting.metal"
#include "Shared.metal"
using namespace metal;

struct FragOutput {
    half4 color0 [[ color(0) ]];
    half4 color1 [[ color(1) ]];
};

vertex RasterizerData basic_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                          constant SceneConstants &sceneConstants [[ buffer(1) ]],
                                          constant ModelConstants &modelConstants [[ buffer(2) ]]) {
    RasterizerData rd;
    
    float4 worldPosition = modelConstants.modelMatrix * float4(vIn.position, 1);
    
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
    rd.colour = vIn.colour;
    rd.textureCoordinate = vIn.textureCoordinate;
    rd.worldPosition = worldPosition.xyz;
    rd.toCameraVector = sceneConstants.cameraPosition - worldPosition.xyz;
    
    rd.surfaceNormal = normalize(modelConstants.modelMatrix * float4(vIn.normal, 0.0)).xyz;
    rd.surfaceTangent = normalize(modelConstants.modelMatrix * float4(vIn.tangent, 0.0)).xyz;
    rd.surfaceBitangent = normalize(modelConstants.modelMatrix * float4(vIn.bitangent, 0.0)).xyz;
    
    
    return rd;
}

fragment FragOutput basic_fragment_shader(RasterizerData rd [[ stage_in ]],
                                     constant Material &material [[ buffer(1) ]],
                                     constant int &lightCount [[ buffer(2) ]],
                                     constant LightData *lightDatas [[ buffer(3)]],
                                     sampler sampler2d [[ sampler(0) ]],
                                     texture2d<float> baseColourMap [[ texture(0) ]],
                                     texture2d<float> baseNormalMap [[ texture(1) ]]) {
    
    float2 textCoord = rd.textureCoordinate;
    
    float4 colour = material.colour;
    if (!is_null_texture(baseColourMap)) {
        colour = baseColourMap.sample(sampler2d, textCoord);
    }
    
    float3 unitNormal;
    if (material.isLit) {
        unitNormal = normalize(rd.surfaceNormal);
        if (!is_null_texture(baseNormalMap)) {
            float3 sampleNormal = baseNormalMap.sample(sampler2d, textCoord).rgb * 2 - 1;
            float3x3 tbn = { rd.surfaceTangent, rd.surfaceBitangent, rd.surfaceNormal };
            unitNormal = tbn * sampleNormal;
        }
        
        float3 unitToCameraVector = normalize(rd.toCameraVector);
        
//        float3 phongIntensity = totalAmbient + totalDiffuse + totalSpecular;
        float3 phongIntensity = Lighting::getPhongIntensity(material, lightDatas, lightCount, rd.worldPosition, unitNormal, unitToCameraVector);
        colour *= float4(phongIntensity, 1.0);
    }
    
//    return half4(colour.r, colour.g, colour.b, colour.a);
    FragOutput out;
    out.color0 = half4(colour.r, colour.g, colour.b, colour.a);
    out.color1 = half4(unitNormal.x, unitNormal.y, unitNormal.z, 1.0);
//    out.color1 = half4(0);
    return out;
}
