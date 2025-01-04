class TestKFPlayerController extends KFPlayerController;

var string s;

exec function Fire(optional float F)
{
	super.Fire(F);
	TestFunc();
}

function TestFunc()
{
    local int A[2]; //статический массив
    local array<int> B; //динамический массив
    local int i;
    i = 0;

	//вывод элементов статического массива
    for( i=0; i<2; i++ )
    {
        A[i] = Rand(101);
        ClientMessage( "A[" $ i $ "]=" $ A[i]);
    }

    B[0] = Rand(101);
    B[1] = Rand(101);

	//вывод элементов динамического массива
    for( i=0; i<B.Length; i++ )
    {
        ClientMessage( "B[" $ i $ "]=" $ B[i]);
    }

	//удаление первого элемента динамического массива
    B.Remove(0,1);
    ClientMessage("Remove B[0]");

    for( i=0; i<B.Length; i++ )
    {
        ClientMessage( "B[" $ i $ "]=" $ B[i]);
    }
}