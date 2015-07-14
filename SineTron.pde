//import ddf.minim.spi.*;
//import ddf.minim.signals.*;
import ddf.minim.*;
//import ddf.minim.analysis.*;
//import ddf.minim.ugens.*;
//import ddf.minim.effects.*;

import beads.*;
import java.util.Arrays;


Minim minim;
AudioPlayer sou;

AudioContext ac;
/*
 * Sine Wave
 * by Daniel Shiffman.   
 * 
 * Render a simple sine wave. 
 */
int playerObjectX; 
int playerObjectY; 
int xspacing = 20;   // How far apart should each horizontal location be spaced
int w;              // Width of entire wave
float theta = 0.0;  // Start angle at 0
float thetaInc = .02;
float thetaInc_2 = .02;
boolean theta_2Up = false; // the state for theta2 modulation
float amplitude;  // Height of wave
float period =10;  // How many pixels before the wave repeats
float dx;  // Value for incrementing X, a function of period and xspacing
float[] yvalues;  // Using an array to store height values for the wave
boolean ampUp = true; // state for amplitude modulation
boolean periodUp = false; // state for period modulation
int elipseXDim = 16;
int elipseYDim = 12;
boolean xDimUp = false;
boolean yDimUp = true;
boolean thetaUp = true;
float distHolder = 0;
float currentScore= 0;
float highScore = 0;
int distFromHigh = 0;
int rgbBackgroundR; 
int rgbBackgroundG; 
int rgbBackgroundB;
int redCoinAmt = 0;
int greenCoinAmt = 0;
int blueCoinAmt = 0;
int numOfYValues; // array for the sin circles
boolean lastCoinGrabLoc = false;
boolean theta_1_State = false;
boolean theta_2_State = false;
int initialTime;
int currentTime;
float timeRun=1;
float timeRunLast;
int levelTimeAmt = 30;
float playerHealth = 10;
boolean timeUp = false;
float multiplier = 1;
int multiplyDebouncer = 0;
int redHighScore = 0;
int greenHighScore = 0;
int blueHighScore = 0;
int sequencer1RandNum; // para for music
int sequencer2RandNum; // para for music
int sequencer3RandNum; // para for music
int sequencerMultiplyNum; // para for music
int seq3DiviserNum;
int playerLives = 2; 
boolean collisionActve = true;
boolean timerRing = false;
int harmNum;
int redIncrease = 0;
int greenIncrease = 0;
int blueIncrease = 0;
boolean playerDied = false;
int levelStage = 1;
int levelTimeDiviser = 1; // deals with points system 
float[] scoreGraph = new float[levelTimeAmt+1]; // array for visual time-to-pts graph



void setup() {
  frameRate(32);
  size(320, 568);

  w = width+16;  
  dx = (TWO_PI / period) * xspacing;
  yvalues = new float[w/xspacing];
  int initialTime = millis(); 
  generateAudio();
 
}


