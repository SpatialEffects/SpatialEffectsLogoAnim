// by dave whyte

int[][] result;
float t;

void setup() {
  size(1280, 1024, P2D);
  smooth(8);
  noFill();

  result = new int[width*height][3];
}

void draw() {

  if (!recording) {
    t = mouseX * 1.0/width;
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



int N = 180; // resolution of the calculations
int n = 7; // frequency of the wave
float os;
float R = 165, r; // R = circle diameter
float th;
float progress;
color bg = color(42, 40, 38);

float ease(float q){
  return 3*q*q - 2*q*q*q;
}

void drawCircle(float q, float radiusFactor, float offset, float strokeWeight, float amplitudeFactor, int frequency, int resolution){
  strokeWeight(strokeWeight);

  beginShape();
  for (int i=0; i < resolution; i++) {
    progress = i * TWO_PI / resolution;
    os = map(cos(progress - TWO_PI * offset), -1, 1, 0, 1); // Normalize the cos between 0 to 1
    // The 2.75 below decides on what part of the circle the waves will be visible
    os = amplitudeFactor * pow(os, 2.75); // exponential multiplication of the cos, plus dim it down a bit -> this modulates the wave amplitude
    r = radiusFactor * (1 + os * cos(frequency * progress + 1.5 * TWO_PI + q)); // calculation of the final vertex distance from the center, modulates the circle diameter, inverts the wave via q if necessary
    vertex(r * sin(progress), -r * cos(progress)); // add a vertex according to the radius
  }
  endShape(CLOSE);
}

void drawCircles() {
  float mouseAngle, mouseDistance;

  PVector center = new PVector(0, 0);
  PVector baseVector = new PVector(0, -1); // Horizontal vector
  PVector mouseVector = new PVector(mouseX - width / 2, mouseY - height / 2); // mouse coords are not translated so we need to calculate it ourselves
  mouseAngle = angle(baseVector, mouseVector);
  mouseAngle = mouseAngle / TWO_PI; // Normalize
  mouseDistance = center.dist(mouseVector);

  mouseDistance = mouseDistance / 12500; // Scale it down

  for (int i = 0; i < 7; ++i) {
    float q = (i % 2) * PI;
    drawCircle(q, 100 + i * 50, mouseAngle, 1 + i * 5, mouseDistance, 14, N);
  }
}

float angle(PVector v1, PVector v2) {
  float a = atan2(v2.y, v2.x) - atan2(v1.y, v1.x);
  if (a < 0) a += TWO_PI;
  return a;
}

void draw_() {
  background(bg); // Fill the bg
  pushMatrix(); // start transformation
  translate(width/2, height/2); // center 
  stroke(230); // set color of the stroke
  drawCircles(); // draw the circles
  popMatrix(); // end transformation
}
