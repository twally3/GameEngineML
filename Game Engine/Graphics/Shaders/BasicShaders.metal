#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

vertex RasterizerData basic_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                          constant SceneConstants &sceneConstants [[ buffer(1) ]],
                                          constant ModelConstants &modelConstants [[ buffer(2) ]]) {
    RasterizerData rd;
    
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * modelConstants.modelMatrix * float4(vIn.position, 1);
    rd.colour = vIn.colour;
    rd.textureCoordinate = vIn.textureCoordinate;
    rd.totalGameTime = sceneConstants.totalGameTime;
    
    return rd;
}

fragment half4 basic_fragment_shader(RasterizerData rd [[ stage_in ]],
                                     constant Material &material [[ buffer(1) ]]) {
//    float4 colour = material.useMaterialColour ? material.colour : rd.colour;
    
    float2 textCoord = rd.textureCoordinate;
    float gameTime = rd.totalGameTime;
    
    float x = sin((textCoord.x + gameTime) * 20);
    float y = sin((textCoord.y + gameTime) * 20);
    float z = tan((textCoord.x + gameTime) * 20);
    
    float4 colour = float4(x, y, z, 1);
    
    return half4(colour.r, colour.g, colour.b, colour.a);
}
