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

    float near = 0.1;
    float far = 1000.0;
    float depth = refrationDepthTexture.sample(sampler2d, refractTextureCoord);
    float floorDistance = 2.0 * near * far / (far + near - (2.0 * depth - 1.0) * (far - near));

    depth = rd.position.z;
    float waterDistance = 2.0 * near * far / (far + near - (2.0 * depth - 1.0) * (far - near));

    float waterDepth = floorDistance - waterDistance;

    float2 distortedTexCoords = dudvTexture.sample(sampler2d, float2(textureCoords.x + moveFactor, textureCoords.y)).rg * 0.1;
    distortedTexCoords = textureCoords + float2(distortedTexCoords.x, distortedTexCoords.y + moveFactor);
    float2 totalDistortion = (dudvTexture.sample(sampler2d, distortedTexCoords).rg) * 0.01 * clamp(waterDepth / 20.0, 0.0, 1.0);

    refractTextureCoord += totalDistortion;
    refractTextureCoord = clamp(refractTextureCoord, 0.001, 0.999);

    reflectTextureCoord += totalDistortion;
    reflectTextureCoord = clamp(reflectTextureCoord, 0.001, 0.999);

    float4 refractColour = refractTexture.sample(sampler2d, refractTextureCoord);
    float4 reflectColour = reflectTexture.sample(sampler2d, reflectTextureCoord);

    float4 normalMapColour = normalMapTexture.sample(sampler2d, distortedTexCoords);
    float3 normal = float3(normalMapColour.r * 2.0 - 1.0, normalMapColour.b * 3.0, normalMapColour.g * 2.0 - 1.0);
    normal = normalize(normal);

    float3 viewVector = normalize(rd.toCameraVector);
    float refractiveFactor = clamp(dot(viewVector, normal), 0.001, 0.999);
    refractiveFactor = pow(refractiveFactor, 0.5);

    float4 color = mix(reflectColour, refractColour, refractiveFactor);

    if (material.isLit) {
        float3 unitToCameraVector = normalize(rd.toCameraVector);

        float3 phongIntensity = Lighting::getPhongIntensity(material, lightDatas, lightCount, rd.worldPosition, normal, unitToCameraVector);
        color *= float4(phongIntensity, 1.0) * clamp(waterDepth / 5.0, 0.0, 1.0);
    }

    return half4(color.r, color.g, color.b, clamp(waterDepth / 5.0, 0.0, 1.0));
}
