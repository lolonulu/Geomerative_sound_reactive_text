import ddf.minim.analysis.*;
import ddf.minim.*;

int PAUSE_DURATION = 2000;

//SOUND
FFT fft;

// variable 'public'
float bandHeight=0;

String [][]soundNames = {
  {"FR_01", "FR_02", "FR_03", "FR_04"}, 
  {"FR_05", "FR_06", "FR_07", "FR_08"}, 
  {"FR_09", "FR_10", "FR_11"}, 
  {"FR_12", "FR_13", "FR_14"}
};
float []linesYPositions ={300., 450., 600., 750., 250., 450., 600., 750., 450., 600., 750., 450., 600., 750.};

AudioPlayer[][] sounds;

class SoundManager {
  //SOUND
  Minim minim;
  AudioPlayer[][] sounds;
  FFT fft;
  float bandHeight;


  SoundManager(PApplet app) {

    minim = new Minim(app);
    sounds = new AudioPlayer[soundNames.length][];
    AudioPlayer [] phraseSounds;
    for (int i =0; i<soundNames.length; i++) {
      phraseSounds = new AudioPlayer[soundNames[i].length]; 
      for (int j=0; j<soundNames[i].length; j++) {
        phraseSounds[j] = minim.loadFile(soundNames[i][j]+".wav", 2048);
      }
      sounds[i]=phraseSounds;
    }
    println(sounds);
  }

  void update() {

    // SOUND
    if ( indexPhraseSet==-1) { 
      // tout initialsier
      indexPhraseSet=0;
      indexPhrase=0;
      playSound();
      nextPhraseSet();
    } else if (!sounds[indexPhraseSet][indexPhrase].isPlaying()) {  
      // sound fils is finished read next one
      indexPhrase++;

      if (indexPhrase >= sounds[indexPhraseSet].length) {
        // If phrases'index is greater than the stanza's index then go on to the next stanza

        indexPhrase=0; // 1rst sentence
        indexPhraseSet++; // increase stanza's index


        if (indexPhraseSet >= sounds.length) {
          indexPhraseSet=0;
          // reset from the beginning
        }
        // PUT BACK BACKGROUND LINES AT THEIR ORIGINAL POSITION
        if (nodesAtEndPosition == null) {
          nodesAtEndPosition= new PVector[myNodes.length];
          for (int i =0; i<myNodes.length; i++) {
            nodesAtEndPosition[i]=new PVector(myNodes[i].x, myNodes[i].y);
          }
        }  
        float d = map(millis(), 0, PAUSE_DURATION, 0.0, 1.0);
        int i =0;
        for (int x=0; x<xCount; x++) {
          for (int y=0; y>yCount; y++) {
            if (i<myNodes.length) {
              myNodes[i].x= lerp(nodesAtEndPosition[i].x, nodesAtStartPosition[i].x, d);
              myNodes[i].y= lerp(nodesAtEndPosition[i].y, nodesAtStartPosition[i].y, d);
              myNodes[i].setBoundary(0, 0, width, height);
              myNodes[i].update();
            }
            i++;
          }
        }
        // pause
        timer();
        isInPause=true;
        //delay(PAUSE_DURATION/2)
        nextPhraseSet();
      } else {
        //on passe à la phrase suivante
        timerPauseDuration();
        nextPhrase();
        isInPause= false;
      }
      playSound();
    } else { 
      // on est en train de lire le son
      // analyser le son
      soundFFTAnalyse();
      wordAttractorToSound();
      linesAttractor();
    }
  }

  void playSound() {
    AudioPlayer s = sounds[indexPhraseSet][indexPhrase];
    s.rewind();
    s.play();
    //println("lecture :"+ indexPhraseSet + ", "+ indexPhrase);
    fft = new FFT(s.bufferSize(), s.sampleRate());
    //
  }

  void soundFFTAnalyse() {
    AudioPlayer s = sounds[indexPhraseSet][indexPhrase];
    fft.forward(s.mix);
    for (int i =0; i< fft.specSize(); i++) {
      float bandDB = 10*log(fft.getBand(i)/fft.timeSize());
      bandDB = constrain(bandDB, -1000, 1000);
      bandHeight = map(bandDB*4, 0, -220, 0, height);
    }
  }

  void wordAttractorToSound() {
    AudioPlayer s = sounds[indexPhraseSet][indexPhrase];
    initAttractor(indexPhrase);
    wAttractor.moveTo(map(s.position(), 0, s.length(), 0, width-100)-width/2, bandHeight/10-300); 
    wAttractor.attract();
  }

  void linesAttractor() {
    AudioPlayer s = sounds[indexPhraseSet][indexPhrase];  
    updateAttractorLines( attractor_Lines.x = map(s.position(), 0, s.length(), 0, width-(100)/2), linesYPositions[indexPhrase]);
    for (int j = 0; j<myNodes.length; j++) {
      attractor_Lines.attract_Lines(myNodes[j]);
      myNodes[j].update();
    }
  }

  //---------------------------TIMER--------------------------------------------------------

  void timer() {
    if (indexPhrase <= sounds[indexPhraseSet].length) {
      AudioPlayer s = sounds[indexPhraseSet][indexPhrase];  
      int stanzaDuration = s.length();
      println("s length"+":"+s);
      if (millis()>millis()-startTime + stanzaDuration) {
        isInPause = true;
        s.pause();
      }
    }
  }

  void timerPauseDuration() {
    if (indexPhrase <= sounds[indexPhraseSet].length) {
      AudioPlayer s = sounds[indexPhraseSet][indexPhrase];  
      int stanzaDuration = s.length();
      if (millis()>millis()-startTime + stanzaDuration + PAUSE_DURATION) {
        isInPause = false;
        s.play();
      }
    }
  }
}
