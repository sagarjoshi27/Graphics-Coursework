// SimpleUI version 1.2
// Started Dec 12th 2018
// This update Feb 2019
// Simon Schofield
// Totally self contained by using a rectangle class called UIRect


//////////////////////////////////////////////////////////////////
// SimpleUIManager() is the only class you have to  create in your 
// application to build the UI. 
// With it you can add buttons (simple only at the moment,  toggle and radio groups coming later)
// and Menus. later release will have text Input and Output, Canvas Widgets and FileIO dialogs
// Later still - sliders and colour pickers.
//
//
// You need to pass all the mouse events into the SimpleUIManager
// e.g. 
// void mousePressed(){ uiManager.handleMouseEvent("mousePressed",mouseX,mouseY); }
// and for all the other mouse actions
//
// Once a mouse event has been received by a UI item (button, menu etc) it calls a function called
// simpleUICallback(...) which you have to include in the 
// main part of the project (below setup() and draw() etc.)
//
// Also, you need to call uiManager.drawMe() in the main draw() function
//

int globalButtonWidth = 60;
int globalMenuWidth = 80;

// colour for overall application
color SimpleUIAppBackgroundColor = color(192,192,192);

// colour for UI components
color SimpleUIBackColour = color(200,200,200);
color SimpleUIRolloverBackColour = color(220,220,200);
color SimpleUITextColour = color(0,0,0);


class SimpleUIManager{
    MenuManager menuManager = new MenuManager();
    ButtonManager buttonManager = new ButtonManager();
    SliderManager sliderManager = new SliderManager();
    Canvas canvas;
    // Canvas
    public SimpleUIManager(){
         
      }
  
    public Menu addMenu(String title, int x, int y, String[] menuItems){
      return menuManager.addMenu(title,x,y,menuItems);
      }
      
    
    public SimpleButton addSimpleButton(String label, int x, int y){
      return buttonManager.addButton("simple", label, x, y, "");
    }
    
    public SimpleButton addToggleButton(String label, int x, int y){
      return buttonManager.addButton("toggle", label, x, y, "");
    }
    
    public SimpleButton addRadioButton(String label, int x, int y, String groupID){
      return buttonManager.addButton("radio", label, x, y, groupID);
    }
    
    public Slider addSlider(String label, int x, int y, boolean vert){
      return sliderManager.addSlider(label, x, y, false);
    }
    
    public Canvas addCanvas(int left, int top, int right, int bottom){
      canvas = new Canvas(left, top, right, bottom);
      return canvas;
    }
    
    
    void handleMouseEvent(String mouseEventType, int x, int y){
      if(canvas != null) canvas.handleMouseEvent(mouseEventType,x,y);
      buttonManager.handleMouseEvent(mouseEventType,x,y);
      menuManager.handleMouseEvent(mouseEventType,x,y);
      sliderManager.handleMouseEvent(mouseEventType,x,y);
      
    }
    
    
    void drawMe(){
      if(canvas != null) canvas.drawMe();
      buttonManager.drawMe();
      menuManager.drawMe();
      sliderManager.drawMe();
      //rect(mouseX, mouseY, width, height);
    }
  }
//////////////////////////////////////////////////////////////////
// UIEventData
// when a UI compent call the simpleUICallback() function, it paases this object back
// which contains EVERY CONCEIVABLE it of extra information about the event that you could imagine
//
public class UIEventData{
  // set by the constructor
  public String uiComponentType; 
  public String uiLabel;
  public String mouseEventType;
  public int mousex;
  public int mousey;
  
  // extra stuff, which is germain to particular events and widgets
  public boolean toggleSelectState = false;
  public String radioGroupName = "";
  public float sliderPosition = 0.0;
  
  public UIEventData(String thingType, String label, String mouseEvent, int x, int y){
     uiComponentType = thingType;
     uiLabel = label;
     mouseEventType = mouseEvent;
     mousex = x;
     mousey = y;
   }
   
   void printMe(boolean verbose, boolean showMouseMoves){
     if(showMouseMoves == false && this.mouseEventType == "mouseMoved") return;
     
     print("UIEventData:" + this.uiComponentType + " " + this.uiLabel);
     println(" mouse event:" + this.mouseEventType + " at (" + this.mousex +"," + this.mousey + ")");
     if(verbose){
       println("toggleSelectState " + this.toggleSelectState);
       println("radioGroupName " + this.radioGroupName);
       println("sliderPosition " + this.sliderPosition);
       // add others as they come along....

     }
     println(" ");
   }
  
}







