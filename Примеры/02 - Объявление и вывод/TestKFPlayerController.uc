class TestKFPlayerController extends KFPlayerController;

//объ€вление глобальной переменной 
var string s;

/* это многострочный вид комментари€
может примен€тьс€ дл€ больштх по€снений
и временного отключени€ некоторых функций программы*/

exec function Fire(optional float F)
{
	super.Fire(F);
	TestFunc();
}



function TestFunc()
{
	//объ€вление локальной переменной 
    local float f;
	//присвоение переменным зна€ений
    s="f = ";
    f=10;
	//вывод значений переменных
	ClientMessage(s $ f);
}