attribute vec3 Position;
attribute vec3 Normal;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

varying vec3 aNormal;
varying vec3 FragPosition;

void main (void) {
    gl_Position = projection * view * model * vec4(Position, 1.0);
    aNormal = Normal;
    FragPosition = Position;
}

