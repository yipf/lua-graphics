-- http://blog.csdn.net/hongqiang200/article/details/8466454 
-- http://fabiensanglard.net/shadowmapping/index.php
-- http://blog.csdn.net/hgl868/article/details/7872414

vert=[[
varying vec3 normal, lightDir;
varying float dist;
varying vec4 ShadowCoord;

void main()
{	
	vec4 vpos=gl_ModelViewMatrix * gl_Vertex;
	normal = gl_NormalMatrix * gl_Normal;
	lightDir=vec3(gl_LightSource[0].position-vpos);
	dist=length(lightDir);
	ShadowCoord= gl_TextureMatrix[1] * vpos;
	gl_TexCoord[0] = gl_MultiTexCoord0;  
	gl_Position = ftransform();		
}
]]

frag=[[
varying vec3 normal, lightDir, eyeVec;
varying float dist;
varying vec4 ShadowCoord;
uniform sampler2D tex,shadowmap;  
void main (void){
	// compute shadow fact
	vec4 shadowCoordinateWdivide = ShadowCoord / ShadowCoord.w ;
	vec4 shadowTexel=texture2D(shadowmap,shadowCoordinateWdivide.st);
	float distanceFromLight = shadowTexel.z;
 	float shadow = 1.0;
 	if (ShadowCoord.w > 0.0) shadow = distanceFromLight < shadowCoordinateWdivide.z ? 0.5 : 1.0 ;
	// spot light
	float x=shadowCoordinateWdivide.x*2.0-1.0;
	float y=shadowCoordinateWdivide.y*2.0-1.0;
	if((x*x+y*y)>1.0) {shadow=0.5;}
	// compute color factor
	float f = dot(normalize(normal),normalize(lightDir));
	f=f>0.0?f:0.0;
	
	// compute final color
	gl_FragColor=shadow*f*texture2D(tex,gl_TexCoord[0].st);  
}
]]

return vert,frag