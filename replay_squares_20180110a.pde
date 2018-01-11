/* 
 branch 20161113c for animated visual display by
 receiving 4 channels from arduino sensors (maybe more) and 
 storing them to .txt file with ability for
 playback without arduino link, plus some
 signal smoothing and channel multiplication (by delay).
 */

//............................................................
//=======================VARIABLES============================
//============================================================
//.............serial communications with arduino.............
int arduinoChannels = 4;  // how many channels are incoming from arduino.
int[][] inputVals = new int[arduinoChannels][4];  // where we'll store what we receive.
//....................tuning variables........................
int inputMultiplier = 4;      // [][][] how many times to multiply the inputs.
int smoothing = 8;            // [][][] number of rows for arrays (for smoothing and delay). (was 4).
int delayHistory = 8;         // [][][] history cycles to skip for for each light delay level. (was 3).
int inputTuneLow = 0;         // [][][] for tuning input off (0-1023).
int inputTuneHigh = 1023;     // [][][] for tuning input full (0-1023).
int storageTuneLow = 20;      // [][][] for storing input off (0-1023).
int storageTuneHigh = 180;    // [][][] for storing input full (0-1023).
int outputTuneLow = 0;       // [][][] for tuning output off (0-1023).
int outputTuneHigh = 255;     // [][][] for tuning full (0-1023).
//....................drawing variables.......................
int delayDraw = 0;  // [][][] between each playback sample.
int bgColor = 220;   // [][][] background color.
int rotateRate = 1;  // [][][] max degrees change per frame.
int rotateX1 = 0;    // [][][] for tracking position.
int rotateY1 = 0;    // [][][] for tracking position.
int rotateZ1 = 0;    // [][][] for tracking position.
int rotateX2 = 0;    // [][][] for tracking position.
int rotateY2 = 0;    // [][][] for tracking position.
int rotateZ2 = 0;    // [][][] for tracking position.
int rotateX3 = 0;    // [][][] for tracking position.
int rotateY3 = 0;    // [][][] for tracking position.
int rotateZ3 = 0;    // [][][] for tracking position.
int translateZ1 = 40;  // [][][] for tracking position in/out of screen.
int translateZ2 = 40;  // [][][] for tracking position in/out of screen.
int translateZ3 = 40;  // [][][] for tracking position in/out of screen.
int translateChange1 = 1;  // [][][] units max change per frame.
int translateChange2 = 1;  // [][][] units max change per frame.
int translateChange3 = 1;  // [][][] units max change per frame.
int translateRate = 1;  // [][][] units max change per frame.
int divisionsX = 11;  // [][][] number of elements per X axis. (was 7, 15, 21, 17, 27).
int size1;           // for sizing the elements (in setup() according to draw size).
//.....................vars for playback......................
int rowTable1 = 0;  // for keeping our place.
//...............vars and arrays for equations................
int channelCount = 0;  // for keeping track which channel we're on.
int outputChannels = (arduinoChannels * inputMultiplier);  // number of outputs channels (columns for arrays).
int history = (inputMultiplier * smoothing * delayHistory);  // nuber of rows for arrays, for output delay.
int[][] storageVals = new int[outputChannels][history];  // array for doing signal tuning.
int[] outputVals = new int[outputChannels];  // array for communicating tuned arduinoChannels.
int[] outputChange = new int[outputChannels];  // for tracking.

