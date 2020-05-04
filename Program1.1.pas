program stopgame;

uses
  crt, system;

type 
  ControlGame = (run, stop, exit);
    
var 
  gameState : ControlGame;  
  key : char;
  
begin
  gameState := ControlGame.run;
  
  while gameState <> ControlGame.exit do
  begin
    if keypressed then 
    begin
      key := readkey;
      case key of
        #27 : GameState := controlGame.exit;
      end;
    end;
  end;

end.