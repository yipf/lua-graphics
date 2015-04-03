-- http://blog.csdn.net/hongqiang200/article/details/8466454 
-- http://fabiensanglard.net/shadowmapping/index.php

vert=[[
varying vec3 normal, lightDir;
varying vec4 ShadowCoord;

void main()
{	
	vec4 vpos=gl_ModelViewMatrix * gl_Vertex;
	normal = gl_NormalMatrix * gl_Normal;
	lightDir=vec3(gl_LightSource[0].position-vpos);
	ShadowCoord= gl_TextureMatrix[1] * vpos;
	gl_TexCoord[0] = gl_MultiTexCoord0;  
	gl_Position = ftransform();		
}
]]

frag=[[
varying vec3 normal, lightDir, eyeVec;
varying vec4 ShadowCoord;
uniform sampler2D tex,shadowmap;  
void main (void){
	vec4 shadowCoordinateWdivide = ShadowCoord / ShadowCoord.w ;
	vec4 shadowTexel=texture2D(shadowmap,shadowCoordinateWdivide.st);
	float distanceFromLight = shadowTexel.z;
	//~ shadowCoordinateWdivide.z += 0.0005;
 	float shadow = 1.0;
 	if (ShadowCoord.w > 0.0) shadow = distanceFromLight < shadowCoordinateWdivide.z ? 0.5 : 1.0 ;
	
	float f = dot(normalize(normal),normalize(lightDir));
	f=f>0.0?f:0.0;

	gl_FragColor=shadow*f*texture2D(tex,gl_TexCoord[0].st);  




	//~ vec4 final_color = 	(gl_FrontLightModelProduct.sceneColor * gl_FrontMaterial.ambient) + (gl_LightSource[0].ambient * gl_FrontMaterial.ambient);
	//~ vec3 N = normalize(normal);
	//~ vec3 L = normalize(lightDir);
	//~ float lambertTerm = dot(N,L);
	//~ float at,af;  
	//~ vec3 ct,cf;  
    //~ vec4 texel;  
	
	//~ // texture color
	//~ if(lambertTerm > 0.0)
	//~ {
		//~ cf = lambertTerm * (gl_FrontMaterial.diffuse).rgb +  gl_FrontMaterial.ambient.rgb;  
		//~ af = gl_FrontMaterial.diffuse.a;  
		//~ texel = texture2D(tex,gl_TexCoord[0].st);  
		//~ ct = texel.rgb;  
		//~ at = texel.a;  
		//~ final_color += vec4(ct * cf, at * af);  
	//~ }
	//~ // shadow color
	//~ vec4 shadowCoordinateWdivide = ShadowCoord / ShadowCoord.w ;
	//~ float distanceFromLight = texture2D(shadowmap,shadowCoordinateWdivide.st).z;
		//~ // Used to lower moiré pattern and self-shadowing
	//~ shadowCoordinateWdivide.z += 0.005;
 	//~ float shadow = 1.0;
 	//~ if (ShadowCoord.w > 0.0)
 		//~ shadow = distanceFromLight < shadowCoordinateWdivide.z ? 0.5 : 1.0 ;
	//~ gl_FragColor = final_color;			
	//~ gl_FragColor = shadow*vec4(ct,1);			
	//~ gl_FragColor=shadowCoordinateWdivide.z; 
	//~ gl_FragColor=  lambertTerm*shadow*vec4(ct,1);	
	//~ gl_FragColor= distanceFromLight;
	//~ gl_FragColor =  vec4(ct,1);  		
	
}
]]

return vert,frag