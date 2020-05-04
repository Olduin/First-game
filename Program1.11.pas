program rstopgame;

uses
  Crt, SysUtils, DateUtils;//ыфв

const
  screenWidth = 80;//длина окна
  screenHeigh = 25;//ширина окна
  snakeMaxLeinght = 50;//максимальная длина змеи
  defaultPeriod = 120;//период ожидания Тика
type 
  ControlGame = (run, pause, exit, gameOver);//состояния игры
  ControlPlayer= (up, down, left, right); //
  DisplayPosition = record //используем записи для позиции на дисплее
    x,y: integer;//Координаты на осях x,y
  end;
  TSnake = record// тип "записи" для змеи
    body : array [1..snakeMaxLeinght + 1] of DisplayPosition; //В последнем элементе след от змеи затирается
    lenght : integer;//длина змеи
    eat : boolean; //ест или нет
  end;
  TFood = record // записи для еды
    X, Y: integer;//Координаты на осях x,y
  end;

var 
  gameState : ControlGame;  
  playerControl : ControlPlayer;
  period: integer;
  nextTick : TDateTime;
  snake : TSnake;
  food : TFood;  

procedure ReadControl;// считывание нажатий клавиш
var
  key : char; //Символьный тип
begin
  if keypressed then  //считывание нажатия клавиши
  begin
    if gameState = pause then gameState := run; //Переход из паузы в состояние игры нажатием любой клавиши
    key := readkey; //присваивание символа нажатой клавиши
    case key of //в случае если
      #27 : gameState := ControlGame.exit; // клавиша "Esc" - выход из игры
      'w' : playerControl := ControlPlayer.up; //Присваевание состояния up
      's' : playerControl := ControlPlayer.down;//Присваевание состояния down
      'a' : playerControl := ControlPlayer.left;//Присваевание состояния left
      'd' : playerControl := ControlPlayer.right;//Присваевание состояния right
      'p',' ' : gameState := ControlGame.pause; //Присваевание состояния pause
    end;
  end;
end;
  
procedure WhaitTick; //Ожидание считывания
var
  waitTime : integer;//время ожидания
  nowTime: TDateTime;//наст. время
begin
  nowTime := Now;//Присваивание настоящего времени
  
  if nowTime < nextTick then // проверка задержки
  begin
    waitTime := MilliSecondsBetween(nextTick, nowTime); //получение разницы между временем следующего считывания и настоящим временем 
    delay (waitTime);//ожидаем полученную разницу
  end;
  
  nextTick := IncMilliSecond(nowTime, period);//Прибавляем к наст. времени период ожидания
end;

procedure PutFood; //Бросаем хавчик
begin
  food.X := random(screenWidth - 10) + 5;//Позиция Х
  food.Y := random(screenHeigh -4) + 2; //Позиция Y
  gotoxy(food.X, food.Y);//помещение ягоды по координатам
  write('0');//вывод еды на экран
end;

procedure SnakeContol;// Управление змеёй
var 
  bodyCoursor : integer; //положение змеи
begin
  bodyCoursor := snake.lenght + 1;
  
  while bodyCoursor > 1 do
  begin
    snake.body[bodyCoursor] := snake.body[bodyCoursor - 1]; //
    bodyCoursor := bodyCoursor - 1;//перемещаемся по элементам массива в обратную сторону
  end;

  if gameState = ControlGame.run then //проверка состояния игры
  begin
    case playerControl of // в случае если состояние игрока...
      up    : snake.body[1].Y := snake.body[1].Y - 1;//Движение вверх
      down  : snake.body[1].Y := snake.body[1].Y + 1;//Движение вниз
      left  : snake.body[1].X := snake.body[1].X - 1;//Движение влево
      right : snake.body[1].X := snake.body[1].X + 1;//Движение вправо
    end;
  end;
end;//}

procedure SnakeDrow;//Отображение змеи на экране
begin
  gotoxy(snake.body[1].X, snake.body[1].Y);//перемещаем курсор в заданные координаты
  write ('*');//отрисовываем элемент змеи
  gotoxy(snake.body[snake.lenght + 1].X, snake.body[snake.lenght + 1].Y);
  write (' ');  //затираем последний элемент
end;//}

procedure SnakeEat;//Змей съел хавку
begin
  snake.lenght := snake.lenght + 1;//увеличиваем длину змеи
  PutFood;//вызываем процедуру
end;

Procedure UserInterfase;//Интерфейс пользователя
begin
  gotoxy(1,1);// в первой строке первого столбца
  write(PlayerControl:10, gameState: 10, food.X: 5, food.Y:5, snake.lenght:5);//вывод интерфейса
end;

procedure DetectColision;//Обработка коллизий
var
  bodyCoursor : integer;
  snakeHead : DisplayPosition;//голова змеи
begin
  if snake.body[1].X = 1 then if playerControl = ControlPlayer.left then gameState := gameOver;  //проверки упирания в стены
  if snake.body[1].X = screenWidth then if playerControl = ControlPlayer.right then gameState := gameOver;  
  if snake.body[1].y = 1 then if playerControl = ControlPlayer.up then gameState := gameOver;  
  if snake.body[1].y = screenHeigh then if playerControl = ControlPlayer.down then gameState := gameOver;
  if snake.body[1].X = food.X then if snake.body[1].Y = food.Y then SnakeEat;//проверка попадания в еду

  snakeHead := snake.body[1];//Присваеваем координаты 1-го элемента массива
  for bodyCoursor := 2 to snake.lenght do 
  begin
    if snakeHead.X = snake.body[bodyCoursor].X then //проверка на наползание змеи на саму себя
      if snakeHead.Y = snake.body[bodyCoursor].Y then gameState := gameOver;
  end;
end;

procedure InitGame;//Инициализация
begin
  Randomize;
  gameState := ControlGame.pause;//Изначально состояние игры - "пауза"
  period := defaultPeriod; //микросекунд
  snake.lenght := 1;//Длина приравнивается к 1
  snake.body[1].X := random(screenWidth - 10) +5;//случайные значения в указанном диапазоне
  snake.body[1].y := random(screenHeigh -4) +2; //случайные значения в указанном диапазоне
  PutFood;//вызываем процедуру (Знаю, что неправильно)
end;

begin

  CursorOff; //Выклшючаем курсор

  ClrScr; //отчищаем строки
  
  InitGame;
 
  while gameState <> ControlGame.exit do //пока состояние игры не "exit"
  begin
    
    WhaitTick;   
    
    ReadControl;

    SnakeContol;

    SnakeDrow;

    UserInterfase;

    DetectColision;

  end;

end.