#include "yipf-img-gl.h"

static GLint shadowMapUniform,texUniform;

img_type create_img(unsigned int width,unsigned int height){
	img_type img=(img_type)malloc(sizeof(img_type_));
	img->comp=4;
	img->data=(char*)malloc((width*height)<<2);
	img->width=width;
	img->height=height;
	return img;
}

char * get_pixel(img_type img,unsigned int x, unsigned int y){
	char *data;
	unsigned int width,height;
	if(!img){		return 0;	}
	width=img->width;	height=img->height;
	data=img->data;
	x=x>width?width:x; 	y=y>height?height:y;
	return data+(y*width+x)*(img->comp);
}

char* set_pixel(char* pixel,unsigned int comp, char r, char g, char b, char a){
	if(!pixel) {return pixel;}
	switch(comp){
		case 4: pixel[3]=a;
		case 3: pixel[2]=b;
		case 2: pixel[1]=g;
		case 1: pixel[0]=r;
		default: break;
	}
	return pixel;
}

char * copy_pixel(char* dst,unsigned int dcomp, char* src,unsigned int scomp){
	unsigned int comp=dcomp>scomp?scomp:dcomp;
	while(comp-->0){dst[comp]=src[comp];}
	return dst;
}

int delete_img(img_type img){
	if(img->data){
		free(img->data);
	}
	free(img);
	return 0;
}

int save_img(img_type img,const char* filepath){
	return  stbi_write_png (filepath, img->width, img->height, img->comp, img->data, (img->width)*(img->comp));
	return 0;
}


img_type load_img(char const *filepath,int req_comp){
	img_type img=create_img(1,1);
	img->data=stbi_load (filepath,  &(img->width), &(img->height), &(img->comp), req_comp);
	return img;
}

vec4 create_vec4(scalar x,scalar y,scalar z){
	vec4 v=(vec4)malloc(sizeof(scalar)*4);
	v[0]=x;	v[1]=y;	v[2]=z;		v[3]=1;
	return v;
}

int destroy_vec4(vec4 v){
	free(v);
	return 0;
}

vec4 cross(vec4 v1,vec4 v2,vec4 v){
	scalar x1,y1,z1,x2,y2,z2;
	x1=v1[0];	y1=v1[1];	z1=v1[2];	
	x2=v2[0];	y2=v2[1];	z2=v2[2];	
	v=v?v:create_vec4(0,0,0);
	v[0]=y1*z2-y2*z1;
	v[1]=z1*x2-z2*x1;
	v[2]=x1*y2-x2*y1;
	return v;
}

scalar dot(vec4 v1,vec4 v2,int n){
	scalar d=0;
	int i;
	for(i=0;i<n;i++){d=d+v1[i]*v2[i];}
	return d;
}

scalar norm(vec4 v){
	scalar x,y,z;
	x=v[0];	y=v[1];	z=v[2];
	return sqrt(x*x+y*y+z*z);
}

vec4 normalize(vec4 v){
	scalar x,y,z,n;
	x=v[0];	y=v[1];	z=v[2];
	n=sqrt(x*x+y*y+z*z);
	v[0]=x/n;	v[1]=y/n;	v[2]=z/n;
	return v;
}

vec4 clone_vec4(vec4 src,vec4 dst,int n){
	if(dst==src){ return dst;	}
	if(!src) return src;
	dst=dst?dst:create_vec4(0,0,0);
	int i;
	for(i=0;i<n;i++){dst[i]=src[i];	}
	return dst;
}

mat4x4 create_mat4x4(){
	return (mat4x4)malloc(sizeof(scalar)*16);
}

int destroy_mat4x4(mat4x4 m){
	free(m);
	return 0;
}

mat4x4 make_translate(mat4x4 m,scalar tx,scalar ty,scalar tz){
	m=m?m:create_mat4x4();
	m[0]=1;	m[1]=0;	m[2]=0;	m[3]=0;
	m[4]=0;	m[5]=1;	m[6]=0;	m[7]=0;
	m[8]=0;	m[9]=0;	m[10]=1;	m[11]=0;
	m[12]=tx;	m[13]=ty;	m[14]=tz;	m[15]=1;
	return m;
}

