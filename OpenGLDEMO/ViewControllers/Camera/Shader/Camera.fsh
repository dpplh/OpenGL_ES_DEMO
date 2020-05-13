precision mediump float;

uniform sampler2D InputImageTexture;
varying vec2 TextureCoordinate;

void main() {
    gl_FragColor = texture2D(InputImageTexture, TextureCoordinate);
}

