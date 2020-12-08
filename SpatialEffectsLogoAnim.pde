// by dave whyte

int[][] result;
float t;

void setup() {
  size(800, 600, P2D);
  smooth(8);
  noFill();

  result = new int[width*height][3];
}

void draw() {

  if (!recording) {
    t = mouseX*1.0/width;
    draw_();
  } else {
    for (int i=0; i<width*height; i++)
      for (int a=0; a<3; a++)
        result[i][a] = 0;

    for (int sa=0; sa<samplesPerFrame; sa++) {
      t = map(frameCount-1 + sa*shutterAngle/samplesPerFrame, 0, numFrames, 0, 1);
      draw_();
      loadPixels();
      for (int i=0; i<pixels.length; i++) {
        result[i][0] += pixels[i] >> 16 & 0xff;
        result[i][1] += pixels[i] >> 8 & 0xff;
        result[i][2] += pixels[i] & 0xff;
      }
    }

    loadPixels();
    for (int i=0; i<pixels.length; i++)
      pixels[i] = 0xff << 24 | 
        int(result[i][0]*1.0/samplesPerFrame) << 16 | 
        int(result[i][1]*1.0/samplesPerFrame) << 8 | 
        int(result[i][2]*1.0/samplesPerFrame);
    updatePixels();

    saveFrame("f###.gif");
    if (frameCount==numFrames)
      exit();
  }
}

//////////////////////////////////////////////////////////////////////////////

int samplesPerFrame = 4;
int numFrames = 144;        
float shutterAngle = .5;

boolean recording = false;



int N = 360; // resolution of the calculations
int n = 7; // period of the wave
float os;
float R = 165, r; // R = circle diameter
float th;
color bg = color(42, 40, 38);

float ease(float q){
  return 3*q*q - 2*q*q*q;
}

void drawCircle(float q){
  beginShape();
  for (int i=0; i<N; i++) { // Loop van 0 tot 359
    th = i*TWO_PI/N; // th = progress in radians rond de cirkel
    os = map(cos(th-TWO_PI*t), -1, 1, 0, 1); // map the cos to 0 to 1 instead of -1 to 1, progress is offset by mouse X coords
    os = 0.125*pow(os, 2.75); // exponential multiplication of the cos, plus dim it down a bit -> this modulates the wave height
    r = R*(1+os*cos(n*th + 1.5*TWO_PI*t + q)); // calculation of the final distance from the center, modulates the circle diameter, inverts the wave via q if necessary
    vertex(r*sin(th), -r*cos(th)); // draw the vertex according to 
  }
  endShape(CLOSE);
}

void drawCircle(float q, float radius, float offset, float strokeWeight){
  beginShape();
  for (int i=0; i<N; i++) { // Loop van 0 tot 359
    th = i*TWO_PI/N; // th = progress in radians rond de cirkel
    os = map(cos(th-TWO_PI*t), -1, 1, 0, 1); // map the cos to 0 to 1 instead of -1 to 1, progress is offset by mouse X coords
    os = 0.125*pow(os, 2.75); // exponential multiplication of the cos, plus dim it down a bit -> this modulates the wave height
    r = R*(1+os*cos(n*th + 1.5*TWO_PI*t + q)); // calculation of the final distance from the center, modulates the circle diameter, inverts the wave via q if necessary
    vertex(r*sin(th), -r*cos(th)); // draw the vertex according to 
  }
  endShape(CLOSE);
}

void drawCircles() {
  drawCircle(0);
  drawCircle(PI);
}

void draw_() {
  background(bg); // Fill the bg
  pushMatrix(); // start transformation
  translate(width/2, height/2); // center 
  stroke(230); // set color of the stroke
  strokeWeight(6); // set width of the stroke
  drawCircles(); // draw the circles
  popMatrix(); // end transformation
}
