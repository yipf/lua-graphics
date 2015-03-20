#include "yipf-img-gl.h"

img_type creat_img(){
	img_type img=(img_type)malloc(sizeof(img_type_));
	return img;
}

int delete_img(img_type img){
	if(img->data){
		free(img->data);
	}
	free(img);
	return 0;
}

int save_img(img_type img,const char* filepath){
	return  stbi_write_png (filepath, img->x, img->y, img->comp, img->data, img->stride_bytes);
}


img_type load_img(char const *filepath,int req_comp){
	img_type img=creat_img();
	img->data=stbi_load (filepath,  &(img->x), &(img->y), &(img->comp), req_comp);
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

scalar dot(vec4 v1,vec4 v2){
	scalar d=0;
	int i;
	for(i=0;i<3;i++){d=d+v1[i]*v2[i];}
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

vec4 clone_vec4(vec4 src,vec4 dst){
	if(!src) return src;
	dst=dst?dst:create_vec4(0,0,0);
	int i;
	for(i=0;i<4;i++){dst[i]=src[i];	}
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
	m[0]=sz;	m[1]=0;	m[2]=0;	m[3]=0;
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
	if(!src) return src;
	dst=dst?dst:create_mat4x4(0,0,0);
	int i;
	for(i=0;i<16;i++){dst[i]=src[i];}
	return dst;	
}

mat4x4 invert_mat(mat4x4 m,mat4x4 inv){
	inv=inv?inv:create_mat4x4();
	inv[0]=m[0];	inv[1]=m[4];		inv[2]=m[8];								inv[3]=0;
	inv[4]=m[1];	inv[5]=m[5];		inv[6]=m[9];								inv[7]=0;
	inv[8]=m[2];	inv[9]=m[6];		inv[10]=m[10];							inv[11]=0;
	inv[12]=-m[12];		inv[13]=-m[13];			inv[14]=-m[14];			inv[15]=1;
	return inv;
}

int my_init(void){
	GLenum glew_state=glewInit();
	if(GLEW_OK!=glew_state) return 1;
	PI=rad(180); 
	D_PI=rad(360); 
	return 0;
}

camera_type create_camera(void){
	return (camera_type)malloc(sizeof(camera_type_));
}

camera_type make_camera(camera_type c, scalar x, scalar y, scalar z, scalar dist ){
	mat4x4 m;
	c=c?c:create_camera();
	/*c->X,Y,Z,T*/\
	c->X=create_vec4(-1,0,0);
	c->Y=create_vec4(0,1,0);
	c->Z=create_vec4(0,0,-1);
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
	return c;
}

camera_type move_camera(camera_type c,scalar left, scalar up, scalar front){
	scalar rate;
	vec4 v,t;
	t=c->T; 	rate=c->dist;
	if(left!=0){ 	left*=rate; v=c->X; t[0]+=left*v[0];t[1]+=left*v[1];t[2]+=left*v[2];} /* T=T0+left*X */
	if(up!=0){up*=rate; t[1]+=up;}
	if(front!=0){front*=rate; v=c->Z; t[0]+=front*v[8];t[2]+=front*v[10];}
	return c;
}

camera_type rotate_camera(camera_type c,scalar dh,scalar dv){
	scalar h,v,hc,hs,vc,vs;
	vec4 x,y,z;
	h=(c->h)+dh; v=(c->v)+dv;
	while(h>PI)h-=D_PI;	while(h<-PI)h+=D_PI;	
	while(v>PI)v-=D_PI;	while(v<-PI)v+=D_PI;	
	hc=cos(h);	hs=sin(h);	vc=cos(v);	vs=sin(v);
	x=c->X;	y=c->Y;	z=c->Z;
	z[0]=-hs*vc;	z[1]=-vs;	z[2]=-hc*vc;
	y[0]=-hs*vs;	y[0]=vc;	y[0]=-hc*vs;
	x=cross(z,y,x);
	c->h=h;	c->v=v;
	return c;
}

camera_type scale_camera(camera_type c,scalar s){
	c->dist*=s;
	return c;
}


/* http://blog.csdn.net/gnuser/article/details/5146598 */
camera_type set_camera_projection(camera_type c,scalar near,scalar far,scalar fov,scalar wh){
	mat4x4 proj;
	proj=c->projection;
	scalar right,top;
	top=near*tan(fov);	right=wh*top;
	proj[0]=near/right;		proj[1]=0;					proj[2]=0;		proj[3]=0;
	proj[4]=0;						proj[5]=near/top;		proj[6]=0;		proj[7]=0;
	proj[8]=0;						proj[9]=0;					proj[10]=(far+near)/(near-far);	proj[11]=-1;
	proj[12]=0;					proj[13]=0;				proj[14]=2*far*near/(near-far)	;	proj[15]=0; 
	return c;
}

camera_type update_camera_observe(camera_type c){
	mat4x4 view;
	view=c->view;
	vec4 x,y,z,t;
	scalar d;
	x=c->X; 	y=c->Y; 	z=c->Z; 	t=c->T; 	
	d=c->dist;
	view[0]=x[0];				view[1]=y[0];				view[2]		=z[0];			view[3]=0;
	view[4]=x[1];				view[5]=y[1];				view[6]		=z[1];			view[7]=0;
	view[8]=x[2];				view[9]=y[2];				view[10]	=z[2];			view[11]=0;
	view[12]=d*z[0]-t[0];	view[13]=d*z[1]-t[1];	view[14]=d*z[2]-t[2];	view[15]=1;
	return c;
}

camera_type update_camera_fps(camera_type c){
	mat4x4 view;
	view=c->view;
	vec4 x,y,z,t;
	scalar d;
	x=c->X; 	y=c->Y; 	z=c->Z; 	t=c->T; 	
	d=c->dist;
	view[0]=x[0];		view[1]=y[0];		view[2]		=z[0];		view[3]=0;
	view[4]=x[1];		view[5]=y[1];		view[6]		=z[1];		view[7]=0;
	view[8]=x[2];		view[9]=y[2];		view[10]	=z[2];		view[11]=0;
	view[12]=-t[0];	view[13]=-t[1];	view[14]=-t[2];	view[15]=1;
	return c;
}

camera_type update_camera(camera_type c){
	return update_camera_observe(c);
}

camera_type camera_look(camera_type c){
	/* set projection matrix*/
	glMatrixMode(GL_PROJECTION_MATRIX);
	glLoadMatrixf(c->projection);
	/* set modelview matrix*/
	glMatrixMode(GL_MODELVIEW_MATRIX);
	glLoadMatrixf(c->view);
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

int set_light(int id,scalar x,scalar y,scalar z,scalar w){
	vec4 pos=create_vec4(x,y,z);
	pos[3]=w;
	switch(id){
		case 0:
			glLightfv (GL_LIGHT0, GL_POSITION, pos);
			break;
		default: break;
	}
	return 0;
}

int gl_clear_all(void){
	glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
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
	p[0]=r;	p[0]=g;	p[0]=b;	p[0]=a;	
	return tex;
}
unsigned int mem_img2texture(texture_type tex){
	unsigned int id;
	glGenTextures(1, &id);
	glBindTexture(GL_TEXTURE_2D, id );
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, tex->w,tex->h, 0, GL_RGBA, GL_UNSIGNED_BYTE, tex->data );
	free(tex->data);
	free(tex);
	return id;
}

unsigned int img2texture(char const *filepath){
	unsigned int id;
	return id;
}
/* call list */
int begin_gen_calllist(void){
	int id;
	return id;
}
int end_gen_calllist(void){
	return 0;
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
int end_draw(int type){
	glEnd();
	return type;
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
	set_vertex(r,r,r,0,0,1,0,0);set_vertex(r,-r,r,0,1,1,0,0);set_vertex(r,-r,-r,1,1,1,0,0);set_vertex(-r,r,-r,1,0,1,0,0);
	/* front */
	set_vertex(r,r,r,0,0,0,0,1);set_vertex(-r,r,r,0,1,0,0,1);set_vertex(-r,-r,r,1,1,0,0,1);set_vertex(r,-r,r,1,0,0,0,1);
	/* back */
	set_vertex(r,r,-r,0,0,0,0,-1);set_vertex(r,-r,-r,0,1,0,0,-1);set_vertex(-r,-r,-r,1,1,0,0,-1);set_vertex(-r,r,-r,1,0,0,0,-1);
	glEnd();
	return 0;
}
