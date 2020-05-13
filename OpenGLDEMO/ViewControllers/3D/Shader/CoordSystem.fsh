precision mediump float;

uniform sampler2D InputImageTexture;
varying vec2 TextureCoordinate;

uniform vec3 lightColor;

void main() {
    gl_FragColor = texture2D(InputImageTexture, TextureCoordinate);
}

