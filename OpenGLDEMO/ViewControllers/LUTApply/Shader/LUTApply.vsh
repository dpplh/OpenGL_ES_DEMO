attribute vec4 Position;
attribute vec2 InputTextureCoordinate;

varying vec2 TextureCoordinate;
uniform mat4 MVP;

void main (void) {
    gl_Position = MVP * Position;
    TextureCoordinate = InputTextureCoordinate;
}
