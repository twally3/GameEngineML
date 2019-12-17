#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float4 colour [[ attribute(1) ]];
    float2 textureCoordinate [[ attribute(2) ]];
    float3 normal [[ attribute(3) ]];
};

struct RasterizerData {
    float4 position [[ position ]];
    float4 colour;
    float2 textureCoordinate;
    float3 worldPosition;
    float3 surfaceNormal;
    float3 toCameraVector;
};

struct ModelConstants {
    float4x4 modelMatrix;
};

struct SceneConstants {
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float3 cameraPosition;
};

struct Material {
    float4 colour;
    bool useMaterialColour;
    bool useTexture;
    bool isLit;
    float3 ambient;
    float3 diffuse;
    float3 specular;
    float shininess;
};

struct LightData {
    float3 position;
    float3 colour;
    float brightness;
    float ambientIntensity;
    float diffuseIntensity;
    float specularIntensity;
};
