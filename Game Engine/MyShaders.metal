#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position;
    float4 colour;
};

struct RasterizerData {
    float4 position [[ position ]];
    float4 colour;
};

vertex RasterizerData basic_vertex_shader(const device VertexIn *vertices [[ buffer(0) ]],
                                  uint vertexID [[ vertex_id ]]) {
    RasterizerData rd;
    
    rd.position = float4(vertices[vertexID].position, 1);
    rd.colour = vertices[vertexID].colour;
    
    return rd;
}

fragment half4 basic_fragment_shader(RasterizerData rd [[ stage_in ]]) {
    float4 colour = rd.colour;
    return half4(colour.r, colour.g, colour.b, colour.a);
}
