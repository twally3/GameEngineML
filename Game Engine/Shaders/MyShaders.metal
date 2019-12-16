#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float4 colour [[ attribute(1) ]];
};

struct RasterizerData {
    float4 position [[ position ]];
    float4 colour;
};

struct ModelConstants {
    float4x4 modelMatrix;
};

struct SceneConstants {
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
};

struct Material {
    float4 colour;
    bool useMaterialColour;
};

vertex RasterizerData basic_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                          constant SceneConstants &sceneConstants [[ buffer(1) ]],
                                          constant ModelConstants &modelConstants [[ buffer(2) ]]) {
    RasterizerData rd;
    
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * modelConstants.modelMatrix * float4(vIn.position, 1);
    rd.colour = vIn.colour;
    
    return rd;
}

fragment half4 basic_fragment_shader(RasterizerData rd [[ stage_in ]],
                                     constant Material &material [[ buffer(1) ]]) {
    float4 colour = material.useMaterialColour ? material.colour : rd.colour;
    return half4(colour.r, colour.g, colour.b, colour.a);
}