int [][] storeSample = {
  {92, 103, 73, 103},
  {60, 58, 46, 66},
  {61, 62, 51, 65},
  {67, 80, 82, 125},
  {67, 78, 72, 112},
  {71, 99, 88, 119},
  {80, 120, 110, 135},
  {91, 127, 77, 102},
  {86, 120, 65, 96},
  {67, 94, 55, 95},
  {78, 105, 64, 101},
  {61, 78, 61, 103},
  {53, 57, 64, 91},
  {62, 63, 80, 99},
  {53, 60, 69, 100},
  {74, 107, 141, 148},
  {86, 145, 124, 170},
  {101, 168, 132, 193},
  {75, 109, 76, 150},
  {62, 94, 72, 155},
  {58, 98, 72, 157},
  {79, 145, 86, 161},
  {93, 153, 78, 145},
  {75, 132, 70, 138},
  {104, 178, 103, 170},
  {95, 152, 88, 168},
  {97, 149, 118, 161},
  {121, 154, 174, 149},
  {167, 164, 183, 151},
  {164, 176, 169, 165},
  {142, 171, 122, 151},
  {109, 136, 84, 122},
  {99, 129, 75, 119},
  {90, 131, 80, 131},
  {109, 151, 92, 144},
  {115, 166, 100, 154},
  {105, 150, 86, 158},
  {91, 157, 77, 150},
  {80, 144, 74, 137},
  {83, 116, 63, 118},
  {74, 116, 72, 141},
  {99, 150, 126, 177},
  {125, 170, 176, 184},
  {134, 156, 163, 160},
  {122, 160, 170, 188},
  {99, 139, 141, 214},
  {83, 99, 105, 150},
  {78, 83, 132, 118},
  {81, 91, 116, 129},
  {88, 97, 111, 125},
  {71, 74, 97, 112},
  {76, 89, 102, 117},
  {71, 83, 95, 117},
  {69, 86, 88, 129},
  {81, 126, 103, 151},
  {127, 161, 120, 141},
  {152, 161, 132, 136},
  {183, 170, 168, 154},
  {173, 170, 194, 165},
  {148, 162, 200, 164},
  {129, 150, 184, 159},
  {108, 119, 141, 132},
  {90, 102, 124, 123},
  {87, 100, 126, 124},
  {80, 84, 110, 129},
  {70, 75, 89, 129},
  {66, 83, 89, 137},
  {73, 105, 105, 160},
  {82, 128, 112, 175},
  {96, 155, 135, 186},
  {115, 176, 195, 198},
  {131, 186, 230, 220},
  {92, 143, 121, 204},
  {92, 159, 121, 192},
  {102, 172, 142, 188},
  {107, 167, 157, 177},
  {107, 154, 175, 174},
  {112, 152, 185, 165},
  {129, 164, 196, 161},
  {162, 169, 203, 158},
  {150, 161, 187, 156},
  {131, 151, 185, 151},
  {122, 144, 190, 151},
  {114, 131, 184, 147},
  {101, 108, 162, 136},
  {88, 94, 143, 141},
  {74, 84, 112, 151},
  {69, 84, 104, 163},
  {67, 88, 90, 164},
  {58, 81, 73, 148},
  {73, 107, 106, 165},
  {62, 70, 78, 102},
  {67, 80, 96, 110},
  {82, 85, 142, 118},
  {83, 90, 140, 136},
  {93, 103, 134, 151},
  {94, 110, 143, 139},
  {83, 82, 118, 124},
  {81, 82, 97, 81},
  {65, 67, 81, 110},
  {72, 81, 105, 130},
  {84, 95, 129, 140},
  {104, 137, 163, 159},
  {103, 143, 151, 154},
  {118, 142, 115, 126},
  {112, 142, 103, 136},
  {96, 132, 117, 134},
  {92, 111, 106, 120},
  {68, 89, 89, 114},
  {68, 86, 83, 109},
  {66, 88, 81, 114},
  {91, 137, 129, 138},
  {123, 149, 133, 140},
  {130, 155, 122, 141},
  {131, 159, 120, 145},
  {125, 152, 105, 141},
  {107, 132, 82, 116},
  {99, 118, 72, 112},
  {84, 109, 72, 123},
  {79, 107, 65, 109},
  {65, 62, 47, 65},
  {65, 87, 64, 106},
  {66, 76, 48, 77},
  {46, 57, 37, 77},
  {43, 58, 38, 85},
  {81, 117, 89, 107},
  {100, 119, 67, 100},
  {75, 110, 66, 122},
  {68, 88, 75, 116},
  {62, 72, 78, 126},
  {61, 75, 90, 145},
  {61, 74, 89, 159},
  {54, 69, 76, 146},
  {57, 73, 92, 150},
  {67, 85, 124, 161},
  {65, 82, 96, 164},
  {63, 88, 102, 192},
  {65, 80, 94, 160},
  {107, 163, 195, 181},
  {129, 155, 136, 175},
  {109, 156, 109, 155},
  {107, 161, 120, 182},
  {142, 176, 111, 147},
  {79, 109, 64, 114},
  {68, 98, 58, 115},
  {75, 111, 71, 135},
  {84, 123, 97, 148},
  {106, 149, 148, 165},
  {131, 167, 188, 184},
  {119, 158, 117, 149},
  {139, 167, 129, 146},
  {135, 159, 106, 134},
  {115, 143, 89, 132},
  {111, 149, 103, 154},
  {118, 151, 110, 152},
  {119, 150, 98, 142},
  {96, 129, 77, 129},
  {92, 136, 76, 135},
  {99, 158, 103, 155},
  {134, 190, 150, 172},
  {163, 219, 189, 202},
  {161, 222, 196, 217},
  {118, 178, 121, 210},
  {98, 162, 101, 203},
  {81, 153, 88, 180},
  {84, 162, 83, 161},
  {78, 146, 74, 150},
  {72, 132, 70, 145},
  {72, 136, 71, 143},
  {73, 133, 69, 134},
  {80, 138, 74, 136},
  {120, 180, 124, 172},
  {132, 172, 135, 173},
  {151, 183, 147, 177},
  {162, 175, 161, 163},
  {175, 169, 181, 161},
  {113, 130, 117, 155},
  {104, 126, 109, 143},
  {97, 135, 134, 151},
  {91, 118, 108, 126},
  {72, 85, 76, 113},
  {136, 157, 142, 139},
  {134, 154, 127, 149},
  {151, 175, 178, 166},
  {154, 176, 183, 165},
  {137, 175, 169, 168},
  {113, 153, 141, 164},
  {111, 153, 179, 161},
  {169, 185, 229, 184},
  {162, 187, 211, 190},
  {169, 192, 229, 176},
  {116, 109, 157, 124},
  {84, 82, 116, 119},
  {85, 87, 136, 120},
  {74, 74, 103, 130},
  {70, 82, 110, 161},
  {84, 123, 157, 203},
  {95, 123, 139, 183},
  {89, 117, 121, 191},
  {73, 106, 104, 189},
  {81, 121, 132, 197},
  {97, 141, 159, 202},
  {108, 148, 177, 203},
  {106, 137, 162, 209},
  {84, 109, 115, 193},
  {74, 99, 100, 185},
  {69, 97, 96, 188},
  {69, 101, 100, 193},
  {68, 95, 99, 186},
  {66, 90, 97, 179},
  {68, 91, 105, 175},
  {72, 94, 120, 176},
  {77, 96, 127, 177},
  {75, 96, 121, 178},
  {86, 126, 157, 196},
  {131, 179, 200, 202},
  {139, 180, 183, 188},
  {133, 181, 170, 188},
  {124, 175, 158, 178},
  {149, 167, 190, 157},
  {167, 172, 204, 173},
  {126, 144, 170, 152},
  {136, 155, 175, 158},
  {146, 175, 157, 177},
  {121, 150, 120, 157},
  {120, 157, 122, 161},
  {118, 157, 145, 171},
  {139, 170, 184, 174},
  {171, 195, 171, 174},
  {138, 171, 112, 144},
  {92, 146, 81, 169},
  {118, 200, 158, 210},
  {144, 191, 154, 183},
  {126, 165, 119, 165},
  {153, 192, 179, 188},
  {139, 176, 152, 176},
  {155, 181, 170, 174},
  {170, 167, 199, 156},
  {181, 164, 203, 155},
  {178, 183, 193, 170},
  {161, 183, 181, 175},
  {149, 187, 189, 186},
  {138, 174, 185, 185},
  {114, 147, 150, 173},
  {112, 164, 178, 170},
  {160, 171, 197, 166},
  {131, 169, 170, 169},
  {156, 179, 172, 160},
  {191, 179, 173, 155},
  {183, 176, 166, 154},
  {179, 173, 175, 156},
  {173, 168, 187, 154},
  {169, 163, 189, 154},
  {146, 156, 180, 155},
  {123, 141, 163, 147},
  {111, 129, 152, 141},
  {108, 127, 152, 140},
  {104, 126, 143, 142},
  {121, 155, 165, 158},
  {172, 183, 185, 180},
  {135, 165, 161, 169},
  {136, 160, 150, 167},
  {124, 166, 135, 171},
  {143, 188, 163, 191},
  {155, 182, 156, 182},
  {151, 177, 171, 174},
  {165, 180, 178, 174},
  {159, 176, 177, 171},
  {155, 173, 180, 169},
  {158, 171, 194, 168},
  {154, 171, 189, 171},
  {151, 171, 180, 165},
  {185, 179, 189, 163},
  {166, 169, 160, 158},
  {164, 173, 160, 166},
  {148, 166, 150, 162},
  {152, 175, 168, 170},
  {159, 179, 169, 163},
  {157, 184, 162, 177},
  {137, 173, 163, 178},
  {139, 175, 186, 177},
  {166, 189, 201, 184},
  {173, 189, 199, 185},
  {146, 172, 163, 174},
  {140, 168, 167, 168},
  {149, 173, 175, 171},
  {143, 175, 174, 170},
  {162, 178, 191, 163},
  {195, 184, 207, 167},
  {205, 186, 204, 167},
  {172, 172, 168, 157},
  {165, 172, 156, 160},
  {167, 174, 160, 159},
  {177, 175, 171, 157},
  {184, 175, 178, 157},
  {180, 177, 167, 160},
  {168, 175, 150, 156},
  {165, 175, 142, 151},
  {166, 175, 136, 146},
  {155, 172, 128, 145},
  {157, 179, 137, 151},
  {172, 189, 147, 155},
  {170, 186, 137, 149},
  {160, 180, 131, 146},
  {163, 182, 139, 150},
  {172, 184, 150, 154},
  {174, 184, 158, 159},
  {167, 183, 158, 159},
  {175, 187, 155, 156},
  {178, 188, 145, 152},
  {153, 180, 123, 148},
  {147, 181, 121, 149},
  {153, 184, 128, 151},
  {163, 185, 134, 150},
  {161, 183, 123, 146},
  {134, 172, 102, 144},
  {120, 169, 95, 147},
  {119, 172, 96, 153},
  {121, 177, 101, 159},
  {122, 174, 100, 156},
  {109, 152, 87, 144},
  {93, 135, 76, 137},
  {92, 140, 79, 144},
  {97, 151, 86, 155},
  {104, 165, 97, 166},
  {119, 181, 118, 175},
  {138, 193, 137, 179},
  {159, 199, 156, 182},
  {176, 200, 176, 179},
  {189, 196, 189, 173},
  {180, 184, 178, 160},
  {165, 172, 170, 154},
  {166, 169, 177, 154},
  {170, 166, 190, 155},
  {169, 164, 195, 155},
  {160, 159, 192, 153},
  {132, 145, 172, 147},
  {111, 133, 156, 145},
  {138, 164, 209, 168},
  {116, 133, 164, 142},
  {101, 114, 151, 133},
  {100, 127, 159, 147},
  {125, 157, 188, 158},
  {180, 181, 198, 165},
  {205, 191, 190, 169},  // end of beginning.
  {202, 192, 177, 170},
  {159, 175, 162, 168},
  {135, 161, 148, 166},
  {125, 159, 149, 168},
  {120, 156, 155, 166},
  {147, 188, 187, 179},
  {180, 211, 225, 195},
  {167, 185, 204, 181},
  {111, 128, 135, 175},
  {78, 110, 110, 206},
  {105, 150, 179, 217},
  {100, 123, 148, 197},
  {75, 118, 88, 172},
  {81, 138, 87, 164},
  {83, 131, 104, 182},
  {86, 94, 142, 140},
  {99, 132, 169, 151},
  {129, 141, 181, 145},
  {143, 170, 163, 153},
  {100, 107, 152, 132},
  {95, 122, 135, 129},
  {85, 104, 110, 130},
  {86, 101, 124, 128},
  {83, 107, 117, 146},
  {96, 138, 126, 165},
  {122, 165, 137, 168},
  {152, 177, 156, 166},
  {189, 185, 197, 174},
  {196, 197, 155, 159},
  {128, 145, 91, 115},
  {80, 80, 51, 75},
  {53, 48, 46, 77},
  {81, 137, 128, 168},
  {169, 203, 213, 188},
  {110, 124, 162, 150},
  {90, 134, 133, 175},
  {77, 90, 88, 139},
  {55, 52, 57, 81},
  {50, 75, 65, 187},
  {55, 84, 69, 166},
  {68, 134, 87, 204},
  {67, 126, 100, 231},
  {63, 103, 75, 161},
  {52, 80, 54, 120},
  {48, 79, 50, 116},
  {53, 100, 56, 123},
  {62, 126, 69, 151},
  {93, 161, 93, 168},
  {125, 187, 146, 184},
  {167, 178, 207, 167},
  {129, 137, 171, 132},
  {117, 131, 168, 136},
  {123, 134, 163, 131},
  {106, 132, 140, 150},
  {105, 134, 146, 156},
  {146, 182, 195, 190},
  {135, 172, 172, 180},
  {138, 169, 204, 177},
  {132, 164, 176, 172},
  {146, 177, 204, 180},
  {120, 133, 134, 146},
  {117, 139, 164, 143},
  {97, 125, 152, 142},
  {115, 122, 134, 131},
  {96, 121, 134, 148},
  {128, 158, 136, 162},
  {113, 140, 99, 131},
  {83, 102, 90, 120},
  {80, 98, 105, 115},
  {85, 103, 116, 118},
  {84, 119, 98, 141},
  {108, 146, 96, 137},
  {87, 119, 80, 133},
  {125, 150, 168, 152},
  {92, 121, 125, 135},
  {108, 156, 144, 157},
  {129, 140, 91, 109},
  {105, 123, 97, 107},
  {68, 68, 57, 80},
  {65, 82, 72, 109},
  {60, 71, 61, 94}
};  // array to store recorded samples for replay.

