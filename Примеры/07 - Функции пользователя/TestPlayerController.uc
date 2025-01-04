class TestPlayerController extends PlayerController;

auto state PlayerWaiting
{
	exec function StartFire( optional byte FireModeNum )
	{
		TestFunc();
	}
}

function TestFunc()
{
    local float a;
    a = FRand()*10;
    CircleFunc(a); //вызов пользовательской функции
}

//функция определения параметров окружности по заданному радиусу
function CircleFunc(float r)
{
     ClientMessage("R = " $ r);
     ClientMessage("D = " $ 2*r);
     ClientMessage("C = " $ 2*PI*r);
     ClientMessage("S = " $ PI*r*r);
}