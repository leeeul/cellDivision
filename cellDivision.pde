PShader shader;
float tarX;
float nowX;

void setup() {
  size(700, 700, P2D);
}

void draw() {
  update(mouseX);

  background(255);
  filter(shader);
  println(frameRate);
}

void update(float x) {
  tarX = x;
  
  nowX += tarX>nowX ? (tarX-nowX)*0.005 : (tarX-nowX)*0.0005;
  //nowX += (tarX-nowX)*.005;
  
  shader = loadShader("cell.glsl");
  shader.set("u_time", millis()/1000.);
  shader.set("mag", constrain(map(nowX,width*.1,width*.9,21.2,1.5),1.5,21.2));
  shader.set("ran", 0.0);
  shader.set("noi", constrain(map(nowX,width*.1,width*.9,-1.5, 1.0),0.1, 1.));//map(x,0,width,0.01, 0.3));
  shader.set("wei", map(nowX,0,width, 70.,5.));
}