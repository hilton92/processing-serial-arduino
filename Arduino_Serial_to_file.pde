/*
Author: Benjamin Hilton
Date: February 2017
Written for the BYU Nanocomposites Lab
*/



//import dependencies
//if you are running this in processing you will need to import the controlp5 library (under sketch > import library > add library)
import processing.serial.*;
import java.awt.event.KeyEvent;
import java.awt.event.InputEvent;
import java.util.Date;
import controlP5.*;
import java.util.*;


boolean selected = false; // true if a COM port has been selected
boolean recording = false; //true if record has been pushed
String seconds;
float time;
int inByte; //the incoming 8-bit integer
Serial myPort; //declare the serial port connection


PrintWriter output; //declare the PrintWriter object (which writes to file)
ControlP5 cp5; //declare the controlp5 object (the gui)
Textarea myTextarea; //this provides the text box of instructions
Chart myChart;//this provides the plot

void setup() {
  
  size(800, 400); // the size of the window in pixels
  cp5 = new ControlP5(this);
  myTextarea = cp5.addTextarea("txt") //add text
    //set location of text, size, font, etc
    .setPosition(75, 25) 
    .setSize(250, 175)
    .setFont(createFont("arial", 12))
    .setLineHeight(14)
    .setColor(color(128))
    .setColorBackground(color(255, 100))
    .setColorForeground(color(255, 100));
  ;
  myTextarea.setText("The below drop-down list shows the COM ports of the devices"
    +" connected to the computer.  Select the COM port"
    +" of the device that the Arduino is connected to."
    +" When you are ready to begin recording, push the"
    +" record button.  To stop recording, push the stop"
    +" recording button. You can record again without"
    +" closing the program just by hitting record again."
    +" To stop the program and close the file properly,"
    +" push 'q' on the keyboard."
    );


  //get the list of available COM ports
  List l = Arrays.asList(Serial.list());
  
  //make a scrollable list with the available COM ports
  cp5.addScrollableList("dropdown")
    //set position, size, etc
    .setPosition(100, 200)
    .setSize(200, 100)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItems(l)
    ;
  //add button for record
  cp5.addButton("Record")
    .setValue(12)//the value doesn't matter
    .setPosition(100, 300)
    .setSize(200, 19)
    ;

  cp5.addButton("Stop_Recording")
    .setValue(7)//the value doesn't matter
    .setPosition(100, 325)
    .setSize(200, 19)
    ;


  //add the plot, set position, size, range, type
  myChart = cp5.addChart("Voltage_Plot")
    .setPosition(400, 100)
    .setSize(375, 200)
    .setRange(0, 256)
    .setView(Chart.LINE) 
    .setStrokeWeight(1.5)
    .setColorCaptionLabel(color(40))
    ;
  myChart.addDataSet("incoming");
  myChart.setData("incoming", new float[80]);
  
}

//this is the setup function, it takes the selected COM port and begins communication
void setUP(int foo) {
  myPort = new Serial(this, Serial.list()[foo], 9600); //opens serial connection with selected COM port, also selects baud rate
  
}

//this function repeats
void draw() {
  if (selected) { //runs only if a COM port has been selected
    while (myPort.available() > 0) {
      inByte = myPort.read();
      if (recording){ //only write to the file if the record button has been selected
        time = time + 0.001;
        seconds = String.format("%.3f", time);
        output.println(seconds + "\t" + inByte);
      }
      myChart.push("incoming", (inByte));//output to the plot always
    }
  }
}

void keyPressed() {
  if (key == 'q') {
    if (recording){
    output.flush();
    output.close();
    }
    exit();
  }
}

public void Record(int theValue) {
  if (theValue == 12) { 
    if (selected == true && recording == false) { // if a COM port has been selected
      recording = true; //set recording to be true
      //create the output object
      
      
        int day = day();
        int m = month();
        int h = hour();
        int min = minute();
        int s = second();
        String d_string = str(day);
        String m_string = str(m);
        String h_string = str(h);
        String min_string = str(min);
        String s_string = str(s);
 
        output = createWriter(m_string + "-" + d_string + "  " + h_string + "_" + min_string + "_" + s_string + ".txt"); //create output object
        output.println("Time\tResistance"); //create headings (in this case, time and resistance)
        time = 0;
        background(20,255,20); //set background color to green to show that it is recording
        
    }
  }
}

void dropdown(int n) { //this runs whenever a port is selected
  selected = true; //set selected to true
  setUP(n); //run setup with the COM port that has been selected
}

public void Stop_Recording(int theValue){ //use to stop recording
  if (theValue == 7){
    if (recording){
      output.flush(); //finish up writing data to the file
      output.close(); //close the file
      background(255,20,20); //change the background to red to show that it has stopped
      recording = false; //set boolean value to false
    }
  }
}
    
    
  