import ddf.minim.*;
import ddf.minim.ugens.*;
import processing.video.*;
import cvimage.*;
import org.opencv.core.*;
import org.opencv.imgproc.Imgproc;

Minim minim;
AudioOutput out;
Oscil wave;

//Notas musicales en notación anglosajona
String [] notas={"A3", "B3", "C4", "D4", "E4", "F4", "G4", "A4", "B4", "A5", "B5", "C5", "D5", "E5", "F5","A6", "B6", "C6", "D6", "E6"};
Wavetable [] wavesEfects = { Waves.SINE, Waves.SAW, Waves.TRIANGLE, Waves.SQUARE, Waves.QUARTERPULSE};
//Efectos visuales
Capture cam;
CVImage cv;
int efecto = 0; 
int efectoSonoro = 0;

// Clase que describe la interfaz del instrumento, idéntica al ejemplo
//Modifcar para nuevos instrumentos
class SineInstrument implements Instrument {
  Oscil wave;
  Line  ampEnv;
  
  SineInstrument( float frequency ) {
    // Oscilador sinusoidal con envolvente
    wave   = new Oscil( frequency, 0, Waves.SINE );
    ampEnv = new Line();
    ampEnv.patch( wave.amplitude );
  }
  
  // Secuenciador de notas
  void noteOn( float duration ) {
    // Amplitud de la envolvente
    ampEnv.activate( duration, 0.5f, 0 );
    // asocia el oscilador a la salida
    wave.patch( out );
  }
  
  // Final de la nota
  void noteOff() {
    wave.unpatch( out );
  }
  
  Oscil getWave(){
    return wave;
  }
  
  void setWave(Oscil w){
    wave = w;
    ampEnv.patch( wave.amplitude );
  }
}

void setup() {
  background(255 ,255 ,255);
  size(640, 580); //100 del piano y 480 de la camara
  //Camara
  cam = new Capture(this,640,480);
  cam.start();
  //OpenCV
  //Carga biblioteca core de OpenCV
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  
  cv=new CVImage(cam.width, cam.height);
  
  //Libreria minim
  minim = new Minim(this);
  
  // Línea de salida
  out = minim.getLineOut();
}

void draw() {
  stroke (255,255,255) ;
  fill (51,100,255) ; //Teclas azul
  for (int i=0;i<4;i=i+2){
    rect(i*32,0,32,100);
  }
  
  fill (255,51,51) ; //Teclas rojas
  for (int i=0;i<4;i=i+2){
    rect(i*32+(32*4),0,32,100);
  }
  
  fill (51,255,63) ; //Teclas verdes
  for (int i=0;i<4;i=i+2){
    rect(i*32+(32*8),0,32,100);
  }
  
  fill (255,230,51) ; //Teclas amarillas
  for (int i=0;i<4;i=i+2){
    rect(i*32+(32*16),0,32,100);
  }
  
  fill (0,0,0) ;
  //Dibujamos las teclas negras
  for (int i=0;i<20;i=i+2){
    rect(i*32+32,0,32,95);
  }

  //Filtros de la cámara
  if (cam.available()) {
    cam.read();
   
    PImage tmp = createImage(cam.width, cam.height, ARGB);
    arrayCopy(cam.pixels,tmp.pixels);
    switch(efecto){
      case 0:
        tmp.filter(ERODE);
        break;
      case 1:
        tmp.filter(INVERT);
        break;
      case 2: 
        tmp.filter(DILATE);
        break;
      case 3:
        tmp.filter(GRAY);
        break;
      case 4:
        tmp.filter(THRESHOLD);
        break;
      case 5:
        tmp.filter(BLUR);
        break;
    }
    image(tmp,0,100);
   }
   
   textSize(20);
   fill(255);
   text("Para cambiar la onda del sonido pulse 1,2,3,4 o 5", 10 , 560 ); 
}


void mousePressed() {
  //Nota en función del valor de mouseX
  int tecla=(int)(mouseX/32);
  println(tecla);
  cambioEfecto(tecla);
  
  SineInstrument s = new SineInstrument( Frequency.ofPitch( notas[tecla] ).asHz() );
  Oscil w = s.getWave();
  w.setWaveform( wavesEfects[efectoSonoro] );
  out.playNote( 0.0, 0.9, s );  
}

//Dependiendo de la tecla que se pulse se aplica un efecto visual
void cambioEfecto(int tecla){
  if(tecla%2!=0) efecto = 4; 
  switch(tecla){
    case 0:
        efecto = 1;
        break;
    case 2:
        efecto = 1;
        break;
    case 4:
        efecto = 2;
        break;
    case 6:
        efecto = 2;
        break;
    case 8:
        efecto = 3;
        break;
    case 10:
        efecto = 3;
        break;
    case 12:
        efecto = 0;
        break;
    case 14:
        efecto = 0;
        break;
    case 16:
        efecto = 5;
        break;
    case 18:
        efecto = 5;
        break;
  }
  /*
  if(tecla == (0|2)) efecto = 1;//teclas azules 
  if(tecla == (4|6)) efecto = 2;//teclas rojas 
  if(tecla == (8|10)) efecto = 3;//teclas verdes 
  if(tecla == (12|14)) efecto = 0; //teclas blancas 
  if(tecla == (16|18)) efecto = 5;//teclas amarillas 
  */
}

void keyPressed() { 
  switch( key ) {
    case '1': 
      efectoSonoro = 0;
      break;
    case '2':
      efectoSonoro = 1;
      break;  
    case '3':
      efectoSonoro = 2;
      break;
    case '4':
      efectoSonoro = 3;
      break;    
    case '5':
      efectoSonoro = 4;
      break;
    default: break; 
  }
  println("Efecto sonoro: " + key);

}