void draw() {  
    
  setCurrentTime();
  
  handleTimeChange();
  
  handleHighScore();
  
  setScoreGraph();    
 
  calcWave();
  
  renderWave();      

//      redIncrease = 0;
//      greenIncrease = 0;
//      blueIncrease = 0;          
    
 if(thetaInc<.02) {
    if(elipseXDim<=17 && xDimUp) {elipseXDim++;};
    if(elipseXDim==17) {xDimUp = false;};
    if(elipseXDim>8 && !xDimUp) {elipseXDim--;};
    if(elipseXDim==12) {xDimUp = true;};
  
    if(elipseYDim<=17 && yDimUp) {elipseYDim++;};
    if(elipseYDim==17) {yDimUp = false;};
    if(elipseYDim>12 && !yDimUp) {elipseYDim--;};
    if(elipseYDim==12) {yDimUp = true;};
 };    
   
  if(thetaInc<=.032 && thetaUp) {thetaInc = thetaInc + .0005;};
  if(thetaInc>=.032) {thetaUp = false;};
  if(thetaInc>.000 && !thetaUp) {thetaInc = thetaInc - .0005;};
  if(thetaInc<=.000) {thetaUp = true;};
  
  if(thetaInc_2<=.032 && theta_2Up) {thetaInc_2 = thetaInc_2 + .0004;};
  if(thetaInc_2>=.032) {theta_2Up = false;};
  if(thetaInc_2>.000 && !theta_2Up) {thetaInc_2 = thetaInc_2 - .0004;};
  if(thetaInc_2<=.000) {theta_2Up = true;};

  if(amplitude<=568 && ampUp) {amplitude++;};
  if(amplitude==568 ) {ampUp = false;};
  if(amplitude>-568 && !ampUp) {amplitude--;};
  if(amplitude==-568) {ampUp = true;};
  
   generateHUD();
       
       if(timeRun >=(levelTimeAmt-3)) { 
         if(currentTime%10==0) {
           fill(255,0,0);
           rect(0, 65,(levelTimeAmt-timeRun)*23 , 12);
         }                 
         textSize(64);
         fill(255);
         if(timeRun >= levelTimeAmt) {            
            text("Times \n Up" , width/4, height/2);
            if(!timerRing) {
               minim = new Minim(this);
               sou = minim.loadFile("glass_ping.wav");
                sou.play();
            };
            timerRing = true;
            timeUp = true;
         } else
            text(int(levelTimeAmt-timeRun) , width/2, height/2);
      };
            if(!timeUp) {
              if(playerLives>0) {
                playerCollision();
                renderPlayer();
              };
        
      };
      
};

void generateAudio() {
  ac = new AudioContext();
  sequencer1RandNum = int(random(1,12));
  sequencerMultiplyNum = int(random(1,12));
  seq3DiviserNum = int(random(1,4));
  sequencer2RandNum = sequencer1RandNum*sequencerMultiplyNum;
  sequencer3RandNum = sequencer1RandNum*sequencerMultiplyNum/seq3DiviserNum;
  Clock clock = new Clock(ac, 700);
  clock.addMessageListener(
  //this is the on-the-fly bead
  new Bead() {
    //this is the method that we override to make the Bead do something
    int pitch;
     public void messageReceived(Bead message) {
        Clock c = (Clock)message;
        if(c.isBeat()) {
          //choose some nice frequencies
          if(random(1) < 0.5) return;
          pitch = Pitch.forceToScale((int)random(12), Pitch.dorian);
          float freq = Pitch.mtof(pitch + (int)random(5) * 12 + 32);
          WavePlayer wp = new WavePlayer(ac, freq, Buffer.SINE);
          Gain g = new Gain(ac, 1, new Envelope(ac, 0));
          g.addInput(wp);
          ac.out.addInput(g);
          ((Envelope)g.getGainEnvelope()).addSegment(0.1, random(200));
          ((Envelope)g.getGainEnvelope()).addSegment(0, random(7000), new KillTrigger(g));
       }
       if(c.getCount() % sequencer3RandNum == 0) {
           //choose some nice frequencies
          int pitchAlt = pitch;
          if(random(1) < 0.2) pitchAlt = Pitch.forceToScale((int)random(12), Pitch.dorian) + (int)random(2) * 12;
          float freq = Pitch.mtof(pitchAlt + 32);
          WavePlayer wp = new WavePlayer(ac, freq, Buffer.SQUARE);
          Gain g = new Gain(ac, 1, new Envelope(ac, 0));
          g.addInput(wp);
          Panner p = new Panner(ac, random(1));
          p.addInput(g);
          ac.out.addInput(p);
          ((Envelope)g.getGainEnvelope()).addSegment(random(0.1), random(50));
          ((Envelope)g.getGainEnvelope()).addSegment(0, random(400), new KillTrigger(p));
       };
        if(c.getCount() % sequencer2RandNum == 0) {
          Noise n = new Noise(ac);
          Gain g = new Gain(ac, 1, new Envelope(ac, 0.05));
          g.addInput(n);
          Panner p = new Panner(ac, random(0.5, 1));
          p.addInput(g);
          ac.out.addInput(p);
          ((Envelope)g.getGainEnvelope()).addSegment(0, random(100), new KillTrigger(p));
       }
       if(c.getCount() % sequencer1RandNum == 0) {
          Noise n = new Noise(ac);
          Gain g = new Gain(ac, 1, new Envelope(ac, 0.01));
          g.addInput(n);
          Panner p = new Panner(ac, random(0.5, 1));
          p.addInput(g);
          ac.out.addInput(p);
          ((Envelope)g.getGainEnvelope()).addSegment(0, random(100), new KillTrigger(p));
       }
     } // end message recieved
   } //end new Bead
 ); // end addlistener
 ac.out.addDependent(clock);
 ac.start();
};

