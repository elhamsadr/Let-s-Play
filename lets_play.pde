

import java.util.Vector;

//-----------------------------------------setup method-----------------------------------------
float d=40;
Player myPlayer;
GameMap myMap;

void setup() {
        
        size(1000, 1100);
        fill(0,0,255);
        myMap   = new GameMap(d, d ,200);
        myPlayer= new Player( width/2 , height-d ,d , d, color(255,100,0) ); 
        
        frameRate(2000);

}
//----------------------------------------draw method---------------------------------------------
void draw() {
    background(255);
    myPlayer.display();
    shape( myMap.moveMap() );
    for (Obstacle obs : myMap.obstacles) {
            if ( myPlayer.collisionDetected ( obs )  ){
                noLoop();  
                println("!!  YOU LOST  !!");
            }
        }
    
}

//-----------------------PLAYER CLASS-----------------------------------------------------------------------

 public class Player {
    PVector  playerPosition;
    PVector  playerDimention;
    color clr;
    
    public Player ( float xPos ,float yPos ,float  wDim , float hDim , color c ) 
    {
       playerPosition=new PVector(xPos, yPos);
       playerDimention=new PVector (wDim , hDim);
       clr=c;
    }

    public void display ()
      {   
            this.playerPosition.x= mouseX;
            fill(clr);
            ellipse(playerPosition.x, playerPosition.y , playerDimention.x, playerDimention.y );
      }
      
    public boolean collisionDetected ( Obstacle gameObstacle ) ////////////////cheeeeeeeeeeeeeeckkkkkkkkk
      {  
          

                 if  ( playerPosition.x-playerDimention.x<= gameObstacle.bottomRightCorner.x  && 
                       playerPosition.x-playerDimention.x > gameObstacle.bottomLeftCorner.x    &&
                       playerPosition.y-playerDimention.y<= gameObstacle.bottomRightCorner.y &&
                       playerPosition.y+playerDimention.y >= gameObstacle.topRightCorner.y )
                        return true;
                 else if ( playerPosition.x+ playerDimention.x >= gameObstacle.bottomLeftCorner.x  && 
                           playerPosition.x+playerDimention.x < gameObstacle.bottomRightCorner.x    &&
                           playerPosition.y-playerDimention.y<= gameObstacle.bottomLeftCorner.y &&
                           playerPosition.y+playerDimention.y >= gameObstacle.topLeftCorner.y  )
                             return true;
            

            return false;

      }

}


//-----------------------OBSTACLE CLASS---------------------------------------------------------------------
public class Obstacle  {
    
    float obstacleWidth;
    float obstacleHeight;

    PVector topLeftCorner;
    PVector topRightCorner;
    PVector bottomLeftCorner;
    PVector bottomRightCorner;
    
    PShape myShape;
    
    Obstacle(PVector bottomRightCornerPosition , float  obsWidth ,float obsHeight)  {    //constructor
        this.obstacleWidth = obsWidth;
        this.obstacleHeight = obsHeight;
        
        topLeftCorner     = new PVector( bottomRightCornerPosition.x - obstacleWidth, bottomRightCornerPosition.y - obstacleHeight);
        topRightCorner    = new PVector(bottomRightCornerPosition.x , bottomRightCornerPosition.y - obstacleHeight);
        bottomRightCorner = bottomRightCornerPosition;
        bottomLeftCorner  = new PVector(bottomRightCornerPosition.x - obstacleWidth, bottomRightCornerPosition.y);

        this.createBlockShape();
    }

    public PShape getBlockShape()
    {
        return this.myShape;
    }

    void moveDown()
    {
        topLeftCorner.add(0,1);
        topRightCorner.add(0,1);
        bottomLeftCorner.add(0,1);
        bottomRightCorner.add(0,1);
       
        this.createBlockShape();// Create a new block one pixel lower than its previous location
    }

    public void createBlockShape() //private   !!!!!!
    {
        this.myShape = createShape(RECT, this.topLeftCorner.x, this.topLeftCorner.y, obstacleWidth, obstacleHeight);
    }

