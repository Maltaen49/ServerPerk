//класс "Часы"
//автор Metalmedved

class Clock extends Actor;

//структура "время будильника"
struct AlarmTime
{
   var byte Hour;
   var byte Minute;
};

//переменная "время будильника"
var AlarmTime ClockAlarmTime;

//функция установки времени будильника
function string SetAlarm(byte h, byte m)
{
    ClockAlarmTime.Hour = h;
    ClockAlarmTime.Minute = m;
    IsSetAlarm = true;
    return "Alarm is set";
}

//если объект не находится ни в одном состоянии, будет вызвана эта версия функции
function string Ring()
{
  return "Clock doesn't set to any state";
}

//состояние "будильник включен"
state AlarmOn
{
  function string Ring()
  {
    return "Clock is ringing!";
    GotoState('AlarmOff');
  }
}

//состояние по умолчанию "будильник отключен"
auto state AlarmOff
{
  function string Ring()
  {
     return "Alarm is off. No ringing";
  }
}

//блок значений переменых по умолчанию
defaultproperties
{
    ClockAlarmTime = (Hour=0,Minute=0)
}