void setCurrentTime() {
  currentTime = millis();
  if(!timeUp) {
    playerHealth= playerHealth + .0225; 
  };
  
  if(currentTime<1000) { // one loop iteration is about 44ms
    currentTime = 1000;
  };
};
// gets the current time in increments of a second and updates the score graph, multiplier, and health
void handleTimeChange() {
  timeRun = (currentTime-initialTime)/1000;      
      if(timeRun != timeRunLast) { // increments the multipler and health
       if(!timeUp) {
         int h = int(timeRun);
          scoreGraph[h] = currentScore*.025;
       };
                      
        if(timeRun<=levelTimeAmt) {
          multiplier += pow(2, (timeRun/1*.075));
//          multiplier += (timeRun/1)*.1;
        };       
      };
       
      timeRunLast = timeRun;
};

void handleHighScore() {
  if(currentScore>highScore) {
      } else {
           rgbBackgroundR = rGBTemplateArray[(distFromHigh*3)];
           rgbBackgroundG = rGBTemplateArray[(distFromHigh*3+1)];
           rgbBackgroundB = rGBTemplateArray[distFromHigh*3+2]; 
           background(redCoinAmt, greenCoinAmt, blueCoinAmt, 255);
      };
      fill(64, 64, 64,175);
      rect(0, 0, 320, 568);
      if(currentScore>highScore) {
        highScore = currentScore;
         greenHighScore = greenCoinAmt;
         redHighScore = redCoinAmt;
         blueHighScore = blueCoinAmt;
        
      };
};

void setScoreGraph() {
   for(int i = 0; i < levelTimeAmt; i++) {
     fill(255,255,255,64);
     rect(i*5,520, 5, -scoreGraph[i]);
  };
};


void calcWave() {
  // Increment theta (try different values for 'angular velocity' here
  theta += thetaInc+thetaInc_2;

  // For every x value, calculate a y value with sine function
  float x = theta;
  for (int i = 0; i < yvalues.length; i++) {
    yvalues[i] = sin(x)*amplitude;
    x+=dx; // dx = .62831855
  }
};
   
void renderPlayer() {
  noStroke();
  fill(255);
  ellipse(pmouseX, pmouseY, 15, 15); 
};

void renderWave() {
  noStroke();  
  

  if(thetaInc<.018 && thetaInc_2 < .018) {        
    if(thetaInc<.015 && thetaInc_2 < .015) {
      fill(255, 0, 0); // red
    } else {
      fill(255, 25, 255, 200);  // cyan
    };
  } else if(thetaInc_2 < .015) {        
      if(thetaInc_2 < .010) {
        fill(0, 255, 0);  // green
      } else {
        fill(10, 255, 10, 125); // CYAN       
      };
   } else if(thetaInc<.0175) {    
    if(thetaInc<.015 ) {
       fill(0, 0, 255); // blue
    } else {
      fill(45, 225, 255, 125); // yellow
    };  
  } else {
    fill(255);
  };   // end of  renderwave funcion
  // A simple way to draw the wave with an ellipse at each location
  for (int x = 0; x < yvalues.length; x++) {
    if(thetaInc<.01) {
      ellipse(x*xspacing, height/2+yvalues[x], elipseXDim, elipseYDim);
    } else
        ellipse(x*xspacing, height/2+yvalues[x], 16, 16);
  };
};

