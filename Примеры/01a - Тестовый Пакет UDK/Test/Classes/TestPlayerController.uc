class TestPlayerController extends PlayerController;

var name n;

auto state PlayerWaiting
{
	exec function StartFire( optional byte FireModeNum )
	{
		TestFunc();
	}
}

function TestFunc()
{
  //Здесь можно писать код примеров
  ClientMessage("Test");
}