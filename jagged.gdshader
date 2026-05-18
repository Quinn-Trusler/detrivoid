shader_type canvas_item;

varying vec2 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec4 col = texture(TEXTURE, UV);

    float noise = texture(noise_tex, world_pos * 0.1).r;

    col.rgb *= noise;

    COLOR = col;
}