//////////////////////////////////////////////////////////////////
// Everything below here is stuff used by the UImanager class
// so you don't need to to look at it, or use it directly. But you can if you
// want to!
// 


//////////////////////////////////////////////////////////////////
// 
// Button Classes
// 
// 

class ButtonManager{
   ArrayList<SimpleButton> buttonList = new ArrayList<SimpleButton>();
   
   public ButtonManager(){
     
   }
   
   public SimpleButton addButton(String type, String label, int x, int y, String radioGroupName){
     
     if(type.toLowerCase() == "simple"){
       SimpleButton b = new SimpleButton(x,y,label);
       buttonList.add(b);
       return b;
     }
     if(type.toLowerCase() == "toggle"){
       SimpleButton b = new ToggleButton(x,y,label);
       buttonList.add(b);
       return b;
     }
     if(type.toLowerCase() == "radio"){
       SimpleButton b = new RadioButton(x,y,label,radioGroupName, this);
       buttonList.add(b);
       return b;
     }
     
     // failsafe
     return new SimpleButton(x,y,label);
   }
   
   public void handleMouseEvent(String mouseEventType, int x, int y){
    for(SimpleButton b : buttonList){
      b.handleMouseEvent( mouseEventType,  x,  y);
    }
    }
   
   public void drawMe(){
      for(SimpleButton b : buttonList){
        b.drawMe();
    }
   }
   
   public void setRadioButtonOff(String groupName){
     for(SimpleButton b : buttonList){
        if( b.UIComponentType == "RadioButton" && b.radioGroupName == groupName) { b.selected = false;}
    }
   }
 }
 
 

//////////////////////////////////////////////////////////////////
// Base class to all components
class SimpleUIBaseClass{
  public String UIComponentType = "SimpleUIBaseClass";
  
}



//////////////////////////////////////////////////////////////////
// Simple button class, functions as a simple button, and is the base class for
// toggle and radio buttons
class SimpleButton extends SimpleUIBaseClass{
  
  int buttonWidth = globalButtonWidth;
  int buttonHeight = 30;
  int locX, locY;
  int textPad = 5;
  String label;
  int textSize = 12;
  boolean rollover = false;
  
  // these have to be part of the base class as is accessed by manager
  public String radioGroupName = "";
  public boolean selected = false;
  
  
  public SimpleButton(int x, int y, String labelString){
    UIComponentType = "SimpleButton";
    locX = x;
    locY = y;
    label = labelString;
    
  }
  
  public void handleMouseEvent(String mouseEventType, int x, int y){
    if( isInMe(x,y) && (mouseEventType == "mouseMoved" || mouseEventType == "mousePressed")){
      rollover = true;
    } else { rollover = false; }
    
    if( isInMe(x,y) && mouseEventType == "mouseReleased"){
      UIEventData uied = new UIEventData(UIComponentType, label, mouseEventType, x,y);
      simpleUICallback(uied);
    }
    
  }
  
  public void drawMe(){
    if(rollover){
      fill(SimpleUIRolloverBackColour);}
    else{
      fill(SimpleUIBackColour);
    }
    rect(locX, locY, buttonWidth, buttonHeight);
    fill(SimpleUITextColour);
    textSize(textSize);
    text(this.label, locX+textPad, locY+textPad, buttonWidth, buttonHeight);
    
  }
  
  public boolean isInMe(int x, int y){
    if(x >= this.locX   && x < this.locX+this.buttonWidth &&
      y >= this.locY && y < this.locY+this.buttonHeight) return true;
   return false;
  }
  
  public void turnOff(String groupName){
    // pseudo virtual function
    // does nothing
    }

}

//////////////////////////////////////////////////////////////////
// ToggleButton

class ToggleButton extends SimpleButton{
  
  
  
  public ToggleButton(int x, int y, String labelString){
    super(x,y,labelString);
    
    UIComponentType = "ToggleButton";
  }
  