//............................................................
//............................................................
//=========================SETUP==============================
//============================================================
void setup() {
  size(1000, 695, P3D);  // screen size & use 3D capabilities (was 1920x1080)
  background(bgColor);  // background color (0=black).
  frameRate(30); 
  smooth(); 
  size1 = (width/divisionsX);
}  // close setup.
//............................................................
//............................................................
//========================draw LOOP===========================
//============================================================
void draw() {
  
  lights();  // for 3D shading.
  for (int i = 0; i < arduinoChannels; i++) {
    inputVals[i][0] = storeSample[rowTable1][i];  // new input.
  }  //close "for(int i...)"
  rowTable1 = (rowTable1 + 1) % 425;  // advance our counter.
  storeInputs();  // store in an array for processing, map to nominal range.
  effects();  // multiply, delay, & tune signals for smoothing and effects.
  records();  // update storage locations before next cycle.
  background(bgColor);  // clear the screen.

  channelCount = 0;  // reset channel counter.
  for (int y = ( size1 / 2 ); y < (height+(size1*2)); y += size1) {  
    for (int x = ( size1 / 2 ); x < (width+(size1*2)); x += size1) {  
      if (channelCount > (outputChannels - 1)) {  // ...by cycling through all the output channels.
        channelCount = 0;
      }  // close "if(i>(outputChannels...)"
      noStroke();  // choose stroke.
    
  if((channelCount % 2) == 1){
      fill(map(outputVals[(channelCount+2) % outputChannels], outputTuneLow, outputTuneHigh, 150, 205), map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 190, 220), map(outputVals[(channelCount+3) % outputChannels], outputTuneLow, outputTuneHigh, 235, 255));   // choose fill color.
    float sizeNow = map(outputVals[(channelCount+1) % outputChannels], outputTuneLow, outputTuneHigh, (size1 *0.2), (size1 *0.5));
      rect(x, y, sizeNow, sizeNow);
    
    
      fill(map(outputVals[(channelCount+2) % outputChannels], outputTuneLow, outputTuneHigh, 255, 180), map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 255, 210), map(outputVals[(channelCount+3) % outputChannels], outputTuneLow, outputTuneHigh, 255, 235));   // choose fill color.
    sizeNow = map(outputVals[(channelCount+3) % outputChannels], outputTuneLow, outputTuneHigh, (size1 *0.3), (size1 *0.6));
      rect(x, y, sizeNow, sizeNow);
    
    
      pushMatrix();
    translate(0,0,-1);
      fill(map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 130, 195), map(outputVals[(channelCount+2) % outputChannels], outputTuneLow, outputTuneHigh, 170, 220), map(outputVals[(channelCount+3) % outputChannels], outputTuneLow, outputTuneHigh, 200, 255));   // choose fill color.
      rectMode(CENTER);  // reference rectangles to their centers.
    sizeNow = map(outputVals[(channelCount) % outputChannels], outputTuneLow, outputTuneHigh, (size1 *0.9), (size1 *1.1));
      rect(x, y, sizeNow, sizeNow);  // draw the rectange.
    popMatrix();
    
  }
    
  else{
  if((channelCount % 3) == 1){
      fill(map(outputVals[(channelCount+2) % outputChannels], outputTuneLow, outputTuneHigh, 150, 220), map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 190, 235), map(outputVals[(channelCount+3) % outputChannels], outputTuneLow, outputTuneHigh, 235, 255));   // choose fill color.
    float sizeNow = map(outputVals[(channelCount+1) % outputChannels], outputTuneLow, outputTuneHigh, (size1 *0.2), (size1 *0.5));
      rect(x, y, sizeNow, sizeNow);
    
    
      fill(map(outputVals[(channelCount+2) % outputChannels], outputTuneLow, outputTuneHigh, 255, 180), map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 255, 205), map(outputVals[(channelCount+3) % outputChannels], outputTuneLow, outputTuneHigh, 255, 235));   // choose fill color.
    sizeNow = map(outputVals[(channelCount+3) % outputChannels], outputTuneLow, outputTuneHigh, (size1 *0.3), (size1 *0.6));
      rect(x, y, sizeNow, sizeNow);    
    
    
      pushMatrix();
    translate(0,0,-1);
      fill(map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 120, 215), map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 150, 230), map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 190, 255));   // choose fill color.
      rectMode(CENTER);  // reference rectangles to their centers.
    sizeNow = map(outputVals[(channelCount) % outputChannels], outputTuneLow, outputTuneHigh, (size1 *0.9), (size1 *1.1));
      rect( x, y, sizeNow, sizeNow);  // draw the rectange.
    popMatrix();
    
    
  }
  else{
      fill(map(outputVals[(channelCount+2) % outputChannels], outputTuneLow, outputTuneHigh, 165, 215), map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 190, 230), map(outputVals[(channelCount+3) % outputChannels], outputTuneLow, outputTuneHigh, 230, 255));   // choose fill color.
    float sizeNow = map(outputVals[(channelCount+1) % outputChannels], outputTuneLow, outputTuneHigh, (size1 *0.2), (size1 *0.5));
      rect(x, y, sizeNow, sizeNow);
    
    
      fill(map(outputVals[(channelCount+2) % outputChannels], outputTuneLow, outputTuneHigh, 255, 150), map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 255, 190), map(outputVals[(channelCount+3) % outputChannels], outputTuneLow, outputTuneHigh, 255, 230));   // choose fill color.
    sizeNow = map(outputVals[(channelCount+3) % outputChannels], outputTuneLow, outputTuneHigh, (size1 *0.3), (size1 *0.6));
      rect(x, y, sizeNow, sizeNow);
    
    
      pushMatrix();
    translate(0,0,-1);
      fill(map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 120, 225), map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 160, 235), map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 190, 255));   // choose fill color.
      rectMode(CENTER);  // reference rectangles to their centers.
    sizeNow = map(outputVals[(channelCount) % outputChannels], outputTuneLow, outputTuneHigh, (size1 *0.9), (size1 *1.1));
      rect( x, y, sizeNow, sizeNow);  // draw the rectange.
    popMatrix();
    
  }
    
  if((channelCount % 4) == 1){
    
      fill(map(outputVals[(channelCount+2) % outputChannels], outputTuneLow, outputTuneHigh, 160, 205), map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 200, 220), map(outputVals[(channelCount+3) % outputChannels], outputTuneLow, outputTuneHigh, 235, 255));   // choose fill color.
    float sizeNow = map(outputVals[(channelCount+1) % outputChannels], outputTuneLow, outputTuneHigh, (size1 *0.2), (size1 *0.5));
      rect(x, y, sizeNow, sizeNow);
    
    
      fill(map(outputVals[(channelCount+2) % outputChannels], outputTuneLow, outputTuneHigh, 255, 160), map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 255, 200), map(outputVals[(channelCount+3) % outputChannels], outputTuneLow, outputTuneHigh, 255, 235));   // choose fill color.
    sizeNow = map(outputVals[(channelCount+3) % outputChannels], outputTuneLow, outputTuneHigh, (size1 *0.3), (size1 *0.6));
      rect(x, y, sizeNow, sizeNow);
    
    
      pushMatrix();
    translate(0,0,-1);
      fill(map(outputVals[(channelCount+0) % outputChannels], outputTuneLow, outputTuneHigh, 130, 195), map(outputVals[(channelCount+2) % outputChannels], outputTuneLow, outputTuneHigh, 170, 220), map(outputVals[(channelCount+3) % outputChannels], outputTuneLow, outputTuneHigh, 200, 255));   // choose fill color.
      rectMode(CENTER);  // reference rectangles to their centers.
    sizeNow = map(outputVals[(channelCount) % outputChannels], outputTuneLow, outputTuneHigh, (size1 *0.9), (size1 *1.1));
      rect( x, y, sizeNow, sizeNow);  // draw the rectange.
    popMatrix();
    
  }
  }
    
    
    

        channelCount++;  // advance the outputChannel counter.
      }  // close "for(x...)"
    }  // close "for(y...)"
  }  // close draw loop
  //............................................................
  //............................................................
  //=====================keyPressed LOOP========================
  //============================================================
  void keyPressed() {
    //......................mode control........................
    
  }  // close keyPressed loop.
  //............................................................
  //............................................................
  //...................storeInputs function.....................
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void storeInputs() {  // store in an array for processing, map to nominal range.
    for (int i = 0; i < arduinoChannels; i++) {  // just for the inputs from arduino...
      storageVals[i][0] = inputVals[i][0];
      storageVals[i][0] = constrain(inputVals[i][0], inputTuneLow, inputTuneHigh);  // save to storageVals array for tuning.
    }  // close "for(int i...)"
    
  }  // end function storeInputs.
  //............................................................
  //.....................effects function.......................
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void effects() {  // multiply, delay, & tune signals for smoothing and effects.
    for (int i = 0; i < outputChannels; i++) {  // for however many outputs we have... 
      if (i < arduinoChannels) {  // ...set first 4 as average of prev (smoothing).
        int sum = 0;  // starting from zero...
        for (int j = 0; j < smoothing; j++) {  // ...look at previous values down the chart...
          sum += storageVals[i][j];  // ...and tally them up...
        }  // close "for(j=0...)"
        storageVals[i][0] = sum / smoothing; 
      }  // close "if(i<arduinoChannels...)"
      else {
        storageVals[i][0] = storageVals[i - arduinoChannels][delayHistory - 1];  // for any multiplied channels, use history from an input.
      }  // close "else..."
      float intermediateFloat = map(storageVals[i][0], storageTuneLow, storageTuneHigh, outputTuneLow, outputTuneHigh);  // tune output values.
      outputChange[i] = (int(intermediateFloat) - outputVals[i]);  // track the difference.
      // flip channels 0/10, 2/8, 5/15, 7/13 to mask cascade from multipy-by-delay.
      if (i == (arduinoChannels + 4) || i == (arduinoChannels + 9)) {  // if ch8||ch13 (assuming arduinoChannels==4)...
        outputVals[i] = outputVals[i-6];  // ...put earlier val in this round's slot...
        outputVals[i-6] = int(intermediateFloat);  // ...and put this round's val in the earlier slot.
      }  // close "if(i==...+4||+9)"
      if (i == (arduinoChannels + 6) || i == (arduinoChannels + 11)) {  // if ch10||ch15 (assuming arduinoChannels==4)...
        outputVals[i] = outputVals[i-10];  // ...put earlier val in this round's slot...
        outputVals[i-10] = int(intermediateFloat);  // ...and put this round's val in the earlier slot.
      }  // close "if(i==...+6||+11)"

      else {  // otherwise be normal.
        outputVals[i] = int(intermediateFloat);  // convert from a float to an int (for saving space?) and save to outputVals array for output.
      }  // close "else"
    }  // close "for(i...)"
  }  // end function effects.
  //............................................................
  //.....................records function.......................
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  void records() {  // update storage locations before next cycle.
    for (int i = 0; i < outputChannels; i++) {  // for each column...
      for (int j = 0; j < (history - 1); j++) {  // ...go down the rows...
        storageVals[i][(history - 1 - j)] = storageVals[i][(history - 2 - j)];  // ...shift values down a row to open top row.
      }  // close "for(j...)"
    }  // close "for(i...)"
  }  // close records function.