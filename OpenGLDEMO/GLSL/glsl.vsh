attribute vec4 Position;
attribute vec2 InputTextureCoordinate;

varying vec2 TextureCoordinate;

void main (void) {
    gl_Position = Position;
    TextureCoordinate = InputTextureCoordinate;
}
