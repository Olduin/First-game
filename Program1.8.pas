program stopgame;

uses
  Crt, SysUtils, DateUtils;

const
  screenWidth = 80;
  screenHeigh = 25;
  snakeMaxLeinght = 50;
  defaultPeriod = 200;
type 
  ControlGame = (run, stop, exit, gameOver);
  ControlPlayer= (up, down, left, right);
  DisplayPosition = record
    x,y: integer;
  end;
  TSnake = record
    body : array [1..snakeMaxLeinght + 1] of DisplayPosition; //В последнем элементе след от змеи
    lenght : integer;
    eat : boolean;
  end;
  TFood = record
    X, Y: integer;
  end;

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

procedure SnakeContol;
var 
  bodyCoursor : integer;
begin
  bodyCoursor := snake.lenght + 1;
  
  while bodyCoursor > 1 do
  begin
    snake.body[bodyCoursor] := snake.body[bodyCoursor - 1];
    bodyCoursor := bodyCoursor - 1;
  end;

  if gameState = ControlGame.run then
  begin
    case playerControl of
      up    : snake.body[1].Y := snake.body[1].Y - 1;
      down  : snake.body[1].Y := snake.body[1].Y + 1;
      left  : snake.body[1].X := snake.body[1].X - 1;
      right : snake.body[1].X := snake.body[1].X + 1;
    end;
  end;
end;//}

procedure SnakeDrow;
begin
  gotoxy(snake.body[1].X, snake.body[1].Y);
  write ('*');
  gotoxy(snake.body[snake.lenght + 1].X, snake.body[snake.lenght + 1].Y);
  write (' ');  
end;//}

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
  if snake.body[1].X = 1 then if playerControl = ControlPlayer.left then gameState := gameOver;  
  if snake.body[1].X = screenWidth then if playerControl = ControlPlayer.right then gameState := gameOver;  
  if snake.body[1].y = 1 then if playerControl = ControlPlayer.up then gameState := gameOver;  
  if snake.body[1].y = screenHeigh then if playerControl = ControlPlayer.down then gameState := gameOver;
  if snake.body[1].X = food.X then if snake.body[1].Y = food.Y then SnakeEat;
end;

procedure InitGame;
begin
  Randomize;
  gameState := ControlGame.stop;
  period := defaultPeriod; //микросекунд
  snake.lenght := 1;
  snake.body[1].X := random(80);
  snake.body[1].y := random(25);
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

    SnakeContol;

    SnakeDrow;

    UserInterfase;

    DetectColision;

  end;

end.