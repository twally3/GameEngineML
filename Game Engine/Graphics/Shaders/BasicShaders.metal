#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

vertex RasterizerData basic_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                          constant SceneConstants &sceneConstants [[ buffer(1) ]],
                                          constant ModelConstants &modelConstants [[ buffer(2) ]]) {
    RasterizerData rd;
    
    float4 worldPosition = modelConstants.modelMatrix * float4(vIn.position, 1);
    
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
    rd.colour = vIn.colour;
    rd.textureCoordinate = vIn.textureCoordinate;
    rd.worldPosition = worldPosition.xyz;
    rd.surfaceNormal = (modelConstants.modelMatrix * float4(vIn.normal, 1.0)).xyz;
    rd.toCameraVector = sceneConstants.cameraPosition - worldPosition.xyz;
    
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
        float3 totalDiffuse = float3(0, 0, 0);
        float3 totalSpecular = float3(0, 0, 0);
        
        float3 unitNormal = normalize(rd.surfaceNormal);
        float3 unitToCameraVector = normalize(rd.toCameraVector);
        
        for (int i = 0; i < lightCount; i++) {
            LightData lightData = lightDatas[i];
            
            float3 unitToLightVector = normalize(lightData.position - rd.worldPosition);
            float3 unitReflectionVector = normalize(reflect(-unitToLightVector, unitNormal));
            
            float3 ambientness = material.ambient * lightData.ambientIntensity;
            float3 ambientColour = clamp(ambientness * lightData.colour * lightData.brightness, 0.0, 1.0);
            totalAmbient += ambientColour;
            
            float3 diffuseness = material.diffuse * lightData.diffuseIntensity;
            float nDotL = max(dot(unitNormal, unitToLightVector), 0.0);
            float3 diffuseColour = clamp(diffuseness * nDotL * lightData.colour * lightData.brightness, 0.0, 1.0);
            totalDiffuse += diffuseColour;
            
            float3 specularness = material.specular * lightData.specularIntensity;
            float rDotV = max(dot(unitReflectionVector, unitToCameraVector), 0.0);
            float specularExp = pow(rDotV, material.shininess);
            float3 specularColour = clamp(specularness * specularExp * lightData.colour * lightData.brightness, 0.0, 1.0);
            totalSpecular += specularColour;
        }
        
        float3 phongIntensity = totalAmbient + totalDiffuse + totalSpecular;
        colour *= float4(phongIntensity, 1.0);
    }
    
    return half4(colour.r, colour.g, colour.b, colour.a);
}
