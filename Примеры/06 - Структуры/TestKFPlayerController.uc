class TestKFPlayerController extends KFPlayerController;

//структура "игрок" из 3х полей: имя, здоровье и кол-во убитых
struct MyPlayer
{
   var string Name;
   var byte Health;
   var int Frags;
};

exec function Fire(optional float F)
{
	super.Fire(F);
	TestFunc();
}

function TestFunc()
{
    local MyPlayer p1; //объявление переменной структуры

	//присвоение значений полям
    p1.Name = "UPlayer";
    p1.Health = 100;
    p1.Frags = 2;
	
	//вывод значения поля
    ClientMessage("Create new player with name " $ p1.Name);
}