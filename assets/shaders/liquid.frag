#version 460 core
precision highp float;
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uIntensity;
uniform vec2 uTilt;
uniform float uShape; // 0.0 = normal/pill, 1.0 = magnifier, 2.0 = buttons
uniform sampler2D uTexture;

out vec4 fragColor;

// Hash without sine for better cross-platform matching of discrete turbulence
float hash(vec2 p) {
    vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// Gradient value noise
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    // Smoothstep
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    float a = hash(i + vec2(0.0, 0.0));
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// 2 octaves of turbulence (per SVG feTurbulence numOctaves=2)
float turbulence(vec2 p) {
    float f = 0.0;
    f += 0.5000 * abs(noise(p) - 0.5) * 2.0; p = p * 2.0;
    f += 0.2500 * abs(noise(p) - 0.5) * 2.0;
    return f;
}

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 size = max(uSize, vec2(1.0));
    vec2 uv = fragCoord / size;
    
    // Scale for turbulence freq (matching SVG baseFrequency 0.008)
    vec2 p = fragCoord * 0.008;
    
    // Add dynamic UI pan/tilt animation offset driving the turbulence field
    p += uTilt * 5.0; 
    
    // Render turbulence mapping mapped around -1.0 to 1.0 
    float tX = turbulence(p) * 2.0 - 1.0;
    float tY = turbulence(p + vec2(100.0)) * 2.0 - 1.0;
    
    // Equivalent to feDisplacementMap scale=77
    vec2 offset = vec2(tX, tY) * (77.0 * clamp(uIntensity, 0.0, 5.0) / size);
    vec2 finalUv = uv + offset;
    
    // Magnifying Glass Effect explicitly for Navbar Selector / Elements explicitly requesting
    if (uShape > 0.5 && uShape < 1.5) {
        vec2 centerVec = finalUv - vec2(0.5);
        // Magnify central area smoothly imitating a domed lens
        float mag = mix(0.7, 1.0, length(centerVec) * 1.5);
        finalUv = vec2(0.5) + centerVec * clamp(mag, 0.7, 1.0);
    }
    
    // Apply bounds and Chromatic Dispersion splitting the RGB texture paths based on the vector offset
    vec2 boundsV = finalUv; 
    
    // Slight separate offset factors for light bending wavelengths (Prism Simulation)
    vec2 offsetDisp = offset * 0.05; 
    
    vec4 rCol = texture(uTexture, clamp(boundsV - offsetDisp, 0.0, 1.0));
    vec4 gCol = texture(uTexture, clamp(boundsV, 0.0, 1.0));
    vec4 bCol = texture(uTexture, clamp(boundsV + offsetDisp, 0.0, 1.0));
    
    vec4 color = vec4(rCol.r, gCol.g, bCol.b, gCol.a);
    
    // Apply saturate(120%) and brightness(1.15) to perfectly replicate CSS filter string
    color.rgb *= 1.15; // Brightness bump
    
    float luma = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    color.rgb = mix(vec3(luma), color.rgb, 1.20); // Saturation bump
    
    fragColor = color;
}