  public void handleMouseEvent(String mouseEventType, int x, int y){
    if( isInMe(x,y) && (mouseEventType == "mouseMoved" || mouseEventType == "mousePressed")){
      rollover = true;
    } else { rollover = false; }
    
    if( isInMe(x,y) && mouseEventType == "mouseReleased"){
      swapSelectedState();
      UIEventData uied = new UIEventData(UIComponentType, label, mouseEventType, x,y);
      uied.toggleSelectState = selected;
      simpleUICallback(uied);
    }
    
  }
  
  public void swapSelectedState(){
    selected = !selected;
  }
  
  public void drawMe(){
    if(rollover){
      fill(SimpleUIRolloverBackColour);}
    else{
       fill(SimpleUIBackColour);   
    }
    
    if(selected){
      strokeWeight(2);} 
   
      
      
    rect(locX, locY, buttonWidth, buttonHeight);
    
    stroke(0,0,0);
    strokeWeight(1);
    fill(SimpleUITextColour);
    textSize(textSize);
    text(this.label, locX+textPad, locY+textPad, buttonWidth, buttonHeight);
    
  }
  
  
  
}

//////////////////////////////////////////////////////////////////
// RadioButton

class RadioButton extends ToggleButton{
  
  
  public ButtonManager parentButtonManager;
  
  public RadioButton(int x, int y, String labelString, String groupName, ButtonManager parentManager){
    super(x,y,labelString);
    radioGroupName = groupName;
    UIComponentType = "RadioButton";
    parentButtonManager = parentManager;
  }
  
  
  public void handleMouseEvent(String mouseEventType, int x, int y){
    if( isInMe(x,y) && (mouseEventType == "mouseMoved" || mouseEventType == "mousePressed")){
      rollover = true;
    } else { rollover = false; }
    
    if( isInMe(x,y) && mouseEventType == "mouseReleased"){
      
      
      parentButtonManager.setRadioButtonOff(this.radioGroupName);
      selected = true;
      UIEventData uied = new UIEventData(UIComponentType, label, mouseEventType, x,y);
      uied.toggleSelectState = selected;
      uied.radioGroupName  = this.radioGroupName;
      simpleUICallback(uied);
    }
    
  }
  
  
  
  
  public void turnOff(String groupName){
    if(groupName == radioGroupName){
      selected = false;
    }
    
  }
  
}



/////////////////////////////////////////////////////////////////////////////
// menu stuff below here
//

/////////////////////////////////////////////////////////////////////////////
// Menu Manager creates and looks after a set of menus (can be just one)
//
//
class MenuManager{
  
  ArrayList<Menu> menuList = new ArrayList<Menu>();
  public MenuManager(){
    
  }
  
  public Menu addMenu(String title, int x, int y, String[] menuItems){
    Menu m = new Menu(title,x,y,menuItems);
    m.setParentManager(this);
    menuList.add(m);
    return m;
  }
  
  public void drawMe(){
    for(Menu m : menuList){
      m.drawMenu();
    }
  }
  
  public void handleMouseEvent(String mouseEventType, int x, int y){
    for(Menu m : menuList){
      m.handleMouseEvent( mouseEventType,  x,  y);
    }
  }
  
  public void closeAllMenus(){
    for(Menu m : menuList){
      m.visible = false;
    }
    
  }
  
}

/////////////////////////////////////////////////////////////////////////////
// the menu class
//
class Menu extends SimpleUIBaseClass{
  
  int locX;
  int locY;
  int textPad = 5;
  String title;
  int textSize = 12;
  int menuWidth = globalMenuWidth;
  int menuHeight = 20;
  int numItems = 0;
  MenuManager parentManager;
  public boolean visible = false;
  boolean rollover = false;
  
  ArrayList<String> itemList = new ArrayList<String>();
  
  
  
  public Menu(String title, int x, int y, String[] menuItems)
    {
    
    UIComponentType = "Menu";
    this.locX = x;
    this.locY = y;
    this.title = title;
    for(String s: menuItems){
      itemList.add(s);
      numItems++;
    }
    }
    
  
  
  public void addItem(String thisItem){
    itemList.add(thisItem);
    
  }
  
  public void setParentManager(MenuManager mm){
    parentManager = mm;
  }
  
  public void drawMenu(){
    //println("drawing menu " + title);
    drawTitle();
    if( visible ){
     drawItems();
    } 
    
  }
  
