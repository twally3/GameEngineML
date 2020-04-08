#include <metal_stdlib>
#include "Lighting.metal"
#include "Shared.metal"
using namespace metal;

vertex RasterizerData terrain_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                          constant SceneConstants &sceneConstants [[ buffer(1) ]],
                                          constant ModelConstants &modelConstants [[ buffer(2) ]]) {
    
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

float inverseLerp(float a, float b, float v) {
    return clamp((v - a) / (b - a), 0.0, 1.0);
}

float4 triplanar(float3 worldPos, float scale, float3 blendedAxes, texture2d<float> texture, sampler sampler2d) {
    float3 scaledWorldPos = worldPos / scale;

    float4 xProjection = texture.sample(sampler2d, scaledWorldPos.yz) * blendedAxes.x;
    float4 yProjection = texture.sample(sampler2d, scaledWorldPos.xz) * blendedAxes.y;
    float4 zProjection = texture.sample(sampler2d, scaledWorldPos.xy) * blendedAxes.z;

    return float4(xProjection.xyz + yProjection.xyz + zProjection.xyz, 1.0);
}

fragment half4 terrain_fragment_shader(RasterizerData rd [[ stage_in ]],
                                     constant Material &material [[ buffer(1) ]],
                                     constant int &lightCount [[ buffer(2) ]],
                                     constant LightData *lightDatas [[ buffer(3)]],
                                     constant int &regionCount [[ buffer(4) ]],
                                     constant TerrainLayer *regions [[ buffer(5) ]],
                                     constant float &maxTerrainHeight [[ buffer(6) ]],
                                     sampler sampler2d [[ sampler(0) ]],
                                     const array<texture2d<float>, 6> _textures [[ texture(1) ]]) {

    float heightPercent = inverseLerp(0.0, maxTerrainHeight, rd.worldPosition.y);
    float4 colour = float4(0.0, 0.0, 0.0, 1.0);

    float epsilon = 1e-4;

    float3 blendedAxes = abs(rd.surfaceNormal);
    blendedAxes /= blendedAxes.x + blendedAxes.y + blendedAxes.z;
    
    for (int i = 0; i < regionCount; i++) {
        float blend = regions[i].blend;
        int textureId = regions[i].textureId;
        float drawStrength = inverseLerp(-blend / 2 - epsilon, blend / 2, heightPercent - regions[i].height);

        float4 baseColour = regions[i].colour * regions[i].colourStrength;
        texture2d<float> texture = _textures[textureId];
        float4 textureColour = triplanar(rd.worldPosition, regions[i].scale, blendedAxes, texture, sampler2d) * (1 - regions[i].colourStrength);

        colour = colour * (1 - drawStrength) + (baseColour + textureColour) * drawStrength;
    }
    
    if (material.isLit) {
        float3 unitNormal = normalize(rd.surfaceNormal);
        float3 unitToCameraVector = normalize(rd.toCameraVector);

        float3 phongIntensity = Lighting::getPhongIntensity(material, lightDatas, lightCount, rd.worldPosition, unitNormal, unitToCameraVector);
        colour *= float4(phongIntensity, 1.0);
    }

    return half4(colour.r, colour.g, colour.b, 1.0);
}

kernel void create_height_map(texture2d<float, access::write> outputTexture [[texture(0)]],
                              constant float *heights [[ buffer(0) ]],
                              constant TerrainType *regions [[ buffer(1) ]],
                              constant int &regionCount [[ buffer(2) ]],
                              uint2 position [[thread_position_in_grid]]) {
    float heightValue = heights[position.y * outputTexture.get_width() + position.x];
//    float4 height = float4(heightValue, heightValue, heightValue, 1.0);
//    outputTexture.write(height, position);
    
    float4 heightColour = float4(0.0, 0.0, 0.0, 1.0);
    for (int i = 0; i < regionCount; i++) {
        if (heightValue >= regions[i].height) {
            heightColour = regions[i].colour;
        } else {
            break;
        }
    }
    
    outputTexture.write(heightColour, position);
}
