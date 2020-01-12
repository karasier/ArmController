import controlP5.*;

ControlP5 cp5;
Slider slider;
Button grab,release,up,down,right,left;
Toggle[] toggle = new Toggle[5];

int[] pos = {512,512,512,512,0};
int[] center = {512,512,512,512,0};
boolean[] toggleState = {true,true,true,true,true};

void setup()
{
  size(700,700);
  cp5 = new ControlP5(this);
  
  // Button of move to center position.
  cp5.addButton("moveCenter")
     .setLabel("Move to Center")
     .setPosition(300,height-150)
     .setSize(100,100);     
  
  cp5.addButton("checkArray")
     .setLabel("Check Array")
     .setPosition(100,height-150)
     .setSize(100,100);     
  
  grab = cp5.addButton("grab")
            .setLabel("grab")
            .setPosition(width-200,50)
            .setSize(200,200);
            
  release = cp5.addButton("release")
            .setLabel("release")
            .setPosition(width-200,height-350)
            .setSize(200,200);
     
  up = cp5.addButton("up")
            .setLabel("UP")
            .setPosition(200,50)
            .setSize(100,200);
            
  down = cp5.addButton("down")
            .setLabel("DOWN")
            .setPosition(200,height-350)
            .setSize(100,200);
            
  right = cp5.addButton("right")
            .setLabel("RIGHT")
            .setPosition(300,250)
            .setSize(200,100);
            
  left = cp5.addButton("left")
            .setLabel("LEFT")
            .setPosition(0,250)
            .setSize(200,100);
  
  for(int i = 0; i < 5; i++)
  {
    toggle[i] = cp5.addToggle(str(i+1))
              .setLabel(str(i+1))
              .setPosition(10, 400 + 45*i)
              .setValue(true)
              .setSize(40, 30);            
  }
  
  slider = cp5.addSlider("velocity")
              .setRange(0,100)
              .setValue(100)
              .setPosition(width-200,height-50)
              .setSize(100,20);
                
  moveCenter(); // initialize
}

void draw()
{  
  background(0);
  
  for(int i = 0; i < toggle.length; i++)
  {
    toggleState[i] = toggle[i].getBooleanValue();    
  }   
  
  if(toggleState[0])
  {
    if(right.isPressed())
    {
      if(pos[0] < 1023)
        pos[0] += 1;         
    }
  
    if(left.isPressed())
    {
      if(pos[0] > 0)
        pos[0] -= 1;         
    }
  }
  
  if(up.isPressed())
  {
    for(int i = 1; i < 4; i++)
    {
      if(pos[i] < 1023 && toggleState[i])
        pos[i] += 1;
    }
  }
  
  if(down.isPressed())
  {
    for(int i = 1; i < 4; i++)
    {
      if(pos[i] > 0 && toggleState[i])
        pos[i] -= 1;
    }
  }
  
  if(toggleState[4])
  {
    if(grab.isPressed())
    {
      if(pos[pos.length-1] < 512)
        pos[pos.length-1] += 1;        
    }
  
    if(release.isPressed())
    { 
      if(pos[pos.length-1] > 0)
        pos[pos.length-1] -= 1;
    }
  }
  
  delay(int(map(slider.getValue(),0,100,300,0)));
}


void moveCenter()
{
  for(int i = 0; i < center.length; i++)
  {
    pos[i] = center[i];
  }
}

void checkArray()
{
  for(int elem:pos)
  {
    println(elem);
  }
}