void generateHUD() {
  fill(64,64,128, 192);
  rect(0, 65,(levelTimeAmt-timeRun)*23 , 12); // timeLeft bar
  fill(64,64,64, 128);
  
  rect(0,0, 320,65); // top status menu mask
  rect(0,height-40, 320,40); // bottom status menu mask
  textSize(16);

  fill(200);
  
  text("Red: ",5, 15);
  text("Green: ", 5, 30);
  text("Blue: ", 5, 45);
  text(int(multiplier) + "x", 220, 547);
 if(redCoinAmt/10==0) {
   text("0", redCoinAmt/15+60, 15);
 }else{
   text(redCoinAmt/10, redCoinAmt/15+85, 15);
 };
 if(greenCoinAmt/10==0) {
   text("0", greenCoinAmt/15+60, 30);
 }else{
    text(greenCoinAmt/10, greenCoinAmt/15+85, 30);
 };
 if(blueCoinAmt/10==0) {
   text("0", blueCoinAmt/15+60, 45);
 }else{
   text(blueCoinAmt/10, blueCoinAmt/15+85, 45);
 };    
  
  rect(0,520,currentScore*.01,8);
  text("Current Score:" + int(currentScore), 5, 545);
  text("High Score:" + int(highScore), 5, 560);
  text("Health: ", 5, 60);
  text(int(playerHealth), (playerHealth*4)+80, 61); // health num display
  text("score math: " + int((levelStage*((1/timeRun*25)*(multiplier/1)))), 5,125);
//  rect(220, 535, multiplier*2, 12);
  text("Lives: " + playerLives, 220, 560);
  if(playerLives==0 && timeRun-timeRun==0) {
    textSize(64);
    text("You \n Dead" , width/4, height/2);
  };
  
  fill(255,0,0, 32);
  rect(75, 3,redHighScore/15 , 12);
  fill(0,255,0, 32);
  rect(75, 20,greenHighScore/15 , 12);
  fill(0,0,255, 32);
  rect(75, 35,blueHighScore/15 , 12);
  fill(255,0,0, 125);
  rect(75, 3,redCoinAmt/15 , 12);  
  fill(0,255,0, 125);
  rect(75, 20,greenCoinAmt/15 , 12);
  fill(0,0,255, 125);
  rect(75, 35,blueCoinAmt/15 , 12);
  fill(128, 128, 128,175);  
  rect(75, 49, playerHealth*4, 12); 
};

