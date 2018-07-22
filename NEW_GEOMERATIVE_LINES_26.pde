import geomerative.*;
import generativedesign.*;

// TEXT
int indexPhraseSet;
int indexPhrase;
int LINE_SPACING = 150;
RPoint [][] phraseSetPoints;
RFont font;
WordAttractor wAttractor;
float textW = 0;
float phraseW = 0;

// LINES
Attractor_Lines attractor_Lines;
int xCount=401;
int yCount=401;
float gridSizeX=1800;
float gridSizeY=1000;
Node [] myNodes = new Node [xCount*yCount];
float xPos, yPos;
int startTime;
PVector [] nodesAtStartPosition;
PVector [] nodesAtEndPosition;

//TIME
boolean isInPause = false;
int duration1 = 0;
int duration2 = 0;
int duration3 = 0;
int duration4 = 0;
int stanzaDuration = 0;
int PAUSE_DURATION = 3000;

//SOUND
SoundManager sm;
int loop=0;
String [][] phraseSet = {
  {
    "On me dit de te haïr et je m'y efforce", 
    "Je t'imagine cruel, violent, implacable", 
    "Mais à te voir je n'ai bientôt plus de force", 
    "Et de te blesser je suis bien incapable", 
  }
  , 
  {
    "Tous mes camarades combattent avec rage", 
    "Et pleurent la nuit au souvenir des supplices", 
    "Infligés à leurs frères qui sont du même âge", 
    "et rêvent comme eux de toucher une peau lisse"
  }
  , 
  {
    "Et de pouvoir enfin caresser des obus", 
    "Autres que ceux produits par le pouvoir obtus", 
    "Je rêve de quitter ces boyaux infernaux"
  }
  , 
  {
    "De laisser ces furieux des deux bords du Rhin", 
    "Et de pouvoir embrasser ta chute de rein", 
    "Et porter notre amour sur les fonts baptismaux"
  }
};
float f;
int state = 0;
float bottomLeftPointsX;
float bottomLeftPointsY;
float bottomRightPointsX;
float bottomRightPointsY;

void setup() {
  size(1920, 1080, JAVA2D);

  // TEXT
  //smooth();
  RG.init(this);
  font = new RFont("FreeSans.ttf", 85, CENTER);

  //LINES
  nodesAtStartPosition = new PVector[xCount*yCount]; 
  initGrid();
  attractor_Lines = new Attractor_Lines(0, 0);
  attractor_Lines.strength=-500;
  attractor_Lines.ramp = 0.95;

  //SOUND
  sm= new SoundManager(this);
  indexPhrase = 0;
  indexPhraseSet = -1;

  // TIME
  startTime=millis();
}


void draw() {
  background(0);

  sm.update();
  // LINES
  if (millis()-startTime > 0) { 
    for (int i = 0; i<myNodes.length; i=i+10) {
      pushMatrix();
      translate(myNodes[i].x, myNodes[i].y);
      stroke(255, 50);
      strokeWeight(random(2, 5));
      float noiseXRange = attractor_Lines.x/100.0;
      float noiseYRange = attractor_Lines.y/1000.0;
      float noiseX = map(myNodes[i].x, 0, xCount, 0, noiseXRange/5);
      float noiseY = map(myNodes[i].y, 0, yCount, 0, noiseYRange/5);
      float noiseValue = noise(noiseX, noiseY);
      float angle = noiseValue*TWO_PI;
      rotate(-angle);
      line(-5, -5, 5, 5);
      popMatrix();
    }
  }
  pushMatrix();

  // TEXT
  if (indexPhraseSet >=0) {
    translate(width/2, height/2);
    // draw phrases vertically centered by moving the top up by half the line spaces
    translate(0, -1.0*LINE_SPACING*(phraseSetPoints.length-1)/2.0);
    // loop through lines
    for (int i=0; i< phraseSetPoints.length; i++) {
      // draw a line
      for (int j=0; j< phraseSetPoints[i].length; j++) {
        pushMatrix(); 
        translate(phraseSetPoints[i][j].x, phraseSetPoints[i][j].y);
        noFill();
        stroke(255, 200);
        strokeWeight(1);
        float angle = TWO_PI*10;
        rotate(j/angle);
        bezier(-2*(noise(10)), 10, 25*(noise(10)), -5, 2*noise(5), -15, 10, -3);
        //bezier(-10*(noise(20))+mouseX/15, 30+mouseY/10, -10*(noise(10))+mouseX/15, 20+mouseY/15, -20*noise(20)+mouseX/15, -20+mouseY/5, 10+mouseX/15, -10+mouseY/15);
        popMatrix();
      }
      // move to the next line
      translate(0, LINE_SPACING);
    }
  }
  popMatrix();

  pushMatrix();
  if (sm.transitionTime >0) {
    resetBackgroundLines(sm.transitionTime);
    noStroke();
    fill(0, sm.transitionTime*255);
    rect(0, 0, width, height);
  }
  popMatrix();
}


