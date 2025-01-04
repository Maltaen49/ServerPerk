//класс "часы с будильником" наследник класса "абстрактные часы"
class AlarmClock extends AbstractClock;

//переопределение функции "звонок"
function string Ring()
{
  return "Clock is ringing!";
}