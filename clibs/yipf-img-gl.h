
typedef unsigned int GLuint;
typedef float GLfloat;
typedef float GLclampf;

typedef void* data_type;
typedef struct img_type_{ int x; int y; int comp; int stride_bytes; data_type data;} img_type_;
typedef img_type_* img_type;

img_type creat_img();
int delete_img(img_type img);
int save_img(img_type img,const char* filepath);
img_type load_img(char const *filepath,int req_comp);

typedef GLfloat scalar;
typedef scalar* vec4;
typedef scalar* mat4x4;


/* vec functions*/
vec4 create_vec4(scalar x,scalar y,scalar z);
int destroy_vec4(vec4 v);
vec4 cross(vec4 v1,vec4 v2,vec4 v);
scalar dot(vec4 v1,vec4 v2,int n);
scalar norm(vec4 v);
vec4 normalize(vec4 v);
vec4 clone_vec4(vec4 src,vec4 dst,int n);

/* matrix functions*/
mat4x4 create_mat4x4();
int destroy_mat4x4(mat4x4 m);
mat4x4 make_translate(mat4x4 m,scalar tx,scalar ty,scalar tz);
mat4x4 make_scale(mat4x4 m,scalar sx,scalar sy,scalar sz);
mat4x4 make_rotate(mat4x4 m,scalar rx,scalar ry,scalar rz,scalar ang);
mat4x4 make_identity(mat4x4 m);
mat4x4 mult_matrix(mat4x4 m2,mat4x4 m1,mat4x4 m);/*	m*v=m2*m1*v  */
mat4x4 clone_mat4x4(mat4x4 src,mat4x4 dst);
vec4 apply_mat(mat4x4 m,vec4 v, vec4 result);/* v=m*v1 */
void print_matrix(mat4x4 m);
/* OpenGL helper*/
unsigned int push_and_apply_matrix(mat4x4 m);

unsigned int push_and_apply_texture(GLuint t);

unsigned int pop_matrix(void);

unsigned int pop_texture(void);

int my_init(unsigned int matrix_max,unsigned int texture_max);

//~ typedef struct{mat4x4 cm; mat4x4 projection; mat4x4 view; vec4 target;} camera_type_;
typedef struct{ scalar h,v,dist; vec4 X,Y,Z,T,temp_vec4; mat4x4 projection; mat4x4 view;} camera_type_;
typedef camera_type_* camera_type;

camera_type create_camera(void);
camera_type make_camera(camera_type c, scalar x, scalar y, scalar z, scalar dist );

camera_type move_camera(camera_type c,scalar left, scalar up, scalar front);
camera_type rotate_camera(camera_type c,scalar h,scalar v);
camera_type scale_camera(camera_type c,scalar s);

camera_type set_camera_projection(camera_type c,scalar near,scalar far,scalar fov,scalar wh);
camera_type set_camera_position(camera_type c, scalar x, scalar y, scalar z);
camera_type resize_camera(camera_type c, scalar w, scalar h);

camera_type update_camera_observe(camera_type c);
camera_type update_camera_fps(camera_type c);

camera_type update_camera(camera_type c);

camera_type camera_look(camera_type c);

/* 2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536 */
enum{TEXTURE_2D=2,LIGHTING=4,CULL_FACE=8,BLEND=16,FILL=32,SMOOTH=64,FOG=128};

int gl_options(int op);
int gl_set_light(int id,scalar x,scalar y,scalar z,scalar w);
int gl_set_bg_color(unsigned char r,unsigned char g,unsigned char b,unsigned char a);
int gl_clear_all(void);
int gl_set_viewport(int x,int y,int w, int h);

/* texture */
typedef struct{unsigned char* data; unsigned w; unsigned h;} texture_type_;
typedef texture_type_* texture_type;
texture_type gen_mem_img(unsigned int w,unsigned int h);
texture_type set_mem_img_color(texture_type tex, unsigned int x,unsigned int y, unsigned char r,unsigned char g,unsigned char b,unsigned char a );
GLuint mem_img2texture(texture_type tex);
GLuint img2texture(char const *filepath);
/* call list */
GLuint begin_gen_calllist(void);
GLuint end_gen_calllist(void);
GLuint call_list(GLuint id);
/* drawer */
enum{POINTS,LINES,POLYGON,TRIANGLES,QUADS,LINE_STRIP,LINE_LOOP,TRIANGLE_STRIP,TRIANGLE_FAN,QUAD_STRIP};
int begin_draw(int type);
int end_draw(void);
int set_vertex(scalar x,scalar y,scalar z,scalar tx,scalar ty, scalar nx, scalar ny, scalar nz);
int draw_box(scalar r);
int draw_plane(scalar r);