void playerCollision() {
    for (int x = 0; x < yvalues.length; x++) {
      int currentMouseX = pmouseX;
      int currentMouseY = pmouseY;
      distHolder = dist(x*xspacing, height/2+yvalues[x], currentMouseX, currentMouseY);        
      if(distHolder<=12) {         
        if(thetaInc<.018 && thetaInc_2 < .018 && lastCoinGrabLoc == false) {           
           redCoinAmt = redCoinAmt + 10;
           currentScore += levelStage*((1/timeRun*25)*(multiplier/1))*(1/levelTimeDiviser);
           redIncrease++;
           if(redCoinAmt>redHighScore) {
             // redHighScore = redCoinAmt;
           };
           if(redCoinAmt%70 == 0) {
             fill(0,255,255,200);
             if(currentMouseY>height*.25) {
                stroke(125);
                ellipse(currentMouseX, currentMouseY-32, 32, 32);
                stroke(0);  
              } else {
                stroke(125);
                ellipse(currentMouseX, currentMouseY+32, 32, 32);
                stroke(0); 
              }; 
              // make sfx for touching coin
              minim = new Minim(this);
              sou = minim.loadFile("woosh.wav");
              sou.play();
            };
         } else if(thetaInc_2 < .015 && lastCoinGrabLoc == false) {
            greenCoinAmt = greenCoinAmt + 10;
            currentScore += levelStage*((1/timeRun*25)*(multiplier/1))*(1/levelTimeDiviser);
            greenIncrease++;
            if(greenCoinAmt>greenHighScore) {
             //  greenHighScore = greenCoinAmt;
            };    
            if(greenCoinAmt%70 == 0) {
              fill(255,0,255,200);
              if(currentMouseY>height*.25) {
                stroke(125);
                ellipse(currentMouseX, currentMouseY-32, 32, 32);
                stroke(0);  
              } else {
                stroke(125);
                ellipse(currentMouseX, currentMouseY+32, 32, 32); 
                stroke(0);
              };  
              minim = new Minim(this);
              sou = minim.loadFile("woosh.wav");              
              sou.play();
            };
         } else if(thetaInc<.0175 && lastCoinGrabLoc == false) {
            blueCoinAmt = blueCoinAmt + 10;
            currentScore += levelStage*((1/timeRun*25)+(multiplier/1))*(1/levelTimeDiviser);
            blueIncrease++;
            if(blueCoinAmt>blueHighScore) {
             // blueHighScore = blueCoinAmt;
            };
            if(blueCoinAmt%70 == 0) {
              fill(255,255,0,200); 
              if(currentMouseY>height*.25) {
                stroke(125);
                ellipse(currentMouseX, currentMouseY-32, 32, 32);
                stroke(0);  
              } else {
                stroke(125);
                ellipse(currentMouseX, currentMouseY+32, 32, 32);
                stroke(0);
              };  
              minim = new Minim(this);
              sou = minim.loadFile("woosh.wav");              
              sou.play();
            };
         } else {
           harmNum = harmNum + 10;
           if(playerHealth>0) {                   
             playerHealth = playerHealth - .5;                    
             if(harmNum%50==0) {
               fill(0,0,0,125);
               if(currentMouseY>height*.25) {
                  ellipse(currentMouseX, currentMouseY-32, 32, 32);  
               } else {
                  ellipse(currentMouseX, currentMouseY+32, 32, 32); 
               }; 
                  minim = new Minim(this);
                  sou = minim.loadFile("bloop.wav");
                  sou.play();
             };
           } else if(playerLives>0){
             playerLives--;
             playerHealth = 10;
//            currentScore = 0;
             redCoinAmt = 0;
             greenCoinAmt = 0;
             blueCoinAmt = 0;
             multiplier = multiplier*.5;
           } else{
            fill(255);        
            text("Opps you suck, big time\n like come on homey", 100, height/2); 
            timeUp = true; 
           };       
         };       
       lastCoinGrabLoc = true;
     } else
       lastCoinGrabLoc = false;
   };
};

