program stopgame;

uses
  Crt, SysUtils, DateUtils;

type 
  ControlGame = (run, stop, exit, gameOver);
  ControlPlayer= (up, down, left, right);
  TSnake = record
    headX, headY : integer;
    lenght : integer;
  end;
  TFood = record
    X, Y: integer;
  end;

const
  screenWidth = 80;
  screenHeigh = 25;

var 
  gameState : ControlGame;  
  playerControl : ControlPlayer;
  period: integer;
  nextTick : TDateTime;
  snake : TSnake;
  food : TFood;  

procedure ReadControl;
var
  key : char;
begin
  if keypressed then 
  begin
    if gameState = stop then gameState := run; 
    key := readkey;
    case key of
      #27 : gameState := ControlGame.exit;
      'w' : playerControl := ControlPlayer.up;
      's' : playerControl := ControlPlayer.down;
      'a' : playerControl := ControlPlayer.left;
      'd' : playerControl := ControlPlayer.right;
    end;
  end;
end;
  
procedure WhaitTick;
var
  waitTime : integer;
  nowTime: TDateTime;
begin
  nowTime := Now;
  
  if nowTime < nextTick then
  begin
    waitTime := MilliSecondsBetween(nextTick, nowTime);
    delay (waitTime);
  end;
  
  nextTick := IncMilliSecond(nowTime, period);
end;

procedure PutFood;
begin
  food.X := random(80);
  food.Y := random(25);
  gotoxy(food.X, food.Y);
  write('0');
end;

procedure SnakeMove;
begin
  if gameState = ControlGame.run then
  begin
    gotoxy(snake.HeadX, snake.HeadY);
    write(' ');
    case playerControl of
      up    : snake.HeadY := snake.HeadY - 1;
      down  : snake.HeadY := snake.HeadY + 1;
      left  : snake.HeadX := snake.HeadX - 2;
      right : snake.HeadX := snake.HeadX + 2;
    end;
    gotoxy(snake.HeadX, snake.HeadY);
    write('*');
  end;
end;

procedure SnakeEat;
begin
  snake.lenght := snake.lenght + 1;
  PutFood;
end;

Procedure UserInterfase;
begin
  gotoxy(1,1);
  write(PlayerControl:10, gameState: 10, food.X: 5, food.Y:5, snake.lenght:5);
end;

procedure DetectColision;
begin
  if snake.HeadX = 1 then if playerControl = ControlPlayer.left then gameState := gameOver;  
  if snake.HeadX = screenWidth then if playerControl = ControlPlayer.right then gameState := gameOver;  
  if snake.Heady = 1 then if playerControl = ControlPlayer.up then gameState := gameOver;  
  if snake.Heady = screenHeigh then if playerControl = ControlPlayer.down then gameState := gameOver;
  if snake.HeadX = food.X then if snake.HeadY = food.Y then SnakeEat;
end;

procedure InitGame;
begin
  Randomize;
  gameState := ControlGame.stop;
  period := 100; //микросекунд
  snake.HeadX := random(80);
  snake.HeadY := random(25);
  PutFood;
end;

begin

  CursorOff;
  ClrScr;
  InitGame;
 
  while gameState <> ControlGame.exit do
  begin
    
    WhaitTick;   
    
    ReadControl;
    
    SnakeMove;

    UserInterfase;

    DetectColision;

  end;

end.