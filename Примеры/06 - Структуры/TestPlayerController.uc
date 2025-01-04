class TestPlayerController extends PlayerController;

//структура "игрок" из 3х полей: имя, здоровье и кол-во убитых
struct MyPlayer
{
   var string Name;
   var byte Health;
   var int Frags;
};

auto state PlayerWaiting
{
	exec function StartFire( optional byte FireModeNum )
	{
		TestFunc();
	}
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