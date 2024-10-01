float random (in vec2 _st) {
    return fract(sin(dot(_st.xy, vec2(12.9898,78.233)))*43758.5453123);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 _st) {
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

#define NUM_OCTAVES 5

float fbm ( in vec2 _st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5),
                    -sin(0.5), cos(0.50));
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(_st);
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
	float time = iTime;
    
    vec4 col = vec4(0.335, 0.432, 0.401, 1.0);
	vec4 woods = texture(iChannel0,uv);
    //woods = texture(iChannel0, vec2(uv.x,fract(uv.y+(time/5.0))));
    woods = texture(iChannel0, vec2(fract(uv.x-(time/10.)), uv.y));
    
    vec2 q = vec2(0.);
    q.x = fbm( uv + 0.00*time);
    q.y = fbm( uv + vec2(1.0));

    vec2 r = vec2(0.);
    r.x = fbm( uv + 0.8*q + vec2(1.7,9.2)+ 0.15*time );
    r.y = fbm( uv + 0.8*q + vec2(8.3,2.8)+ 0.126*time);

    float f = fbm(uv+r);
    woods.a *= length(r) * q.x * 2.0;
    woods.rgb *= r.y * q.y * 1.3;
    
    // rain
	float d = 1.;
	for (int i = 0; i < 13; i++)
	{
		float f = pow(d, .45)+.25;
		vec2 st =  f * (uv * vec2(1.5, .05)+vec2(-time*.1+uv.y*.5, time*.12));
		f = (texture(iChannel1, st * .5, -99.0).x + texture(iChannel1, st*.284, -99.0).y);
		f = clamp(pow(abs(f)*.5, 29.0) * 140.0, 0.00, uv.y*.4+.05);
		vec3 b = vec3(.25);
	
		woods.rgb += b*f;
		d += 3.5;
	}
    
    // lightning
    //float lightning = sin(time*sin(time*10.));				// lighting flicker
    //lightning *= pow(max(0., sin(time+sin(time))), 2.)/200.;		// lightning flash
    //woods.rgb *= 0.6 + 0.004*lightning*mix(0.5, .1, time*time);	// composite lightning
    //woods.rgb *= 1.-dot(uv-=.5, uv); 

    // Output to screen
    fragColor = col * (1.0 - woods.a) + woods * woods.a;
}