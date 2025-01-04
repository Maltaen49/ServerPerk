class TestMut extends Mutator;

function PostBeginPlay()
{
	if( Level.Game.PlayerControllerClass==Class'KFPlayerController' )
	{
		Level.Game.PlayerControllerClass = Class'TestKFPlayerController';
		Level.Game.PlayerControllerClassName = string(Class'TestKFPlayerController');
	}	
}

defaultproperties
{
    GroupName="KFTestMutator"
    FriendlyName="Test Mutator"
    Description="Mutator description here"
}
