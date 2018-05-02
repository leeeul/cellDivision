#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform float u_time;
uniform float noi = .0;
uniform float ran = .0;
uniform float mag = 0.;
uniform float wei = 0.;

varying vec4 vertTexCoord;
vec3 color;
vec2 coord;

vec2 random(vec2 c_){
    float x = fract(sin(dot(c_, vec2(75.8,48.6)))*1e5);
    float y = fract(sin(dot(c_, vec2(85.8,108.6)))*1e5);
    
    vec2 returnVec = vec2(x,y);
    returnVec = returnVec*2.-1.;
    return returnVec;
}

float noise(vec2 coord){
    
    vec2 i = floor(coord);
    vec2 f = fract(coord);
    
    f = smoothstep(0., 1., f);
    
    float returnVal = mix(    mix( dot(random(i), coord-i),
                                  dot(random(i+vec2(1., 0.)), coord-(i+vec2(1., 0.))),
                                  f.x),
                          mix( dot(random(i+vec2(0., 1.)), coord-(i+vec2(0., 1.))),
                              dot(random(i+vec2(1., 1.)), coord-(i+vec2(1., 1.))),
                              f.x),
                          f.y
                          );
    
    
    return (returnVal);
    // 노이즈의 리턴값이 -1 ~ 1 범위입니다
}

float random_f(vec2 coord){
    return fract(sin(dot(coord, vec2(75.7,65.9)))*1e5); // 0~1
}

vec2 noiseVec2(vec2 coord){
    float time_Speed = 1.5;
    float time_Diff = random_f(coord)*5.375;
    coord += u_time*time_Speed + time_Diff;
    // 이 윗 3줄이 노이지하게 움직이게 만듭니다. 움직이기 싫으면 그냥 윗 3줄 주석처리 하세요.
    return vec2( noise((coord+0.57)), noise((coord+90.43)) );
    // return -1 ~ 1 범위
}

void main() {
    coord = vertTexCoord.xy;
    
    coord -= .5;
    coord *= 44.032;
    
    float l = length(coord);
    coord *= sin(l*.196)+.640;
    coord /= 1.248;
    coord /= mag;
    
    vec2 i = floor(coord);
    vec2 me;
    
    float minDist = 3.;
    for(float y = -1.; y <= 1.; y += 1.){
        for(float x = -1.; x <= 1.; x += 1.){
            vec2 tC = i + vec2(x, y);
            tC += .5;
            tC += random(tC)*ran;
            tC += noiseVec2(tC)*noi;
            
            float d = distance(coord, tC);
            if(d<minDist){
                minDist = d;
                me = tC;
            }
        }
    }
    
    if(minDist<0.1 && minDist>0.05){
        color = vec3(0.087,0.195,0.131);
    }else{
    
        float mb=3.; //이게 이제 세포벽면으로부터의 최소거리를 담는 변수
        for(float y=-2.; y<=2.; y++){
            for(float x=-2.; x<=2.; x++){
                vec2 you = i + vec2(x, y);
                you += .5;
                you += random(you)*ran;
                you += noiseVec2(you)*noi;
                
                if(you == me){
                    continue;
                }
                
                vec2 m = (me+you)/2.;
                
                vec2 b = me-m;
                vec2 a = coord-m;
                vec2 n = normalize(b);
                
                vec2 l = n*(dot(a, n));
                l+=m;
                
                float d = distance(l, m);
                if(d<mb){
                    mb=d;
                }
            }
        }
        
        float v = smoothstep(-0.568, 3.268, mb*2.480);
        color = vec3(v*0.0);
        color = mix(vec3(0.990,0.795,0.988), color, smoothstep(0.250, 1.030, mb*wei));
        color = 0.936 - color;
        color *= 1.052;
    }
    float h = 19.036;
    color = mix(color, vec3(1.0), smoothstep(h, h*1.05, l));
    
    gl_FragColor = vec4(color, 1.);
}
