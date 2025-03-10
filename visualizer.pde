BufferedReader reader;
ArrayList<event> test_events = new ArrayList<event>();
String[] filenames;
PVector[] touches = new PVector[5];
Double test_start_time;
Double run_start_time;

Boolean started = false;

EventRunnerThread RunTest;
int current_event_index = 0;

int device_width = 300;
float device_ratio = 2;

color[] colors = {color(115, 169, 255),color(115, 255, 143),color(255, 215, 115),color(255, 115, 115),color(241, 115, 255)};

class event {
  double time;
  String action;
  String values;
  
  event(double time, String action, String values) {
    this.time = time;
    this.action = action;
    this.values = values;
  }
}

class EventRunnerThread extends Thread {
  Boolean isActive = true;
  
  void run() {
    try {
      while(isActive) {
        if(current_event_index >= test_events.size()) {
          isActive = false;
          started = false;
          return;
        }
          
        event current_event = test_events.get(current_event_index);
        
        double elapsed_time = (System.nanoTime() / 1000000) - run_start_time;
        
        if(elapsed_time >= current_event.time) {
          
          String[] values = split(current_event.values, " ");
          
          println(current_event.action);
          
          if(current_event.action.equals("touchStart")) {
            int index = Integer.valueOf(values[0]);
            int x = Integer.valueOf(values[1]);
            int y = Integer.valueOf(values[2]);
            touches[index] = new PVector(x,y);
          }
          
          if(current_event.action.equals("move")) {
            int index = Integer.valueOf(values[0]);
            int x = Integer.valueOf(values[1]);
            int y = Integer.valueOf(values[2]);
            touches[index].x = x;
            touches[index].y = y;
          }
          
          if(current_event.action.equals("touchEnd")) {
            int index = Integer.valueOf(values[0]);
            touches[index] = null;
          }
          
          current_event_index++;
        }
      }
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }
}

void settings() {
    //fullScreen();
  int device_height = (int)(device_width*device_ratio);
  size(device_width, device_height);
}

void setup() {
  String path = sketchPath() + "\\..\\logs";
  filenames = listFileNames(path);
  
  reader = createReader(path + "\\NemmiProtoUnoLog_14_13_29_115.txt");
  test_events = parseFile();
  
  background(127);
  noStroke();
}

void draw() {
  /*
  if(!started) {
    for(int i=0; i<filenames.length; i++) {
      String name = filenames[i].replace("NemmiProtoUnoLog_", "").replace("_", ":");
      fill(255);
      rect(50, ((i+1)*50), 150,35);
      fill(0);
      text(name, 60, ((i+1)*60), 140, 25);
    }
  }
  else {*/
  if(!started) {
    run_start_time = (double) System.nanoTime() / 1000000;
    
    if(RunTest == null) {
      RunTest = new EventRunnerThread();
      RunTest.isActive = true;
      started = true;
      RunTest.start();
    }
  }
  else {
    clear();
    fill(50);
    //rect((int)(width/2 - device_width / 2), (int)(height/2 - (device_width*device_ratio)/2), device_width, device_width*device_ratio);
    double time = (double) System.nanoTime() / 1000000 - run_start_time;
    fill(255);
    text("Test time: " + str((float)time),20,20);
    
    for(int i = 0; i < touches.length; i++) {
      if(touches[i]!=null) {
        fill(colors[i]);
        float posX = touches[i].x / 100 * width;
        float posY = touches[i].y / 100 * height;
        circle(posX, posY, 20);
      }
    }
  }
  //}
}

public void stop() {
  if (RunTest!=null) RunTest.isActive=false;
  super.stop();
}

ArrayList<event> parseFile() {
  String line;
  int i=0;
  //time, event, values
  ArrayList<event> events = new ArrayList<event>();
  
  while(true) {
    try {
      line = reader.readLine();
    }
    catch(Exception e) {
      line = null;
    }
    if(line == null)
      break;
    
    String[] toParse = split(line,"\t");
    String action = toParse[1];
    
    String[] times = split(toParse[0],":");
    int hours = Integer.valueOf(times[0]);
    int minutes = Integer.valueOf(times[1]);
    String[] s_mil = split(times[2],".");
    int seconds = Integer.valueOf(s_mil[0]);
    int millis = Integer.valueOf(s_mil[1]);
    
    double parsedTime = (hours * 60 * 60000) + (minutes * 60000) + (seconds * 1000) + millis;
    
    if(action.equals("test")) {
      test_start_time = parsedTime;
    }
    else {
      event t_event = new event(parsedTime-test_start_time, toParse[1], toParse[2]);
      events.add(t_event);
    }
  }
  
  return events;
}

String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    exit();
    return null;
  }
}
