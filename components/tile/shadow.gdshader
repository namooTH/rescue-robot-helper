shader_type canvas_item;

uniform sampler2D heightmap : hint_default_white;
uniform float height_scale = 10.0; // controls slope strength
uniform vec3 light_dir = vec3(0.5, 0.5, 1.0); // top-right light

void fragment() {
    vec2 uv = UV;

    // sample height from heightmap
    float h = texture(heightmap, uv).r * height_scale;

    // compute local height derivatives
    float hL = texture(heightmap, uv + vec2(-0.001, 0)).r * height_scale;
    float hR = texture(heightmap, uv + vec2( 0.001, 0)).r * height_scale;
    float hD = texture(heightmap, uv + vec2(0, -0.001)).r * height_scale;
    float hU = texture(heightmap, uv + vec2(0,  0.001)).r * height_scale;

    // build normal from derivatives
    vec3 normal = normalize(vec3(hL - hR, hD - hU, 2.0));

    // lambertian lighting
    float light = clamp(dot(normal, light_dir), 0.0, 1.0);

    COLOR = vec4(vec3(light), 1.0);
}