mat4x4 make_scale(mat4x4 m,scalar sx,scalar sy,scalar sz){
	m=m?m:create_mat4x4();
	m[0]=sx;	m[1]=0;	m[2]=0;	m[3]=0;
	m[4]=0;	m[5]=sy;	m[6]=0;	m[7]=0;
	m[8]=0;	m[9]=0;	m[10]=sz;	m[11]=0;
	m[12]=0;	m[13]=0;	m[14]=0;	m[15]=1;
	return m;
}

mat4x4 make_rotate(mat4x4 m,scalar x,scalar y,scalar z,scalar ang){
	scalar n,s,c;
	n=sqrt(x*x+y*y+z*z);	s=sin(ang);	c=cos(ang);
	x=x/n;	y=y/n;	z=z/n;	
	m=m?m:create_mat4x4();
	m[0]=x*x*(1-c)+c;		m[4]=x*y*(1-c)-z*s;		m[8]=x*z*(1-c)+y*s;	m[12]=0;
	m[1]=x*y*(1-c)+z*s;	m[5]=y*y*(1-c)+c;		m[9]=y*z*(1-c)-x*s;	 	m[13]=0;
	m[2]=x*z*(1-c)-y*s;		m[6]=y*z*(1-c)+x*s;	m[10]=z*z*(1-c)+c;		m[14]=0;
	m[3]=0;						m[7]=0	;					m[11]=0;						m[15]=1;
	return m;
}

mat4x4 make_identity(mat4x4 m){
	return make_scale(m,1,1,1);
}

mat4x4 mult_matrix(mat4x4 m2,mat4x4 m1,mat4x4 m){
	m=m?m:create_mat4x4();
	scalar a11,a21,a31,a41,a12,a22,a32,a42,a13,a23,a33,a43,a14,a24,a34,a44;
	scalar b11,b12,b13,b14,b21,b22,b23,b24,b31,b32,b33,b34,b41,b42,b43,b44;
	/*get m1*/
	a11=m1[0];a21=m1[1];a31=m1[2];a41=m1[3];
	a12=m1[4];a22=m1[5];a32=m1[6];a42=m1[7];
	a13=m1[8];a23=m1[9];a33=m1[10];a43=m1[11];
	a14=m1[12];a24=m1[13];a34=m1[14];a44=m1[15];
	/*get m2*/
	b11=m2[0];b12=m2[1];b13=m2[2];b14=m2[3];
	b21=m2[4];b22=m2[5];b23=m2[6];b24=m2[7];
	b31=m2[8];b32=m2[9];b33=m2[10];b34=m2[11];
	b41=m2[12];b42=m2[13];b43=m2[14];b44=m2[15];
	/*m=m2*m1*/
	m[0]=a11*b11+a21*b21+a31*b31+a41*b41;
	m[1]=a11*b12+a21*b22+a31*b32+a41*b42;
	m[2]=a11*b13+a21*b23+a31*b33+a41*b43;
	m[3]=a11*b14+a21*b24+a31*b34+a41*b44;
	m[4]=a12*b11+a22*b21+a32*b31+a42*b41;
	m[5]=a12*b12+a22*b22+a32*b32+a42*b42;
	m[6]=a12*b13+a22*b23+a32*b33+a42*b43;
	m[7]=a12*b14+a22*b24+a32*b34+a42*b44;
	m[8]=a13*b11+a23*b21+a33*b31+a43*b41;
	m[9]=a13*b12+a23*b22+a33*b32+a43*b42;
	m[10]=a13*b13+a23*b23+a33*b33+a43*b43;
	m[11]=a13*b14+a23*b24+a33*b34+a43*b44;
	m[12]=a14*b11+a24*b21+a34*b31+a44*b41;
	m[13]=a14*b12+a24*b22+a34*b32+a44*b42;
	m[14]=a14*b13+a24*b23+a34*b33+a44*b43;
	m[15]=a14*b14+a24*b24+a34*b34+a44*b44;
	return m;
}

