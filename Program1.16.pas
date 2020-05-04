program Snakee;

//подключение модулей
uses
  Crt,//Управление текстом на экране дисплея,
  SysUtils,//Системные функции
  DateUtils;//Обработка календарных дат и интервалов времени
  
//объявление констант
const
  screenWidth = 80;//ширина экрана
  screenHeigh = 25;//высота экрана
  snakeMaxLeinght = 100;//максимальная длина змеи
  defaultPeriod = 120;//период по умолчанию
  gameOverText = 'GAME OVER';//сообщение конец игры
  gamePauseText = 'PAUSE';//сообщение пауза

  gameArenaBgColor = Green;//цвет игровой области
  gameArenaFgColor = Black;//цвет 
  uiBgColor = Yellow;
  uiFgColor = Black;

//объявление типов
type 
  ControlGame = (run, pause, exit, gameOver);//Состояние игры: "запущен", "пауза", "выход", "конец игры"
  ControlPlayer= (up, down, left, right); //Команды управления "вверх", "вниз", "влево", "вправо"
  DisplayPosition = record //Позиции на игровом поле
    x,y: integer;//положение по осям
  end;
  
  TSnake = record // Модель змеи
    body : array [1..snakeMaxLeinght + 1] of DisplayPosition; //тело змеи
    lenght : integer;//длина змеи
    eat : boolean; //признак поедания
  end;
  
  TFood = record // модель еды
    X, Y: integer;//положение по осям
  end;

//объявление переменных
var 
  gameState : ControlGame;  //содержание состояния игры
  playerControl : ControlPlayer;//ввод пользвателя
  period: integer;//период между тика
  nextTick : TDateTime;//время начала следующего тика
  snake : TSnake;//модель змеи
  food : TFood;//модель змеи

// получение ввода пользователя
procedure ReadControl;
var
  key : char; //введённый символ
begin
  if keypressed then  //если нажата клавиша?
  begin
    if gameState = pause then gameState := run; //Переход из паузы в состояние игры нажатием любой клавиши
    key := readkey; //получение символа нажатой клавиши
    //в зависимости от нажатой клавиши изменяем состояние игры и управления змеёз
    case key of 
      #27 : gameState := ControlGame.exit; // изменяется состояние игры на "выход"
      'p',' ' : gameState := ControlGame.pause; //изменяется состояние игры на "пауза"

      'w' : playerControl := ControlPlayer.up; //Присваевание состояния "вверх"
      's' : playerControl := ControlPlayer.down;//Присваевание состояния "вниз"
      'a' : playerControl := ControlPlayer.left;//Присваевание состояния "Влево"
      'd' : playerControl := ControlPlayer.right;//Присваевание состояния "вправо"
      
    end;
  end;
end;
  
//Ожидание времени следующего тика
procedure WaitTick; 
var
  waitTime : integer;//время ожидания
  nowTime: TDateTime;//наст. время
begin
  nowTime := Now;//Получение настоящего времени
  
  if nowTime < nextTick then // если время тика ещё не наступило
  begin
    waitTime := MilliSecondsBetween(nextTick, nowTime); //расчитываем оставшееся до тика время в милисекундах
    delay (waitTime);//ожидаем полученное время
  end;
  
  nextTick := IncMilliSecond(nowTime, period);//рассчитываем время следующего тика
end;

//размещение еды на игровом поле
procedure PutFood; 
begin
  //размещаем еду не ближе 5 позиций от края игрового поля
  TextColor(gameArenaFgColor);
  food.X := random(screenWidth - 10) + 5;//Позиция Х
  food.Y := random(screenHeigh -4) + 2; //Позиция Y
  gotoxy(food.X, food.Y);//помещение еды по координатам
  write('0');//вывод еды на экран
end;

// Управление змеёй
procedure SnakeContol;
var 
  bodyCoursor : integer; //указатель позиции текущего элемента змеи 
begin
  if gameState = ControlGame.run then //Если состояния игры "запущен"
  begin
    bodyCoursor := snake.lenght + 1;//Устанавливаем курсор на конец змеи
    //передвигаем все элементы на один к хвосту змеи
    while bodyCoursor > 1 do //пока курсор не указывает на голову
    begin
      snake.body[bodyCoursor] := snake.body[bodyCoursor - 1]; //к каждому элементу тела змеи присваеваем значение предыдущего
      bodyCoursor := bodyCoursor - 1;//передвигаем курсор на 1 позицию вперёд
    end;
  
    //в зависимости от состояния управления сдвигаем голову змеи
    case playerControl of 
      up    : snake.body[1].Y := snake.body[1].Y - 1;//Движение вверх
      down  : snake.body[1].Y := snake.body[1].Y + 1;//Движение вниз
      left  : snake.body[1].X := snake.body[1].X - 1;//Движение влево
      right : snake.body[1].X := snake.body[1].X + 1;//Движение вправо
    end;
  end;
end;

