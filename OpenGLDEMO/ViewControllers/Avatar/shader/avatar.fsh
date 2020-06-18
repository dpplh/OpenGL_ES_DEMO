precision mediump float;

uniform sampler2D InputImageTexture;
varying vec2 TextureCoordinate;

void main() {
    vec4 color = texture2D(InputImageTexture, TextureCoordinate);
    gl_FragColor = color;
}
