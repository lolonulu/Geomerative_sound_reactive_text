import ddf.minim.analysis.*;
import ddf.minim.*;

// variable 'public'
float bandHeight=0;

String [][]soundNames = {
  {"FR_01", "FR_02", "FR_03", "FR_04"}, 
  {"FR_05", "FR_06", "FR_07", "FR_08"}, 
  {"FR_09", "FR_10", "FR_11"}, 
  {"FR_12", "FR_13", "FR_14"}
};
float []linesYPositions1 ={300., 450., 600., 750.};
float []linesYPositions2 ={370., 520., 670.};


class SoundManager {
  //SOUND
  Minim minim;
  AudioPlayer[][] sounds;
  FFT fft;
  float bandHeight;
  float transitionTime = 0;
  boolean isTransitioning = false;
  int startTransitionTime;
  int transitionDuration = 1000;
  float t = textWidth(phraseSet[indexPhraseSet][indexPhrase]);


  SoundManager(PApplet app) {

    minim = new Minim(app);
    sounds = new AudioPlayer[soundNames.length][];
    //println(soundNames.length);
    AudioPlayer [] phraseSounds;
    for (int i =0; i<soundNames.length; i++) {
      phraseSounds = new AudioPlayer[soundNames[i].length]; 
      for (int j=0; j<soundNames[i].length; j++) {
        phraseSounds[j] = minim.loadFile(soundNames[i][j]+".wav", 512);
      }
      sounds[i]=phraseSounds;
    }
  }

  void update() {
    if (isTransitioning ) {
      if (millis() >= startTransitionTime+transitionDuration) {
        // transition end
        isTransitioning=false;
        transitionTime=0;
        nextPhraseSet();
      } else {
        //  we are transiting
        transitionTime = map(millis(), startTransitionTime, startTransitionTime+transitionDuration, 0., 1.);
      }
      // SOUND
    } else {
      if ( indexPhraseSet==-1) { 
        // Initialise all
        indexPhraseSet=0;
        indexPhrase=0;
        playSound();
        nextPhraseSet();
      } else if (!sounds[indexPhraseSet][indexPhrase].isPlaying()) {  
        // sound file is finished read next one
        indexPhrase++;

        if (indexPhrase >= sounds[indexPhraseSet].length && (isTransitioning == false)) {
          // If phrases'index is greater than the stanza's index then go on to the next stanza
          indexPhrase=0;// 1rst sentence
          indexPhraseSet++;// increase stanza's index

          if (indexPhraseSet >= sounds.length) {
            indexPhraseSet=0;
            startTime = millis();
            // reset from the beginning
          }
          // we begin the transition
          isTransitioning = true;
          startTransitionTime = millis();
        } else {
          //go to the next phrase
          nextPhrase();
        }
        playSound();
      } else { 
        // we're reading the sound file
        // analyse of the sound
        soundFFTAnalyse();
        wordAttractorToSound();
        linesAttractor();
      }
    }
  }


  void playSound() {
    AudioPlayer s = sounds[indexPhraseSet][indexPhrase];
    s.rewind();
    s.play();
    //println("lecture :"+ indexPhraseSet + ", "+ indexPhrase);
    fft = new FFT(s.bufferSize(), s.sampleRate());
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
    //wAttractor.moveTo(map(s.position(), 0, s.length()-1000, 0, width-100)-width/1.5, bandHeight/8-300);
    wAttractor.moveTo(map(s.position(), 0, s.length(), bottomLeftPointsX-width/2, bottomRightPointsX), bandHeight/8-300); 
    wAttractor.attract();
  }

  void linesAttractor() {
    AudioPlayer s = sounds[indexPhraseSet][indexPhrase]; 
    if (phraseSet[indexPhraseSet].length==4) {
      updateAttractorLines( attractor_Lines.x = map(s.position(), 200, s.length(), bottomLeftPointsX+width/2, bottomRightPointsX+width/2), linesYPositions1[indexPhrase]);
    } else if (phraseSet[indexPhraseSet].length==3) {
      updateAttractorLines( attractor_Lines.x = map(s.position(), 200, s.length(), bottomLeftPointsX+width/2, bottomRightPointsX+width/2), linesYPositions2[indexPhrase]);
    }
    for (int j = 0; j<myNodes.length; j++) {
      attractor_Lines.attract_Lines(myNodes[j]);    
      myNodes[j].update();
    }
  }
}
