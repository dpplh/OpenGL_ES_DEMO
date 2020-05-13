attribute vec4 Position;
attribute vec2 InputTextureCoordinate;

varying vec2 TextureCoordinate;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main (void) {
    gl_Position = projection * view * model * Position;
    TextureCoordinate = InputTextureCoordinate;
}