vec4 apply_mat(mat4x4 m1,vec4 v1, vec4 v){
	scalar a11,a21,a31,a41,a12,a22,a32,a42,a13,a23,a33,a43,a14,a24,a34,a44;
	scalar b1,b2,b3,b4;
	v=v?v:create_vec4(0,0,0);
	/*get m1*/
	a11=m1[0];a21=m1[1];a31=m1[2];a41=m1[3];
	a12=m1[4];a22=m1[5];a32=m1[6];a42=m1[7];
	a13=m1[8];a23=m1[9];a33=m1[10];a43=m1[11];
	a14=m1[12];a24=m1[13];a34=m1[14];a44=m1[15];
	/*get v1*/
	b1=v1[0];b2=v1[1];b3=v1[2];b4=v1[3];
	v[0]=a11*b1+a12*b2+a13*b3+a14*b4;
	v[1]=a21*b1+a22*b2+a23*b3+a24*b4;
	v[2]=a31*b1+a32*b2+a33*b3+a34*b4;
	return v;
}

mat4x4 clone_mat4x4(mat4x4 src,mat4x4 dst){
	if(dst==src){ return dst;	}
	if(!src) return src;
	dst=dst?dst:create_mat4x4(0,0,0);
	int i;
	for(i=0;i<16;i++){dst[i]=src[i];}
	return dst;	
}

static scalar PI=3.1415926535898;
static scalar D_PI=6.2831853071796;


mat4x4 push_and_apply_matrix(mat4x4 m){
	mat4x4 top_matrix=MATRIX_STACK+(MATRIX_STACK_TOP<<4);
	glGetFloatv(GL_MODELVIEW_MATRIX,top_matrix);
	++MATRIX_STACK_TOP;
	glMultMatrixf(m);
	return top_matrix;
}

mat4x4 pop_matrix(void){
	mat4x4 top_matrix;
	--MATRIX_STACK_TOP;
	top_matrix=MATRIX_STACK+(MATRIX_STACK_TOP<<4);
	glLoadMatrixf(top_matrix);
	return top_matrix;
}

GLuint push_and_apply_texture(GLuint t){
	TEXTURE_STACK[++TEXTURE_STACK_TOP]=t;
	//~ glActiveTextureARB(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, t );
	//~ glUniform1iARB(texUniform,0);
	return t;
}

GLuint pop_texture(void){
	//~ glActiveTextureARB(GL_TEXTURE0);
	GLuint id=TEXTURE_STACK[--TEXTURE_STACK_TOP];
	glBindTexture(GL_TEXTURE_2D,id);
	return id;
}

int my_init(unsigned int matrix_max,unsigned int texture_max){
//~ int my_init(void){
	GLenum glew_state;
	glew_state=glewInit();
	if(GLEW_OK!=glew_state) {printf("Error Loading GLEW: %d",GLEW_OK);return 1;}
	MATRIX_STACK=(scalar*)malloc(sizeof(scalar)*16*matrix_max);
	TEXTURE_STACK=(GLuint*)malloc(sizeof(GLuint)*texture_max);
	MATRIX_STACK_TOP=0;
	TEXTURE_STACK_TOP=0;
	glClearDepth(1.0);            // Depth Buffer Setup
	glEnable(GL_DEPTH_TEST);   // Enables Depth Testing
	glDepthFunc(GL_LEQUAL);    // The Type Of Depth Testing To Do
	glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);
	glEnable(GL_NORMALIZE);
	glAlphaFunc(GL_GREATER,0.1); 
	glEnable(GL_TEXTURE_2D); // always enable textures
	return 0;
}

int gl_set_viewport(int x,int y,int w, int h){
	glViewport(x,y,w,h);
	return 0;
}

camera_type create_camera(void){
	return (camera_type)malloc(sizeof(camera_type_));
}

camera_type make_camera(camera_type c, scalar x, scalar y, scalar z, scalar dist ){
	mat4x4 m;
	c=c?c:create_camera();
	/*c->X,Y,Z,T*/\
	c->X=create_vec4(1,0,0);
	c->Y=create_vec4(0,1,0);
	c->Z=create_vec4(0,0,1);
	c->T=create_vec4(x,y,z);
	c->dist=dist;
	c->h=0;
	c->v=0;
	/*c->projection*/
	m=create_mat4x4();
	c->projection=m;
	/*c->view*/
	m=create_mat4x4();
	c->view=m;
	/*c->bias*/
	m=make_scale(create_mat4x4(),0.5,0.5,0.5);
	m[12]=0.5;	m[13]=0.5; m[14]=0.5;
	c->bias=m;
	return c;
}

