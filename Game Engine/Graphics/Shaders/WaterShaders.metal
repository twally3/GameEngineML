#include <metal_stdlib>
#include "Lighting.metal"
#include "Shared.metal"
using namespace metal;

vertex RasterizerData water_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                          constant SceneConstants &sceneConstants [[ buffer(1) ]],
                                          constant ModelConstants &modelConstants [[ buffer(2) ]]) {
    RasterizerData rd;
    
    float4 worldPosition = modelConstants.modelMatrix * float4(vIn.position, 1);
    
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
    rd.colour = vIn.colour;
    rd.textureCoordinate = vIn.textureCoordinate;
    rd.worldPosition = worldPosition.xyz;
    rd.surfaceNormal = (modelConstants.modelMatrix * float4(vIn.normal, 0.0)).xyz;
    rd.toCameraVector = sceneConstants.cameraPosition - worldPosition.xyz;
    rd.clipSpace = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
    
    return rd;
}

fragment half4 water_fragment_shader(RasterizerData rd [[ stage_in ]],
                                     constant Material &material [[ buffer(1) ]],
                                     constant int &lightCount [[ buffer(2) ]],
                                     constant LightData *lightDatas [[ buffer(3)]],
                                     constant float &moveFactor [[ buffer(4) ]],
                                     sampler sampler2d [[ sampler(0) ]],
                                     texture2d<float> reflectTexture [[ texture(0) ]],
                                     texture2d<float> refractTexture [[ texture(1) ]],
                                     texture2d<float> dudvTexture [[ texture(2) ]],
                                     texture2d<float> normalMapTexture [[ texture(3) ]],
                                     depth2d<float> refrationDepthTexture [[ texture(4) ]] ){

    float2 textureCoords = rd.textureCoordinate * 4.0;
    float4 clipSpace = rd.clipSpace;
    float2 ndc = (clipSpace.xy / clipSpace.w) / 2.0 + 0.5;

    float2 refractTextureCoord = float2(ndc.x, 1 - ndc.y);
    float2 reflectTextureCoord = float2(ndc.x, ndc.y);
    
    float2 distortedTexCoords = dudvTexture.sample(sampler2d, float2(textureCoords.x + moveFactor, textureCoords.y)).rg * 0.1;
    distortedTexCoords = textureCoords + float2(distortedTexCoords.x, distortedTexCoords.y + moveFactor);
    float2 totalDistortion = (dudvTexture.sample(sampler2d, distortedTexCoords).rg) * 0.02;

    refractTextureCoord += totalDistortion;
    refractTextureCoord = clamp(refractTextureCoord, 0.001, 0.999);

    reflectTextureCoord += totalDistortion;
    reflectTextureCoord = clamp(reflectTextureCoord, 0.001, 0.999);

    float4 refractColour = refractTexture.sample(sampler2d, refractTextureCoord);
    float4 reflectColour = reflectTexture.sample(sampler2d, reflectTextureCoord);

    float3 viewVector = normalize(rd.toCameraVector);
    float refractiveFactor = clamp(dot(viewVector, float3(0, 1, 0)), 0.001, 0.999);

    float4 color = mix(reflectColour, refractColour, refractiveFactor);

    if (material.isLit) {
        float4 normalMapColour = normalMapTexture.sample(sampler2d, distortedTexCoords);
        float3 normal = float3(normalMapColour.r * 2.0 - 1.0, normalMapColour.b, normalMapColour.g * 2.0 - 1.0);
        normal = normalize(normal);

        float3 unitToCameraVector = normalize(rd.toCameraVector);

        float3 phongIntensity = Lighting::getPhongIntensity(material, lightDatas, lightCount, rd.worldPosition, normal, unitToCameraVector);
        color *= float4(phongIntensity, 1.0);
    }

    return half4(color.r, color.g, color.b, 1.0);
}

    
//    float depth = refrationDepthTexture.sample(sampler2d, refractTextureCoord);
//    float lineardepth = (2.0f * 0.1) / (1000.0f + 0.1f - depth * (1000.0f - 0.1f));
//
//    return half4(lineardepth, lineardepth, lineardepth, 1.0);