//---------------TEXT INIT ATTRACTOR------------------------------------------------------------------------------------------------------------------------------------------
void initAttractor( int i) {
  if (i>=4 && i<8) {
    i-=4;
  } else if (i>=8 && i<11) {
    i-=8;
  } else if (i>=11 && i<14) { 
    i-=11;
  } else if (i>14) {
    i=0;
  }
  float x = 0;
  float y =-50; 
  wAttractor = new WordAttractor(x, y, phraseSetPoints[i]);
}

void nextPhraseSet() {
  nodesAtEndPosition = null;
  createPhrasesPoints(phraseSet[indexPhraseSet]);
}

void nextPhrase() {
  //println(phraseSet[indexPhraseSet][indexPhrase]);
}

//---------------TEXT ATTRACTOR------------------------------------------------------------------------------------------------------------------------------------------
void createPhrasesPoints(String []phrases) {
  phraseSetPoints = new RPoint[phrases.length][];
  for (int i =0; i<phrases.length; i++) {
    RGroup myGroup = font.toGroup(phrases[i]); 
    myGroup = myGroup.toPolygonGroup();
    phraseSetPoints[i] = myGroup.getPoints();
    myGroup.getBottomLeft();
    myGroup.getBottomRight();
    bottomLeftPointsX = myGroup.getBottomLeft().x;
    bottomRightPointsX = myGroup.getBottomRight().x;
    println(myGroup.getBottomLeft().x);
    println(myGroup.getBottomRight().x);
  }
}

//----------------LINES ATTRACTOR INIT-----------------------------------------------------------------------------------------------------------------------------------
void updateAttractorLines(float x, float y) {
  attractor_Lines.x=x;
  attractor_Lines.y=y;
}

//----------------LINES GRID INIT----------------------------------------------------------------------------------------------------------------------------------------
void initGrid() {
  int i =0;
  for (int x=0; x<xCount; x++) {
    for (int y=0; y<yCount; y++) {
      xPos = x*(gridSizeX /(xCount-1)) + (width-gridSizeX)/2;
      yPos = y*(gridSizeY /(yCount-1)) + (height-gridSizeY)/2;
      myNodes[i] = new Node(xPos, yPos);
      myNodes[i]. setBoundary(0, 0, width, height);
      myNodes[i].setDamping(0.9);
      nodesAtStartPosition[i] = new PVector(xPos, yPos);
      i++;
    }
  }
}


void resetBackgroundLines(float d) {
  // PUT BACK BACKGROUND LINES AT THEIR ORIGINAL POSITION
  if (nodesAtEndPosition == null) {   
    nodesAtEndPosition= new PVector[myNodes.length];
    for (int i =0; i<myNodes.length; i++) {
      nodesAtEndPosition[i]=new PVector(myNodes[i].x, myNodes[i].y);
    }
  } 
  int i =0;
  for (int x=0; x<xCount; x++) {
    for (int y=0; y<yCount; y++) {
      if (i<myNodes.length) {
        myNodes[i].x= lerp(nodesAtEndPosition[i].x, nodesAtStartPosition[i].x, d);
        myNodes[i].y= lerp(nodesAtEndPosition[i].y, nodesAtStartPosition[i].y, d);
        myNodes[i].setBoundary(0, 0, width, height);
        myNodes[i].update();
      }
      i++;
    }
  }
}