camera_type move_camera(camera_type c,scalar right, scalar up, scalar back){
	scalar rate;
	vec4 v,t;
	t=c->T; 	rate=c->dist;
	if(right!=0){ 	right*=rate; v=c->X; t[0]+=right*v[0];t[1]+=right*v[1];t[2]+=right*v[2];} /* T=T0+right*X */
	if(up!=0){up*=rate; t[1]+=up;}
	if(back!=0){back*=rate; v=c->Z; t[0]+=back*v[0];t[2]+=back*v[2];}
	return c;
}

camera_type rotate_camera(camera_type c,scalar dh,scalar dv){
	scalar h,v,hc,hs,vc,vs;
	vec4 x,y,z;
	h=(c->h)+dh; v=(c->v)+dv;
	while(h>PI)h-=D_PI;	while(h<-PI)h+=D_PI;	
	while(v>PI)v-=D_PI;	while(v<-PI)v+=D_PI;	
	x=c->X;	y=c->Y;	z=c->Z;
	hc=cos(h);	hs=sin(h);	vc=cos(v);	vs=sin(v);
	z[0]=hs*vc;	z[1]=vs;	z[2]=hc*vc;
	x[0]=hc;x[1]=0;x[2]=-hs;
	y=cross(z,x,y);
	c->h=h;	c->v=v;
	return c;
}

camera_type scale_camera(camera_type c,scalar s){
	c->dist*=s;
	return c;
}

camera_type set_camera_position(camera_type c, scalar x, scalar y, scalar z){
	vec4 pos=c->T;
	pos[0]=x; 	pos[1]=y; 	pos[2]=z; 	
	return c;
}

camera_type resize_camera(camera_type c, scalar w, scalar h){
	mat4x4 proj=c->projection;
	proj[0]*=w;
	proj[5]*=h;
	return c;
}


void print_matrix(mat4x4 m){
	int i;
	for(i=0;i<4;i++){
		printf("\n%f\t%f\t%f\t%f",m[i],m[i+4],m[i+8],m[i+12]);
	}
	printf("\n");
}


/* http://blog.csdn.net/gnuser/article/details/5146598 */
camera_type set_camera_projection(camera_type c,scalar near,scalar far,scalar fov,scalar wh){
	mat4x4 proj;
	proj=c->projection;
	scalar right,top;
	top=near*tan(fov/2);	right=wh*top;
	proj[0]=near/right;		proj[1]=0;					proj[2]=0;		proj[3]=0;
	proj[4]=0;						proj[5]=near/top;		proj[6]=0;		proj[7]=0;
	proj[8]=0;						proj[9]=0;					proj[10]=(far+near)/(near-far);	proj[11]=-1;
	proj[12]=0;					proj[13]=0;				proj[14]=2*far*near/(near-far);	proj[15]=0; 
	return c;
}

camera_type set_camera_direction(camera_type c, scalar x, scalar y, scalar z,scalar upx,scalar upy,scalar upz){
	vec4 X,Y,Z;
	X=c->X; 	Y=c->Y; 	Z=c->Z; 
	Z[0]=-x;	Z[1]=-y;	Z[2]=-z;
	Y[0]=upx; Y[1]=upy;	Y[2]=upz;
	cross(Y,Z,X); 	cross(Z,X,Y);
	normalize(X); normalize(Y); normalize(Z); 
	return c;
}

camera_type update_camera(camera_type c){
	mat4x4 view;
	vec4 x,y,z,t,v;
	scalar d;
	view=c->view;
	x=c->X; 	y=c->Y; 	z=c->Z; 	t=c->T;
	d=c->dist;
	v=TEMP_VEC4;
	v[0]=-d*z[0]-t[0]; v[1]=-d*z[1]-t[1];	v[2]=-d*z[2]-t[2];
	// get invert matrix 
	view[0]=x[0];				view[1]=y[0];				view[2]		=z[0];			view[3]=0;
	view[4]=x[1];				view[5]=y[1];				view[6]		=z[1];			view[7]=0;
	view[8]=x[2];				view[9]=y[2];				view[10]	=z[2];			view[11]=0;
	view[12]=dot(v,x,3);	view[13]=dot(v,y,3);	view[14]=dot(v,z,3);	view[15]=1;	
	return c;
}

