precision mediump float;

uniform vec3 lightPosition;
uniform vec3 viewPosition;

uniform vec4 objectColor;
uniform vec4 lightColor;

varying vec3 FragPosition;
varying vec3 aNormal;

void main() {
    vec3 viewDir = normalize(viewPosition - FragPosition);
    vec3 lightDir = normalize(FragPosition - lightPosition);
    vec3 reflectDir = reflect(lightDir, aNormal);
    
    float specular = pow(max(dot(viewDir, reflectDir), 0.0), 256.0);
    
    gl_FragColor = objectColor * specular;
}

