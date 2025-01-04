class TestKFPlayerController extends KFPlayerController;

exec function Fire(optional float F)
{
	super.Fire(F);
	TestFunc();
}

function TestFunc()
{
    local Clock c1; //объявляем объект
    c1 = Spawn(class'Clock'); // используем библиотечную функцию для создания объекта
    ClientMessage("Default alarm set to " $ c1.ClockAlarmTime.Hour $ ":" $ c1.ClockAlarmTime.Minute);
    ClientMessage(c1.Ring()); //вызов в состоянии "будильник выключен"
    c1.GotoState('AlarmOn');  //переход в другое состояние
    ClientMessage(c1.Ring()); //вызов в состоянии "будильник включен"
}