camera_type camera_look(camera_type c){
	/* set projection matrix*/
	glMatrixMode(GL_PROJECTION);
	glLoadMatrixf(c->projection);
	glMultMatrixf(c->view);
	 /* set modelview matrix*/
	glMatrixMode(GL_MODELVIEW);
	//~ glLoadIdentity();
	return c;
}

int gl_options(int op){
	if(op&TEXTURE_2D){glEnable(GL_TEXTURE_2D);}else{ glDisable(GL_TEXTURE_2D);}
	if(op&LIGHTING){glEnable(GL_LIGHTING);}else{ glDisable(GL_LIGHTING);}
	if(op&CULL_FACE){glEnable(GL_CULL_FACE);}else{ glDisable(GL_CULL_FACE);}
	if(op&BLEND){glEnable(GL_BLEND);}else{ glDisable(GL_BLEND);}
	if(op&FOG){glEnable(GL_FOG);}else{ glDisable(GL_FOG);}
	if(op&FILL){glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);}else{glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);}
	if(op&SMOOTH){glShadeModel(GL_SMOOTH);}else{glShadeModel(GL_FLAT);}
	return 0;
}

int gl_set_light(int id,scalar x,scalar y,scalar z,scalar w){
	TEMP_VEC4[0]=x; TEMP_VEC4[1]=y; TEMP_VEC4[2]=z; TEMP_VEC4[3]=w;
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glEnable(GL_LIGHT0);
	switch(id){
		case 0: glLightfv (GL_LIGHT0, GL_POSITION, TEMP_VEC4);			break;
		default: break;
	}
	return 0;
}

int gl_clear_all(void){
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
	return 0;
}

int gl_set_bg_color(unsigned char r,unsigned char g,unsigned char b,unsigned char a){
	glClearColor (r/255.0, g/255.0, b/255.0, a/255.0);
	return 0;
}


/* texture */
texture_type gen_mem_img(unsigned int w,unsigned int h){
	texture_type tex=(texture_type)malloc(sizeof(texture_type_));
	w=w>0?w:1;	h=h>0?h:1;
	tex->data=(unsigned char*)malloc(w*h*4);
	tex->w=w;	tex->h=h;
	return tex;
}

texture_type set_mem_img_color(texture_type tex, unsigned int x,unsigned int y, unsigned char r,unsigned char g,unsigned char b,unsigned char a ){
	unsigned char * p;
	if(!tex){
		tex=gen_mem_img(1,1);
		p=tex->data;
	}else{
		p=(tex->data)+(y*(tex->w)+x)*4;
	}
	p[0]=r;	p[1]=g;	p[2]=b;	p[3]=a;	
	return tex;
}

GLuint mem_img2texture(texture_type tex){
	GLuint id;
	glGenTextures(1, &id);
	glBindTexture(GL_TEXTURE_2D, id );
	glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, tex->w,tex->h, 0,  GL_RGBA, GL_UNSIGNED_BYTE, tex->data );
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	free(tex->data);
	free(tex);
	return id;
}

GLuint img2texture(char const *filepath){
	GLuint id;
	unsigned int w,h,comp;
	unsigned char *data;
	data=stbi_load(filepath,&w,&h,&comp,4);
	if(!data){
		printf("Error when loading file: %s",filepath);
		return 0;
	}
	glGenTextures(1, &id);
	glBindTexture(GL_TEXTURE_2D, id );
	glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,w,h, 0,  GL_RGBA, GL_UNSIGNED_BYTE, data );
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	free(data);
	return id;
}
/* call list */
GLuint begin_gen_calllist(void){
	GLuint id;
	id = glGenLists (1);//glGenLists()唯一的标识一个显示列表
	glNewList(id, GL_COMPILE);
	return id;
}

GLuint end_gen_calllist(void){
	glEndList();
	return 0;
}
GLuint call_list(GLuint id){
	glCallList(id);
	return id;
}
/* drawer */

int begin_draw(int type){
	switch(type){
		case POINTS: glBegin(GL_POINTS); break;
		case LINES: glBegin(GL_LINES); break;
		case POLYGON: glBegin(GL_POLYGON); break;
		case TRIANGLES: glBegin(GL_TRIANGLES); break;
		case QUADS: glBegin(GL_QUADS); break;
		case LINE_STRIP: glBegin(GL_LINE_STRIP); break;
		case LINE_LOOP: glBegin(GL_LINE_LOOP); break;
		case TRIANGLE_STRIP: glBegin(GL_TRIANGLE_STRIP); break;
		case TRIANGLE_FAN: glBegin(GL_TRIANGLE_FAN); break;
		case QUAD_STRIP: glBegin(GL_QUAD_STRIP); break;
		default: break;
	}
	return type;
}
int end_draw(void){
	glEnd();
}

