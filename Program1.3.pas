program stopgame;

uses
  crt, system;

type 
  ControlGame = (run, stop, exit);
    
var 
  gameState : ControlGame;  
  period, waitTime : integer;
  nextTick, nowTime : DateTime;
  
procedure ReadControl;
var
  key : char;
begin
  if keypressed then 
  begin
    key := readkey;
    case key of
      #27 : GameState := controlGame.exit;
    end;
  end;
end;
  
begin
  gameState := ControlGame.run;
  period := 100; //микросекунд
  
  while gameState <> ControlGame.exit do
  begin
    nowTime := DateTime.Now;
    if nowTime < nextTick then
    begin
      waitTime := nextTick.Subtract(nowTime).Milliseconds;
      delay (waitTime);
    end;
    nextTick := nowTime.AddMilliseconds(period);
  
    ReadControl;
    
  end;
end.