    public boolean hasIntersection(PVector newBlockBottomRightCorner , float newBlockWidth, float newBlockHeight, PVector boundary)// check if the proposed position for new block has intersection with previous ones
     {
       PVector newBlockTopLeft     = new PVector(newBlockBottomRightCorner.x - newBlockWidth - boundary.x , newBlockBottomRightCorner.y - newBlockHeight - boundary.y);
       PVector newBlockBottomLeft  = new PVector(newBlockBottomRightCorner.x - newBlockWidth - boundary.x , newBlockBottomRightCorner.y + boundary.y);
       PVector newBlockTopRight    = new PVector(newBlockBottomRightCorner.x + boundary.x , newBlockBottomRightCorner.y - newBlockHeight -boundary.y);
       PVector newBlockBottomRight = new PVector(newBlockBottomRightCorner.x + boundary.x , newBlockBottomRightCorner.y + boundary.y);
       
       boolean itHasCollision =(( newBlockBottomLeft.x <= this.topRightCorner.x && newBlockBottomLeft.x > this.topLeftCorner.x)   && ( newBlockBottomLeft.y >= this.topRightCorner.y && newBlockBottomLeft.y < this.bottomRightCorner.y)) ||
                               (( newBlockBottomRight.x >= this.topLeftCorner.x && newBlockBottomRight.x < this.topRightCorner.x) && ( newBlockBottomRight.y >= this.topLeftCorner.y && newBlockBottomRight.y < this.bottomLeftCorner.y)) ||
                               (( newBlockTopLeft.x <= this.bottomRightCorner.x && newBlockTopLeft.x > this.bottomLeftCorner.x)   && ( newBlockTopLeft.y <= this.bottomRightCorner.y && newBlockTopLeft.y > this.topRightCorner.y))||
                               (( newBlockTopRight.x >= this.bottomLeftCorner.x && newBlockTopRight.x < this.bottomRightCorner.x) && ( newBlockTopRight.y <= this.bottomLeftCorner.y && newBlockTopRight.y > this.bottomLeftCorner.y)) ;
                            
       return itHasCollision;
     }


}

//------------------------------------------GameMap Class--------------------------------------------
public class GameMap {
    Vector<Obstacle> obstacles = new Vector<Obstacle>(); //ArrayList<Obstacle> obstacles=new ArrayList<Obstacle>();
    PShape  mapShape = createShape(GROUP);
    PVector blockBoundary;
    float   minY = 0;
    final float blockWidth;

    GameMap(float minXDistance, float minYDistance, float blkWidth) { // constructor
        this.blockBoundary = new PVector(minXDistance, minYDistance);
        this.blockWidth    = blkWidth;
    }

    public void generateBlock(PVector newBlockPosition, float newBlockwidth, float newBlockHeight) {
        // Check for any intersection with any other block inside obstacles vector boundary 
        // if not ... new a block and add it to obstacles
        for (Obstacle obs : obstacles) {
            if ( obs.hasIntersection( newBlockPosition, newBlockwidth, newBlockHeight, blockBoundary) ){
                return;  // if yes ... do nothing
            }
        }
        Obstacle newBlock = new Obstacle(newBlockPosition, newBlockwidth, newBlockHeight);
        obstacles.add(newBlock);
        mapShape.addChild( newBlock.getBlockShape() );
        
    }



    // move the whole map down one pixel
    public PShape moveMap(){
        
         Obstacle tempObstacle;
         if( obstacles.size()==0){ // generate the first block in game map
             
              float newBlockBottomRightCornerY =  random( 0, minY - blockBoundary.y);//random( 0, height);
              float newBlockBottomRightCornerX = random(blockWidth, width);//each time a random width for block
              float newBlockHeight = random(100, 500);
              generateBlock(new PVector(newBlockBottomRightCornerX, newBlockBottomRightCornerY), blockWidth,newBlockHeight);
              minY= newBlockBottomRightCornerY-newBlockHeight;//?????????????

          }

        else { 
              
              mapShape.translate(0, 1);//shift down the game map 1 pixel 
              for ( int i=0; i<  obstacles.size(); i++) {  //(Obstacle obstacle : obstacles)    !!!!
                    tempObstacle=obstacles.get(i);
                    obstacles.get(i).moveDown();                              //????????????????
                    //tempObstacle.moveDown();  // obstacle.moveDown();        ????????????????
                   
                    if(tempObstacle.topLeftCorner.y > height) {  //(obstacle.topLeftCorner.y > height)  !!!!
                        obstacles.remove(i); // obstacles.remove(obstacle);  !!!
                        mapShape.removeChild(i);
                       }

                    if(minY == 0) {
                         minY = tempObstacle.topLeftCorner.y;  //minY = obstacle.topLeftCorner.y; !!!
                          } 
                    else if(tempObstacle.topLeftCorner.y < minY)  { // (obstacle.topLeftCorner.y < minY) !!!
                          minY =  tempObstacle.topLeftCorner.y; //minY =obstacle.topLeftCorner.y; // replace the top left corner of the top most block 
                       }
               }//end for

             if(minY > blockBoundary.y) {
                  // generate a new block at a random position
                  float newBlockBottomRightCornerY =  random( minY - blockBoundary.y - height, minY - blockBoundary.y );//??random( minY - blockBoundary.y, minY - blockBoundary.y - height);//!!!!!!!!! random( 0, minY - blockBoundary.y);
                  float newBlockBottomRightCornerX = random(blockWidth, width);//each time a random width for block
                  float newBlockHeight = random(100, 500);
                  generateBlock(new PVector(newBlockBottomRightCornerX, newBlockBottomRightCornerY), blockWidth,newBlockHeight);
                   }
        
            }
        return mapShape; 
    }// end of movemap  function

}