int set_vertex(scalar x,scalar y,scalar z,scalar tx,scalar ty, scalar nx, scalar ny, scalar nz){
	glTexCoord2f(tx,ty);
	glNormal3f(nx,ny,nz);
	glVertex3f(x,y,z);
	return 0;
}

int draw_box(scalar r){
	glBegin(GL_QUADS);
	/* top */
	set_vertex(r,r,r,0,0,0,1,0);set_vertex(r,r,-r,0,1,0,1,0);set_vertex(-r,r,-r,1,1,0,1,0);set_vertex(-r,r,r,1,0,0,1,0);
	/* bottom */
	set_vertex(r,-r,r,0,0,0,-1,0);set_vertex(-r,-r,r,0,1,0,-1,0);set_vertex(-r,-r,-r,1,1,0,-1,0);set_vertex(r,-r,-r,1,0,0,-1,0);
	/* left */
	set_vertex(-r,r,r,0,0,-1,0,0);set_vertex(-r,r,-r,0,1,-1,0,0);set_vertex(-r,-r,-r,1,1,-1,0,0);set_vertex(-r,-r,r,1,0,-1,0,0);
	/* right */
	set_vertex(r,r,r,0,0,1,0,0);set_vertex(r,-r,r,0,1,1,0,0);set_vertex(r,-r,-r,1,1,1,0,0);set_vertex(r,r,-r,1,0,1,0,0);
	/* front */
	set_vertex(r,r,r,0,0,0,0,1);set_vertex(-r,r,r,0,1,0,0,1);set_vertex(-r,-r,r,1,1,0,0,1);set_vertex(r,-r,r,1,0,0,0,1);
	/* back */
	set_vertex(r,r,-r,0,0,0,0,-1);set_vertex(r,-r,-r,0,1,0,0,-1);set_vertex(-r,-r,-r,1,1,0,0,-1);set_vertex(-r,r,-r,1,0,0,0,-1);
	glEnd();
	return 0;
}

int draw_plane(scalar r){
	glBegin(GL_QUADS);
	set_vertex(r,0,r,0.0,0.0,0,1,0);set_vertex(r,0,-r,0.0,1.0,0,1,0);set_vertex(-r,0,-r,1.0,1.0,0,1,0);set_vertex(-r,0,r,1.0,0.0,0,1,0);
	glEnd();
	return 0;
}

GLhandleARB compile_shader(const char* string,GLenum type){
	GLhandleARB handle;
	GLint result;				// Compilation code result
	GLint errorLoglength;
	char* errorLogText;
	GLsizei actualErrorLogLength;
	
	handle = glCreateShaderObjectARB(type);
	if (!handle){
		//We have failed creating the vertex shader object.
		printf("Failed creating vertex shader object!");
		return 0;
	}
	glShaderSourceARB(handle, 1, &string, 0);
	glCompileShaderARB(handle);
	//Compilation checking.
	glGetObjectParameterivARB(handle, GL_OBJECT_COMPILE_STATUS_ARB, &result);
	if (!result)
	{
		printf("Failed to compile shader:");
		glGetObjectParameterivARB(handle, GL_OBJECT_INFO_LOG_LENGTH_ARB, &errorLoglength);
		errorLogText = malloc(sizeof(char) * errorLoglength);
		glGetInfoLogARB(handle, errorLoglength, &actualErrorLogLength, errorLogText);
		printf("%s\n",errorLogText);
		free(errorLogText);
	}
	return handle;
}


GLhandleARB build_shader(const char* vert,const char* frag){
	GLhandleARB shadowShaderId;
	shadowShaderId = glCreateProgramObjectARB();
	glAttachObjectARB(shadowShaderId,vert?compile_shader(vert,GL_VERTEX_SHADER):0);
	glAttachObjectARB(shadowShaderId,frag?compile_shader(frag,GL_FRAGMENT_SHADER):0);
	glLinkProgramARB(shadowShaderId);
	return shadowShaderId;
}