  void drawTitle(){
    if(rollover){
      fill(SimpleUIRolloverBackColour);}
    else{
      fill(SimpleUIBackColour);
    }
    rect(locX, locY, menuWidth, menuHeight);
    fill(SimpleUITextColour);
    textSize(textSize);
    text(this.title, locX+textPad, locY+3, menuWidth, menuHeight);
    
  }
  
  
  void drawItems(){
    if(rollover){
      fill(SimpleUIRolloverBackColour);}
    else{
      fill(SimpleUIBackColour);
    }
    
    
    
    int thisY = locY + menuHeight;
    rect(locX, thisY, menuWidth, (menuHeight*numItems));
    
    if(isInItems(mouseX,mouseY)){
      hiliteItem(mouseY);
    }
    
    fill(SimpleUITextColour);
    textSize(textSize);
    
    for(String s : itemList){
      text(s, locX+textPad, thisY, menuWidth, menuHeight);
      thisY += menuHeight;
    }
    
  }
  
  
 void hiliteItem(int y){
   int topOfItems =this.locY + menuHeight;
   float distDown = y - topOfItems;
   int itemNum = (int) distDown/menuHeight;
   fill(230,210,210);
   rect(locX, topOfItems + itemNum*menuHeight, menuWidth, menuHeight);
 }
  
 public void handleMouseEvent(String mouseEventType, int x, int y){
    rollover = false;
    
    //println("here1 " + mouseEventType);
    if(isInMe(x,y)==false) {
      visible = false;
      return;
    }
    if( isInMe(x,y)){
      rollover = true;
    }
    
    //println("here2 " + mouseEventType);
    if(mouseEventType == "mousePressed" && visible == false){
      //println("mouseclick in title of " + title);
      parentManager.closeAllMenus();
      visible = true;
      rollover = true;
      return;
    }
    if(mouseEventType == "mousePressed" && isInItems(x,y)){
      String pickedItem = getItem(y);
      
      UIEventData uied = new UIEventData(UIComponentType, pickedItem, mouseEventType, x,y);
      simpleUICallback(uied);
      
      parentManager.closeAllMenus();
      
      return;
    }
  }
  
 String getItem(int y){
   int topOfItems =this.locY + menuHeight;
   float distDown = y - topOfItems;
   int itemNum = (int) distDown/menuHeight;
   //println("picked item number " + itemNum);
   return itemList.get(itemNum);
 }
  
 boolean isInMe(int x, int y){
   if(isInTitle(x,y)){
     //println("mouse in title of " + title);
     return true;
   }
   if(isInItems(x,y)){
     return true;
   }
   return false;
 }
 
 boolean isInTitle(int x, int y){
   if(x >= this.locX   && x < this.locX+this.menuWidth &&
      y >= this.locY && y < this.locY+this.menuHeight) return true;
   return false;
   
 }
 
 
 boolean isInItems(int x, int y){
   if(visible == false) return false;
   if(x >= this.locX   && x < this.locX+this.menuWidth &&
      y >= this.locY+this.menuHeight && y < this.locY+(this.menuHeight*(this.numItems+1))) return true;
      
   
   return false;
 }
  
  
  
  
}// end of menu class

/////////////////////////////////////////////////////////////////////////////
// Slider Manager Class
//
class SliderManager{
   ArrayList<Slider> sliderList = new ArrayList<Slider>();
   
   public SliderManager(){
     
   }
   
   public Slider addSlider(String label, int x, int y, boolean vert){
     
       Slider s = new Slider(label, x,y, false);
       sliderList.add(s);
       return s;
     
   }
   
   public void handleMouseEvent(String mouseEventType, int x, int y){
    for(Slider s : sliderList){
      s.handleMouseEvent( mouseEventType,  x,  y);
    }
    }
   
   public void drawMe(){
      for(Slider s : sliderList){
       s.drawMe();
      }
   }
   
  
 }
/////////////////////////////////////////////////////////////////////////////
// Slider Class
//
// calls back with value on  both release and drag

class Slider extends SimpleUIBaseClass{
  
  // currently only does horizontal sider
  UIRect bounds;
  
  int len = 100;
  int wid = 20;
  boolean orientation;
  public float currentPos  = 0.0;
  boolean mouseEntered = false;
  int textPad = 5;
  String label;
  int textSize = 12;
  boolean rollover = false;
  