//Отрисовка змеи на экране
procedure SnakeDrow;
begin
  TextColor(gameArenaFgColor);
  TextBackground(gameArenaBgColor);
  gotoxy(snake.body[1].X, snake.body[1].Y);//перемещаем курсор в координаты головы змеи
  write ('*');//отрисовываем элемент змеи
  
  gotoxy(snake.body[snake.lenght + 1].X, snake.body[snake.lenght + 1].Y);//перемещаем курсор за хвост змеи
  write (' ');  //стираем элемент после хвоста
end;

//отрисовка игровой области

procedure GameArenaDrow;
var 
  counterLine : Integer;//счётчик линий
  fillLine : String;//Строка заполнения
begin
  FillChar(fillLine, screenWidth, ' ');//Заполнение линии пробелами
  SetLength(fillLine, screenWidth);//установка длины линии

  TextBackground(uiBgColor);//Установка фона интерфейса пользователя
  GotoXY(1,1);//Перемещение курсора в начало первой строки
  Write(fillLine);//Отрисовка пользовательского интерфейса

  TextBackground(gameArenaBgColor);//Установка цвета фона игровой области
  for counterLine := 2 to screenHeigh do //от первой строки до конца игровой области
  begin
    GotoXY(1, counterLine);//Установка курсора на текущую линию игровой области
    Write(fillLine);//Отрисовка текущей линии игрового поля
  end;

end;

//кормление змеи
procedure SnakeEat;
begin
  snake.lenght := snake.lenght + 1;//увеличиваем длину змеи
  PutFood;//вызываем процедуру размещения новой еды
end;

// Вывод сообщения в центр игровой области
procedure ShowMessage(messageText : String);
begin
    GotoXY((screenWidth - Length(messageText)) div 2, screenHeigh div 2);// размещаем курсор по середине экрана
    write(gameOverText);// выводим сообщение
end;

//Интерфейс пользователя
Procedure UserInterfase;
var 
  messageUI:String;//Текст сообщения в интерфейсе пользователя
begin
  TextBackground(uiBgColor);//Установка фона в интерфейсе пользователя
  TextColor(uiFgColor);//установка цвета текста в интерфейсе пользователя
  case  gameState of// В зависимости от состояния игры устанавливаем текст сообщения
    ControlGame.pause : messageUI := gamePauseText;//При паузе
  else
    messageUI := '';//В других случаях
  end;

  gotoxy(1,1);// помещаем курсор в начало первой строки 
  write( 'Очков:', snake.lenght:5, '   ', messageUI:20);//выводим данные
    
  if gamestate = ControlGame.gameOver then //если игра стоит на паузе
  begin
    ShowMessage(gameOverText);//Вывод сообщения на экран
  end;
  
end;

//Обработка коллизий
procedure DetectColision;
var
  bodyCoursor : integer;//указатель на текущий элемент змеи
  snakeHead : DisplayPosition;//положение головы змеи
begin
  //проверка пересечения границ игровой области
  if snake.body[1].X = 1 then if playerControl = ControlPlayer.left then gameState := gameOver;  //слева
  if snake.body[1].X = screenWidth then if playerControl = ControlPlayer.right then gameState := gameOver; //справа 
  if snake.body[1].y = 1 then if playerControl = ControlPlayer.up then gameState := gameOver;  //сверху
  if snake.body[1].y = screenHeigh then if playerControl = ControlPlayer.down then gameState := gameOver;//снизу
  
  if snake.body[1].X = food.X then if snake.body[1].Y = food.Y then SnakeEat;//проверка пересечения с едой

  //проверка пересечения с телом змеи
  snakeHead := snake.body[1];// получаем положение головы змеи
  for bodyCoursor := 2 to snake.lenght do //бежим курсором по телу змеи
  begin
    //если голова пересеклось с телом
    if snakeHead.X = snake.body[bodyCoursor].X then 
      if snakeHead.Y = snake.body[bodyCoursor].Y then 
        gameState := gameOver; //присваеванием состоянию игры "конец игры"
  end;
end;

//установка начального состояния
procedure InitGame;
begin
  GameArenaDrow;
  Randomize;//инициализация генератора случайных чисел
  gameState := ControlGame.pause;//Установка состояния игры на "паузу"
  period := defaultPeriod; //устоновка периода по умолчанию
  snake.lenght := 1;//Установка начальной длины змеи
  //размещение знеи на игровом поле
  snake.body[1].X := random(screenWidth - 10) +5;//не ближе 5 элементов от края игрового поля
  snake.body[1].y := random(screenHeigh -4) +2; //не ближе 5 элементов от края игрового поля
  PutFood;//вызываем процедуру размещения еды
end;


/////////////////////////////////////////////////////////////////////////////////////////
//Начало программы
begin

  CursorOff; //Выклшючаем курсор

  ClrScr; //отчищаем строки
  
  InitGame;//начальные установки
  //основной цикл
  while gameState <> ControlGame.exit do //пока состояние игры не "выход"
  begin

    SnakeDrow;//Отрисовка змеи на экране
    
    ReadControl; //// получение ввода пользователя

    SnakeContol;// Управление змеёй

    UserInterfase;//Интерфейс пользователя

    DetectColision;//Обработка коллизий

    WaitTick;  // Ожидание времени следующего тика

  end;

end.