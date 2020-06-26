#ifndef LIGHTING_METAL
#define LIGHTING_METAL

#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

class Lighting {
public:
    static float3 getPhongIntensity(constant Material &material,
                                    constant LightData *lightDatas,
                                    int lightCount,
                                    float3 worldPosition,
                                    float3 unitNormal,
                                    float3 unitToCameraVector) {
        float3 totalAmbient = float3(0, 0, 0);
        float3 totalDiffuse = float3(0, 0, 0);
        float3 totalSpecular = float3(0, 0, 0);
        
        for (int i = 0; i < lightCount; i++) {
            LightData lightData = lightDatas[i];
            
            float3 unitToLightVector = normalize(lightData.position - worldPosition);
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
            totalSpecular += specularColour * 10;
        }
        
        return totalAmbient + totalDiffuse + totalSpecular;
    }
};

#endif