int rGBTemplateArray[] = { // 0--------64------128---- 192---->255   PWM Vals
                                                // green----cyan----blue----mag---->red
      0, 255, 0,
      0, 255, 4, 0, 255, 8, 0, 255, 12, 0, 255, 16, 0 , 155, 20, 0, 255, 24, 0, 255, 28, 0, 255, 32, 0, 255, 36, 0, 255, 40,
      0, 255, 42, 0, 255, 46, 0, 255, 50, 0, 255, 54, 0, 255, 58, 0, 255, 62, 0, 255, 66, 0 , 255, 70, 0, 255, 74, 0, 255, 78,  
      0, 255, 82, 0, 255, 86, 0, 255, 90, 0, 255, 94, 0, 255, 98, 0, 255, 102, 0, 255, 106, 0 , 255, 110, 0, 255, 114, 0, 255, 118,
      0, 255, 122, 0, 255, 126, 0, 255, 130, 0, 255, 134, 0, 255, 140, 0, 255, 144, 0, 255, 148, 0 , 255, 152, 0, 255, 156, 0, 255, 160,
      0, 255, 164, 0, 255, 168, 0, 255, 172, 0, 255, 176, 0, 255, 180, 0, 255, 184, 0, 255, 188, 0 , 255, 192, 0, 255, 196, 0, 255, 200,
      0, 255, 204, 0, 255, 208, 0, 255, 212, 0, 255, 216, 0, 255, 220, 0, 255, 224, 0, 255, 228, 0 , 255, 232, 0, 255, 236, 0, 255, 240,
      0, 255, 244, 0, 255, 248, 0, 255, 252, 0, 255, 255, 0, 250, 255, 0, 246, 255, 0, 242, 255, 0 , 238, 255, 0, 234, 255, 0, 230, 255,
      0, 226, 255, 0, 222, 255, 0, 218, 255, 0, 214, 255, 0, 210, 255, 0, 208, 255, 0, 204, 255, 0 , 200, 255, 0, 196, 255, 0, 192, 255,      
      0, 188, 255, 0, 184, 255, 0, 180, 255, 0, 176, 255, 0, 172, 255, 0, 168, 255, 0, 164, 255, 0 , 160, 255, 0, 156, 255, 0, 152, 255,
      0, 148, 255, 0, 144, 255, 0, 140, 255, 0, 136, 255, 0, 132, 255, 0, 128, 255, 0, 124, 255, 0 , 120, 255, 0, 116, 255, 0, 112, 255,
      0, 108, 255, 0, 104, 255, 0, 100, 255, 0, 96, 255, 0, 92, 255, 0, 88, 255, 0, 84, 255, 0 , 80, 255, 0, 76, 255, 0, 72, 255,
      0, 68, 255, 0, 64, 255, 0, 60, 255, 0, 56, 255, 0, 52, 255, 0, 48, 255, 0, 44, 255, 0 , 40, 255, 0, 36, 255, 0, 32, 255,
      0, 28, 255, 0, 24, 255, 0, 20, 255, 0, 16, 255, 0, 12, 255, 0, 8, 255, 0, 4, 255, 0 , 0, 255, 0, 0, 255, 0, 0, 255,
      4, 0, 255, 8, 0, 255, 12, 0, 255, 16, 0, 255, 20, 0, 255, 24, 0, 255, 28, 0, 255, 32 , 0, 255, 36, 0, 255, 40, 0, 255,
      44, 0, 255, 48, 0, 255, 52, 0, 255, 56, 0, 255, 60, 0, 255, 64, 0, 255, 68, 0, 255, 72 , 0, 255, 76, 0, 255, 80, 0, 255,
      84, 0, 255, 88, 0, 255, 92, 0, 255, 96, 0, 255, 100, 0, 255, 104, 0, 255, 108, 0, 255, 112 , 0, 255, 116, 0, 255, 130, 0, 255,
      134, 0, 255, 138, 0, 255, 142, 0, 255, 146, 0, 255, 150, 0, 255, 154, 0, 255, 158, 0, 255, 162 , 0, 255, 166, 0, 255, 170, 0, 255,
      174, 0, 255, 178, 0, 255, 182, 0, 255, 186, 0, 255, 190, 0, 255, 194, 0, 255, 198, 0, 255, 202 , 0, 255, 206, 0, 255, 210, 0, 255,
      214, 0, 255, 218, 0, 255, 222, 0, 255, 226, 0, 255, 230, 0, 255, 234, 0, 255, 238, 0, 255, 242 , 0, 255, 246, 0, 255, 250, 0, 255,
      255, 0, 250, 255, 0, 246, 255, 0, 242, 255, 0, 238, 255, 0, 234, 255, 0, 230, 255, 0, 228, 255 , 0, 224, 255, 0, 220, 255, 0, 216,
      255, 0, 212, 255, 0, 208, 255, 0, 204, 255, 0, 200, 255, 0, 196, 255, 0, 192, 255, 0, 188, 255 , 0, 184, 255, 0, 180, 255, 0, 176,
      255, 0, 172, 255, 0, 168, 255, 0, 164, 255, 0, 160, 255, 0, 156, 255, 0, 152, 255, 0, 148, 255 , 0, 144, 255, 0, 140, 255, 0, 136,
      255, 0, 132, 255, 0, 128, 255, 0, 124, 255, 0, 120, 255, 0, 116, 255, 0, 112, 255, 0, 108, 255 , 0, 104, 255, 0, 100, 255, 0, 96,
      255, 0, 92, 255, 0, 88, 255, 0, 84, 255, 0, 80, 255, 0, 76, 255, 0, 72, 255, 0, 68, 255 , 0, 64, 255, 0, 60, 255, 0, 56,
      255, 0, 52, 255, 0, 48, 255, 0, 44, 255, 0, 40, 255, 0, 36, 255, 0, 32, 255, 0, 28, 255 , 0, 24, 255, 0, 20, 255, 0, 16,
      255, 0, 12, 255, 0, 8, 255, 0, 4, 255, 0, 0, 255, 255, 255
    };
    


           
      