GLhandleARB apply_shader(GLhandleARB shaderid){
	glUseProgramObjectARB(shaderid);
	return shaderid;
}


static GLuint shadowmapTex=0;
static GLuint SHADOW_MAP_WIDTH=2048;
static GLuint SHADOW_MAP_HEIGHT=2048;
static GLuint shadowmapFBO=0;



render_type create_render(GLuint width, GLuint height,int render_mode){
	render_type r;
	r=(render_type)malloc(sizeof(render_type_));
	glGenFramebuffersEXT(1, &(r->FBO));
	r->depth_tex=0;
	r->color_tex=0;
	return resize_tex(r,width,height,render_mode);
}

render_type resize_tex(render_type r,GLuint width, GLuint height,int render_mode){
	glEnable(GL_TEXTURE_2D);
	if(render_mode&DEPTH){
		if(r->depth_tex) glDeleteTextures(1,&(r->depth_tex));
		glGenTextures(1, &(r->depth_tex));
		glBindTexture(GL_TEXTURE_2D, (r->depth_tex) );
		glTexImage2D(GL_TEXTURE_2D,0,GL_DEPTH_COMPONENT,width,height,0,GL_DEPTH_COMPONENT,GL_UNSIGNED_BYTE,NULL);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP);  
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP);  
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);  
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);  
	}
	if(render_mode&COLOR){
		if(r->color_tex) glDeleteTextures(1,&(r->color_tex));
		glGenTextures(1, &(r->color_tex));
		glBindTexture(GL_TEXTURE_2D, (r->color_tex) );
		glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA,width,height,0,GL_RGBA,GL_UNSIGNED_BYTE,NULL);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP);  
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP);  
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);  
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);  
	}
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, r->FBO);
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_TEXTURE_2D, r->depth_tex, 0);
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, r->color_tex, 0); 
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	return r;
}

render_type apply_render(render_type r){
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, r?(r->FBO):0);
	return r;
}

int build_shadowmap(camera_type light,render_type r){
	// draw to shadowmap texture
	//~ glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, shadowmapFBO);
	apply_render(r);
	glPushAttrib(GL_VIEWPORT_BIT | GL_COLOR_BUFFER_BIT);
	glClear( GL_DEPTH_BUFFER_BIT);
	glViewport(0,0,SHADOW_MAP_WIDTH,SHADOW_MAP_HEIGHT);
	glCullFace(GL_FRONT); // only draw back faces
	camera_look(light);
	glUseProgramObjectARB(0);
	return 0;
}

int bind_shadowmap(camera_type light,GLhandleARB shader,render_type r){
	// return to normal rendering
	glPopAttrib();
	glCullFace(GL_BACK);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	// Go back to normal matrix mode
	glCullFace(GL_BACK);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	// apply shader and set bind TEXTURE1: shadowmap
	glUseProgramObjectARB(shader);
	glActiveTextureARB(GL_TEXTURE1);
	//~ glBindTexture(GL_TEXTURE_2D, shadowmapTex);
	glBindTexture(GL_TEXTURE_2D, r->depth_tex);
	glUniform1iARB(glGetUniformLocationARB(shader,"shadowmap"),  1); 
	glUniform1iARB(glGetUniformLocationARB(shader,"tex"),  0); 
	// set texture matrix for texture1
	glMatrixMode(GL_TEXTURE);
	glLoadIdentity();	
	glLoadMatrixf(light->bias);
	glMultMatrixf (light->projection);
	glMultMatrixf (light->view);
	glActiveTextureARB(GL_TEXTURE0);
	return 0;
}

scalar* make_vector_n(index_t n){
	return (scalar*)malloc(n*sizeof(scalar));
}

scalar* make_knots(index_t n,index_t p){
	index_t i,length;
	if(n<=p){
		return 0;
	}
	length=n+p+1;
	scalar* knots=make_vector_n(length);
	for(i=0;i<p+1;i++) knots[i]=0;
	for(i=p+1;i<;i++) knots[i]=i-p;
	for(i=0;i<p+1;i++) knots[length-i-1]=0;
	return knots;
}
unsigned int find_span(index_t n,index_t p,scalar u,scalar* knots);
scalar* compute_N(scalar u,index_t p, scalar * knots,scalar * N);
