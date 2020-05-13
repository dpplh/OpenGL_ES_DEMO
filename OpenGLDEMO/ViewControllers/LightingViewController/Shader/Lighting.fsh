precision mediump float;

varying vec3 aNormal;

uniform vec4 objectColor;
uniform vec4 lightColor;

varying vec3 FragPosition;
uniform vec3 lightPosition;

void main() {
    vec3 norm = normalize(aNormal);
    vec3 lightDirection = normalize(lightPosition - FragPosition);
    float diff = max(dot(norm, lightDirection), 0.0);
    vec4 diffuse = diff * lightColor;
    
    gl_FragColor = objectColor * diffuse;
}

