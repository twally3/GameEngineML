#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float4 colour [[ attribute(1) ]];
    float2 textureCoordinate [[ attribute(2) ]];
};

struct RasterizerData {
    float4 position [[ position ]];
    float4 colour;
    float2 textureCoordinate;
    float totalGameTime;
};

struct ModelConstants {
    float4x4 modelMatrix;
};

struct SceneConstants {
    float totalGameTime;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};

struct Material {
    float4 colour;
    bool useMaterialColour;
};