  public Slider(String label, int x, int y, boolean vert){
    UIComponentType = "Slider";
    this.label = label;
    bounds = new UIRect(x, y, x+len, y+wid);
    
  }
  
  public void handleMouseEvent(String mouseEventType, int x, int y){
    PVector p = new PVector(x,y);
    
    if( mouseLeave(p) ){
      UIEventData uied = new UIEventData(UIComponentType, label, "mouseReleased" , x,y);
      uied.sliderPosition = currentPos;
      simpleUICallback(uied);
      //println("mouse left sider");
    }
    
    if( bounds.isPointInside(p) == false){
      mouseEntered = false;
      return; }
    
    
    
    if( (mouseEventType == "mouseMoved" || mouseEventType == "mousePressed")){
      rollover = true;
    } else { rollover = false; }
    
    if(  mouseEventType == "mousePressed" || mouseEventType == "mouseReleased" || mouseEventType == "mouseDragged"){
      mouseEntered = true;
      float val = getSliderValueAtMousePos(x);
      setSliderPosition(val);
      UIEventData uied = new UIEventData(UIComponentType, label, mouseEventType, x,y);
      uied.sliderPosition = val;
      simpleUICallback(uied);
    }
    
  }
  
  float getSliderValueAtMousePos(int pos){
    float val = map(pos, bounds.left, bounds.right, 0,1);
    return val;
  }
  
  void setSliderPosition(float val){
   currentPos =  constrain(val,0,1);
  }
  
  boolean mouseLeave(PVector p){
     // is only true, if the mouse has been in the widget, has been depressed
    if( mouseEntered && bounds.isPointInside(p)== false) {
      mouseEntered = false;
      return true; }
      
    return false;
  }
  
  public void drawMe(){
    if(rollover){
      fill(SimpleUIRolloverBackColour);}
    else{
      fill(SimpleUIBackColour);
    }
    rect(bounds.left, bounds.top,  bounds.getWidth(), bounds.getHeight());
    fill(SimpleUITextColour);
    textSize(textSize);
    text(this.label, bounds.right+textPad, bounds.top+13);
    int sliderHandleLocX = (int) map(currentPos,0,1,bounds.left, bounds.right);
    sliderHandleLocX = (int)constrain(sliderHandleLocX, bounds.left+10, bounds.right-10 );
    ellipse(sliderHandleLocX, bounds.top + 10, 10,10);
  }
  
}

/////////////////////////////////////////////////////////////////////////////
// Canvas Class
//
// application drawing order
// clear all
// draw canvas contents (including any shapes outside canvas boudry)
// canvas clears edges round canvas
// draw rest of UI
//
// Is drawn first, and clears the area around it, so shapes drawn outside the canvas ae covered
//
// recieves mouse events from a set rectangle
// Unlike buttons and menus, the UImanager is only configured to have one canvas class
//
//


class Canvas extends SimpleUIBaseClass{
  
  UIRect bounds;
  UILine line;
  UIEllipse circle;
  public Canvas(int left, int top, int right, int bottom){
    UIComponentType = "Canvas";
    bounds = new UIRect(left, top, right, bottom);
    line = new UILine(left, top, right, bottom);
    circle = new UIEllipse(left, top, right, bottom);
  }
  
  
  public void handleMouseEvent(String mouseEventType, int x, int y){
    PVector p = new PVector(x,y);
    if( bounds.isPointInside(p) == false) return;
    
    UIEventData uied = new UIEventData(UIComponentType, "canvas", mouseEventType, x,y);   
    simpleUICallback(uied);
  
  }
  
  
  public void drawMe(){
    
    
    strokeWeight(1);
    stroke(0,0,0);
    
    // draw over any stuff outside the bounds
    int appWidth = width;
    int appHeight = height;
    
    // draw over stuff surrounding the canvas
    fill(SimpleUIAppBackgroundColor);
    noStroke();
    // left, top, right, bottom 
    rect(0,0, bounds.left, appHeight);
    rect(bounds.left,0, bounds.getWidth(), bounds.top);
    rect(bounds.right,0, appWidth-bounds.left, appHeight);
    rect(bounds.left, bounds.bottom,  bounds.getWidth(), appHeight-bounds.getHeight());
    // fill the canvas main area with white
    //fill(255,255,255);
    //rect(bounds.left, bounds.top,  bounds.getWidth(), bounds.getHeight());
    // then draw a line round the oustide
    strokeWeight(1);
    stroke(0,0,0);
    noFill();
    rect(bounds.left, bounds.top,  bounds.getWidth(), bounds.getHeight());
  }
  
  
  
  
}// end canvas






