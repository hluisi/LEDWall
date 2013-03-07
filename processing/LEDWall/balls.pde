ArrayList<BigBall> balls;
int ball_spectrum_count = 0;

void setupBalls() {
  balls = new ArrayList<BigBall>();
  PVector loc = new PVector(0,0);
  balls.add(new BigBall(loc, audio.EQ_DATA[AUDIO_MODE][ball_spectrum_count], ball_spectrum_count));
  println("BALLS SETUP ...");
}

void doBalls() {
  
  buffer.beginDraw();
  buffer.background(0);
  buffer.pushStyle();
  buffer.blendMode(ADD);
  
  
  if (ball_spectrum_count > 5) ball_spectrum_count = 0;
  PVector loc = kinect.user_center.get();
  
  
  //if (balls.size() > 256) balls.remove(0);
  
  balls.add(new BigBall(loc, audio.EQ_DATA[AUDIO_MODE][ball_spectrum_count], ball_spectrum_count));
    
  for (int i = 0; i < balls.size(); i++) {
    BigBall ball = balls.get(i);
    ball.run();

    if (ball.isDead()) balls.remove(i);
  }
  
  
  
  //kinect.updateUser(audio.COLORS[AUDIO_MODE]);
  kinect.updateUser(audio.COLOR[COLOR_MODE_NOBLACK]);
  buffer.blend(kinect.current_image,0,0,kinect.current_image.width,kinect.current_image.height,0,0,buffer.width,buffer.height,EXCLUSION);
  //buffer.image(kinect.current_image, 0, 0);
  buffer.popStyle();
  buffer.endDraw();
  ball_spectrum_count++;
}

class BigBall {
  PVector location;
  PVector velocity;
  PVector acceleration;

  float radius;
  color ball_color;
  //color ball_stroke;

  float lifespan;
  int spectrum;
  boolean update_color;

  BigBall(PVector start, int id, int spec) {
    float test = random(1);
    if (test < 0.35) {
      location = new PVector(random(buffer.width), random(buffer.height));
      update_color = false;
    } else {
      location = start.get();
      update_color = true;
    }
    velocity = new PVector(random( -1, 1), random( -1, 1));
    acceleration = new PVector();
    radius = map(id, 0, 1023, 0, buffer.height / 4);
    ball_color = audio.COLOR[COLOR_MODE]; //audio.COLORS[AUDIO_MODE];
    //ball_stroke = color(map(brightness(ball_color), 0, 255, 255, 0));
    lifespan = 255;
  }

  void check() {
    if (location.x < (0  - (radius /2)) || location.x > (buffer.width  + (radius /2)))  velocity.x *= -1;
    if (location.y < (0  - (radius /2)) || location.y > (buffer.height + (radius / 2))) velocity.y *= -1;
    
    //if (location.x < (0 - radius)) location.x = buffer.width + radius;
    //else if (location.x > (buffer.width + radius)) location.x = 0 - radius;
    //if (location.y < (0 - radius)) location.y = buffer.height + radius;
    //else if (location.y > (buffer.height + radius)) location.y = 0 - radius;
  }
  
  void applyForce(PVector force) {
    velocity.add(force);
  }
  
  void applyAttraction() {
    PVector force = PVector.sub(location, kinect.user_center);
    float distance = force.mag();
    distance = constrain(distance,5.0,5.0);
    force.normalize();
    float str = map(audio.EQ_DATA[AUDIO_MODE][spectrum], 0, 1023, 0, 0.5);
    force.mult(str);
    //force.mult(-1);
    applyForce(force);
  }
    
    
  void applyDrag() {
    float speed = velocity.mag();
    float dragMag = 0.05 * speed * speed;
    PVector drag = velocity.get();
    drag.mult(-1);
    drag.normalize();
    drag.mult(dragMag);
    applyForce(drag);
  }

  void update() {
    float push = map(audio.EQ_DATA[AUDIO_MODE][spectrum], 0, 1023, -1, 10);
    velocity.normalize(acceleration);
    acceleration.setMag(push);
    velocity.add(acceleration);
    //float test = random(1);
    applyAttraction();
    applyDrag();
    location.add(velocity);
    acceleration.mult(0);
    lifespan -= 1;
    if (update_color) ball_color = audio.COLOR[COLOR_MODE]; //audio.COLORS[AUDIO_MODE];
  }

  void display() {
    buffer.noStroke();
    //buffer.stroke(ball_stroke, lifespan);
    buffer.fill(ball_color, lifespan);
    buffer.ellipse(location.x, location.y, radius, radius);
  }

  void run() {
    update();
    check();
    display();
  }

  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    }
    else {
      return false;
    }
  }
}


