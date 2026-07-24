#version 460 core
#include <flutter/runtime_effect.glsl>

precision mediump float;

// Elara Wave — deep-water caustics background.
// Layered value noise, domain-warped over time, to suggest light rippling
// through clean water. Kept to 2-3 octaves deliberately (see docs/ANIMATION.md
// performance budget) — this runs behind headers all day on mid-range phones.

uniform vec2 uResolution;
uniform float uTime;
uniform float uIntensity;
uniform vec4 uColorDeep;
uniform vec4 uColorLight;

out vec4 fragColor;

float hash(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

float valueNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
  float value = 0.0;
  float amplitude = 0.55;
  for (int i = 0; i < 3; i++) {
    value += amplitude * valueNoise(p);
    p *= 2.05;
    amplitude *= 0.5;
  }
  return value;
}

void main() {
  vec2 uv = FlutterFragCoord() / uResolution;

  // Slow domain warp so the caustic net drifts rather than scrolls.
  float t = uTime * 0.12;
  vec2 warp = vec2(
    fbm(uv * 3.0 + vec2(t, -t * 0.6)),
    fbm(uv * 3.0 + vec2(-t * 0.7, t))
  );
  vec2 warped = uv * 4.2 + warp * 1.1;

  float caustic = fbm(warped + vec2(t * 0.35, t * 0.22));
  caustic = pow(caustic, 2.2);

  // Light enters from the top — brighter surface, darker toward the floor.
  float depthFade = mix(1.15, 0.55, uv.y);

  vec3 deep = uColorDeep.rgb;
  vec3 light = uColorLight.rgb;
  vec3 base = mix(deep, light, clamp(uv.y * 0.5, 0.0, 1.0));

  float highlight = smoothstep(0.55, 0.95, caustic) * depthFade * uIntensity;

  // Subtle chromatic separation on the caustic highlights only, to sell
  // refraction without any full-screen fringing.
  vec3 color = base + highlight * vec3(0.85, 1.0, 1.05);
  color += highlight * 0.06 * vec3(0.3, 0.0, -0.2);

  fragColor = vec4(color, 1.0);
}
