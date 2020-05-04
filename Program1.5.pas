program stopgame;

uses
  crt, system;

type 
  ControlGame = (run, stop, exit);
  ControlPlayer= (up, down, left, right);  
var 
  gameState : ControlGame;  
  playerControl : ControlPlayer;
  period: integer;
  nextTick : DateTime;
  
  
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
  waitTime : integer;//milliseconds
  nowTime: DateTime;
begin
  nowTime := DateTime.Now;
  
  if nowTime < nextTick then
  begin
    waitTime := nextTick.Subtract(nowTime).Milliseconds;
    delay (waitTime);
  end;
  
  nextTick := nowTime.AddMilliseconds(period);
end;
 
Procedure UserInterfase;
begin
  gotoxy(1,1);
  write(PlayerControl, '    ');
end;
 
begin
  gameState := ControlGame.run;
  period := 100; //микросекунд
 
  clrscr;
 
  while gameState <> ControlGame.exit do
  begin
    
    WhaitTick;   
    
    ReadControl;
    
    UserInterfase;
  end;
end.