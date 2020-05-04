program stopgame;

uses
  Crt, SysUtils, DateUtils;

type 
  ControlGame = (run, stop, exit);
  ControlPlayer= (up, down, left, right);  

const
  screenWidth = 80;
  screenHeigh = 25;

var 
  gameState : ControlGame;  
  playerControl : ControlPlayer;
  period: integer;
  nextTick : TDateTime;
  snakeHeadX, snakeHeadY: integer;

procedure InitGame;
begin
  Randomize;
  gameState := ControlGame.run;
  period := 100; //микросекунд
  snakeHeadX := random(80);
  snakeHeadY := random(25);
end;
  
procedure ReadControl;
var
  key : char;
begin
  if keypressed then 
  begin
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
 
procedure SnakeMove;
begin
  gotoxy(snakeHeadX, snakeHeadY);
  write(' ');
  case playerControl of
    up    : snakeHeadY := snakeHeadY - 1;
    down  : snakeHeadY := snakeHeadY + 1;
    left  : snakeHeadX := snakeHeadX - 2;
    right : snakeHeadX := snakeHeadX + 2;
  end;
  gotoxy(snakeHeadX, snakeHeadY);
  write('*');
end;


Procedure UserInterfase;
begin
  gotoxy(1,1);
  write(PlayerControl, '    ');
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

  end;

end.