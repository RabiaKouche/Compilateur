import java.util.ArrayDeque;
import java.util.Arrays;

private ArrayDeque<String> stack;

private String[] input;
private String output;

private String[] dictionary;
private String[] window;
private String[] titles;

private String[] rules;
private int currentRule;

private int Xmargin = 20;
private int Ymargin = 25;

private final static String EPS = "ε";


// Setup : configuration du projet
void setup() {
  this.stack = new ArrayDeque<String>();
  this.output = "";  
  this.input = (String.join(" ", loadStrings("../programme.txt")).replaceAll("\t", "") + " " + EPS).split(" ");
  
  this.dictionary = loadStrings("../data/dictionnaire.csv");
  this.window = this.dictionary[0].split("\t");
  
  this.rules = loadStrings("../data/regles.txt");
  
  this.titles = new String[this.dictionary.length];
  for(int i=0; i < this.dictionary.length; i++) {
    this.titles[i] = this.dictionary[i].split("\t")[0].trim();
  }
  
  preprocessing();
  
  stack.push("$");
  stack.push("P");
  
  textSize(20);
  frameRate(1.5);
  
  background(255);
  size(600, 800);
}

// Draw : dessine
void draw() {
  String content = "";
  
  try {
    println(input[0]);
    
    String test = stack.peek();
    
    String res = findInDictionary(input[0], test);    
    output += " " + res;
      
    stack.pop();
    if(res.matches("\\d+")) {
      currentRule = Integer.parseInt(res);;
      
      if (currentRule == 0) {
        printCenter("ERREUR DE COMPILATION:\nSyntaxe incorrecte", #FF0000);       
      }
     
      content = findRule(currentRule).split("\t")[2];
    } else {
      content = res;
    }
  } catch(NumberFormatException n) {
    n.printStackTrace();
  } catch(Exception e) {
    e.printStackTrace();
    exit();
  }
  
  updateStack(content);
  
  drawStack();
  drawRules();

  int topInput = 10;
  int inputH = 30;
  
  drawInputTextbox(width/4, topInput, 400, inputH, 15, 18, color(210,25,12), "Input", 15, color(255,255,212));
  drawInputTextbox(width/4, topInput + inputH + 10, 400, inputH, 15, 18, color(210,225,12), "Output", 15, color(0,0,12));
 
  printInput(input);
  printOutput(output);
}

void preprocessing() {
  for(int i = 0; i < input.length; i++) {
    String[] parts = input[i].split(" ");
    
    // parcours des éléments
    for(int j = 0; j < parts.length; j++) {
      if (parts[j].matches("\\d+")) 
        parts[j] = "nb";
      else {
        if (!Arrays.asList(titles).contains(parts[j]) && parts[j].matches("([a-z]|[A-Z])+")) 
          parts[j] = "id";
      }
    }
    
    input[i] = String.join(" ", parts);
  }
}

/**
 * Change la pile en fonction de l'instruction lue
 **/
void updateStack(String content) {
  String[] parts = content.split(" ");
    
  if(parts[0].equals("pop")) {
    input = Arrays.copyOfRange(input, 1, input.length);
  } else if (parts[0].equals("ACC")) {
    println("Programme correct");
    printCenter("Compilation correcte", #00FF00);       
    exit();
  } else {
    for(int i=parts.length-1; i >= 0 ; i--) {
      if(!parts[i].equals("ε"))
        stack.push(parts[i]);
    }
  }
}

/**
 * Trouve un élément dans le dictionnaire dont le texte et le fond de pile sont passés en paramètre.
 * @param token Texte
 * @param stackElement fond de pile
 * @return Element correspondant du dictionnaire
 **/
String findInDictionary(String token, String stackElement) throws Exception {
  int index = Arrays.asList(window).indexOf(token);
  int stackEltIndex = Arrays.asList(this.titles).indexOf(stackElement);

  String[] row = dictionary[stackEltIndex].split("\t");  //<>//
  String resultAsStr = row[index];
  
  if (resultAsStr.length() == 0) 
    throw new Exception("ERREUR DICTIONNAIRE"); // erreur
  
  return resultAsStr; 
}

/**
 * Trouve la règle dont le numéro est passé en paramètre.
 * @param ruleNumber Numéro de la règle.
 * @return Règle associée.
 **/
String findRule(int ruleNumber) {
  return rules[ruleNumber - 1];
}

/**
 * Dessine la pile
 **/
void drawStack() {
  int elemCount = max(stack.size(), 15);
  
  float rectHeight = 760;
  float rectWidth = 110;
 
  /*if(elemCount >= 16) {
    rectWidth = width / 0.05*elemCount;
  }*/
  
  PShape drawnStack = createShape();
  drawnStack.beginShape();
    drawnStack.vertex(Xmargin, Ymargin);
    drawnStack.vertex(Xmargin, Ymargin + rectHeight);
    drawnStack.vertex(Xmargin + rectWidth, Ymargin + rectHeight);
    drawnStack.vertex(Xmargin + rectWidth, Ymargin);
  drawnStack.endShape();
  
  shape(drawnStack);
  
  float x, y, lineHeight;
  
  lineHeight = rectHeight / elemCount;
  
  x = Xmargin + rectWidth/2;
  y = Ymargin + rectHeight - lineHeight/2;
  
  Object[] contents = stack.toArray();
  
  //Draw the stack's contents
  for(int i=contents.length-1; i > -1; i--) {
    drawStackElement(x, y, lineHeight, rectWidth, (String)contents[i]);
    y -= lineHeight;
  }
}

void drawStackElement(float x, float y, float lineHeight, float lineWidth, String element) {
  fill(0);
  textAlign(CENTER, CENTER);
  text(element, x, y);
  
  float x1, x2, y1;
  
  x1 = x - lineWidth/2;
  x2 = x + lineWidth/2;
  y1 = y - lineHeight/2;
  
  line(x1, y1, x2, y1);
}

/**
 * Dessine l'encart contenant les règles
 **/
void drawRules() {
  fill(255);
  stroke(0);
  textAlign(TOP, LEFT);
  PShape rulesRect = createShape();
  rulesRect.beginShape();
    rulesRect.vertex(150, 350);
    rulesRect.vertex(350, 350);
    rulesRect.vertex(350, 660);
    rulesRect.vertex(150, 660);
  rulesRect.endShape(CLOSE);
  
  float x, y, lineSize;
  
  x = 150;
  y = 350;
  
  lineSize = (660.0-350.0)/rules.length;
  
  shape(rulesRect);
  
  for(int i=0; i < rules.length; i++) {
    drawRule(x, y, lineSize, rules[i].split("\t"));
    y+=lineSize;
  }
}

//Draws a rule in the visual Rules container
void drawRule(float x, float y, float lineSize, String[] rule) {
  int ruleNumber = Integer.parseInt(rule[0]);
  String ruleLabel = rule[1];
  String ruleDefinition = rule[2];
  
  //Draws the three on a single visual row
  //stroke(0);
  fill(0);
  stroke(0);
  
  if(ruleNumber == currentRule) {
    fill(255, 0, 0); 
  }
  
  int firstSeparatorOffset = 35;
  int secondSeparatorOffset = 70;
  
  text(ruleNumber, x + 2, y + lineSize);
  text(ruleLabel, x + firstSeparatorOffset + 2, y + lineSize);
  text(ruleDefinition, x + secondSeparatorOffset + 2, y + lineSize);
  
  line(x + firstSeparatorOffset, y, x + firstSeparatorOffset, y + lineSize);
  line(x + secondSeparatorOffset, y, x + secondSeparatorOffset, y + lineSize);
}


/**
 * Dessine Idem 
 **/
void drawInputTextbox(int x, int y , int w, int h, int r, int pct, color c1, String t, int s, color c2) {

  int rectInputTextBoxX = x;
  int rectInputTextBoxY = y;
  int rectInputTextBoxW = w;
  int rectInputTextBoxH = h;
  int rectInputTitleW = w * pct / 100;
  
  int borderRad0 = 0;
  int borderRad1 = r;
  
  fill(c1);
  rect(rectInputTextBoxX, rectInputTextBoxY, rectInputTitleW  , rectInputTextBoxH, borderRad1, borderRad0, borderRad0, borderRad1);
  
  int rectInputContentX = rectInputTextBoxX + rectInputTitleW;
  int rectInputContentY = rectInputTextBoxY;
  
  fill(255, 255, 255);
  rect(rectInputContentX, rectInputContentY, rectInputTextBoxW - rectInputTitleW, rectInputTextBoxH, borderRad0, borderRad1, borderRad1, borderRad0);  
 
  fill(c2);
  textSize(s);
  text(t, rectInputTextBoxX + 10, rectInputTextBoxY + rectInputTextBoxH / 2 + s / 2); 
  
  fill(255, 255, 255);
}


/**
 * Affiche l'input 
 **/
void printInput(String[] t) {   
    int x = 230;
    int y = 31;
    
    int nbElementsToShow = min(t.length, 10);
    
    String[] truncatedInput = java.util.Arrays.copyOfRange(t, 0, nbElementsToShow);
       
    String bef = String.join(" ", Arrays.copyOfRange(t, 0, 1)) + " ";
    String aft = "";
    if(truncatedInput.length > 1)
      aft = String.join(" ", Arrays.copyOfRange(t, 1, truncatedInput.length));
             
    fill(0,220,0);           
    text(bef, x, y);

    fill(0);
    text(aft, x + textWidth(bef), y);
  
    fill(255);
}

void printOutput(String output) {   
    int x = 230;
    int y = 71;
    
    String[] outputArr = output.split(" ");
    
    int nbElementsToShow = min(outputArr.length, 10);
    
    String[] truncatedOutput = java.util.Arrays.copyOfRange(outputArr, outputArr.length - nbElementsToShow, outputArr.length);
         
    fill(0);
    text(String.join(" ", truncatedOutput), x, y);
  
    fill(255);
}

void printCenter(String txt, color col) {
   fill(col);
   textSize(30);
   text(txt, 150, 250);
   textSize(20);
   fill(255);
}