/////////////////////////////////////////////////////////////////
// simple rectangle class
//

class UIRect{
  
  float left,top,right,bottom;
  
  public UIRect(float x1, float y1, float x2, float y2){
    setRect(x1,y1,x2,y2);
  }
  
  public UIRect(PVector p1, PVector p2){
    setRect(p1.x,p1.y,p2.x,p2.y);
  }
  
  void setRect(float x1, float y1, float x2, float y2){
    this.left = min(x1,x2);
    this.top = min(y1,y2);
    this.right = max(x1,x2);
    this.bottom = max(y1,y2);
  }
  
  PVector getCentre(){
    float cx =  (this.right - this.left)/2.0;
    float cy =  (this.bottom - this.top)/2.0;
    return new PVector(cx,cy);
  }
  
  boolean isPointInside(PVector p){
    // inclusive of the boundries
    if(   isBetweenInc(p.x, this.left, this.right) && isBetweenInc(p.y, this.top, this.bottom) ) return true;
    return false;
  }
  
  float getWidth(){
    return (this.right - this.left);
  }
  
  float getHeight(){
    return (this.bottom - this.top);
  }
  
  boolean isBetweenInc(float v, float lo, float hi){
    if(v >= lo && v <= hi) return true;
  return false; 
  }

  
}// end UIRect class

/////////////////////////////////////////////////////////////////
// simple line class
//

class UILine{
  
  float left,top,right,bottom;
  
  public UILine(float x1, float y1, float x2, float y2){
    setLine(x1,y1,x2,y2);
  }
  
  public UILine(PVector p1, PVector p2){
    setLine(p1.x,p1.y,p2.x,p2.y);
  }
  
  void setLine(float x1, float y1, float x2, float y2){
    this.left = min(x1,x2);
    this.top = min(y1,y2);
    this.right = max(x1,x2);
    this.bottom = max(y1,y2);
  }
  
  PVector getCentre(){
    float cx =  (this.right - this.left)/2.0;
    float cy =  (this.bottom - this.top)/2.0;
    return new PVector(cx,cy);
  }
  
  boolean isPointInside(PVector p){
    // inclusive of the boundries
    if(   isBetweenInc(p.x, this.left, this.right) && isBetweenInc(p.y, this.top, this.bottom) ) return true;
    return false;
  }
  
  float getWidth(){
    return (this.right - this.left);
  }
  
  float getHeight(){
    return (this.bottom - this.top);
  }
  
  boolean isBetweenInc(float v, float lo, float hi){
    if(v >= lo && v <= hi) return true;
  return false; 
  }

  
}// end UILine class

/////////////////////////////////////////////////////////////////
// simple line class
//

class UIEllipse{
  
  float left,top,right,bottom;
  
  public UIEllipse(float x1, float y1, float x2, float y2){
    setCircle(x1,y1,x2,y2);
  }
  
  public UIEllipse(PVector p1, PVector p2){
    setCircle(p1.x,p1.y,p2.x,p2.y);
  }
  
  void setCircle(float x1, float y1, float x2, float y2){
    this.left = min(x1,x2);
    this.top = min(y1,y2);
    this.right = max(x1,x2);
    this.bottom = max(y1,y2);
  }
  
  PVector getCentre(){
    float cx =  (this.right - this.left)/2.0;
    float cy =  (this.bottom - this.top)/2.0;
    return new PVector(cx,cy);
  }
  
  boolean isPointInside(PVector p){
    // inclusive of the boundries
    if(   isBetweenInc(p.x, this.left, this.right) && isBetweenInc(p.y, this.top, this.bottom) ) return true;
    return false;
  }
  
  float getWidth(){
    return (this.right - this.left);
  }
  
  float getHeight(){
    return (this.bottom - this.top);
  }
  
  boolean isBetweenInc(float v, float lo, float hi){
    if(v >= lo && v <= hi) return true;
  return false; 
  }

  
}// end UICircle class
