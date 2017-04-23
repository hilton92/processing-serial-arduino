/*
Author: Benjamin Hilton
Date: February 2017
Written for the BYU Nanocomposites Lab
*/



//import dependencies
import processing.serial.*;
import java.awt.event.KeyEvent;
import java.awt.event.InputEvent;
import java.util.Date;
import controlP5.*;
import java.util.*;

boolean selected = false;
boolean recording = false;
int start_time = 0;
float time;
int inByte;

Serial myPort; //declare the serial port connection


PrintWriter output;
ControlP5 cp5;
Textarea myTextarea; //this provides the text box of instructions
Chart myChart;//this provides the plot


void setup() {
  size(800, 400);
  cp5 = new ControlP5(this);
  myTextarea = cp5.addTextarea("txt")
    .setPosition(100, 50)
    .setSize(200, 150)
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
    +" record button.  To stop the program, push 'q' on"
    +" the keyboard."
    );



  List l = Arrays.asList(Serial.list());
  /* add a ScrollableList, by default it behaves like a DropdownList */
  cp5.addScrollableList("dropdown")
    .setPosition(100, 200)
    .setSize(200, 100)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItems(l)
    ;

  cp5.addButton("Record")
    .setValue(12)
    .setPosition(100, 300)
    .setSize(200, 19)
    ;


  myChart = cp5.addChart("Voltage_Plot")
    .setPosition(400, 100)
    .setSize(375, 200)
    .setRange(0, 260)
    .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
    .setStrokeWeight(1.5)
    .setColorCaptionLabel(color(40))
    ;
  myChart.addDataSet("incoming");
  myChart.setData("incoming", new float[100]);
  
}


void setUP(int foo) {
  myPort = new Serial(this, Serial.list()[foo], 9600);
  //get date stamp (as integer) convert it to a string
  Date d = new Date();
  long _time = d.getTime()/1000;
  println(_time);
  String time_string = str(_time);
  output = createWriter(time_string + ".txt"); //create output object
  output.println("Time\tResistance"); //create headings (in this case, time and resistance)
}

void draw() {

  if (selected && recording) {
    while (myPort.available() > 0) {
      inByte = myPort.read();
      time = (millis() - start_time) / 1000.0;
      output.println(time + "\t" + inByte);
      myChart.push("incoming", (inByte));
    }
  }
}

void keyPressed() {
  if (key == 'q' && selected) {

    output.flush();
    output.close();
    exit();
  }
}

public void Record(int theValue) {
  if (theValue == 12) {
    if (selected == true) {
      start_time = millis();
      recording = true;
    }
  }
}

void dropdown(int n) {
  
  selected = true;
  setUP(n);

}