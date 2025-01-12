class Vepr12mut extends Mutator
    Config(MastersMut);

//var Vepr12mut MutV;
var() globalconfig bool bManualReload, bForceManualReload;
var globalconfig bool bAllowWeaponLock;
var transient bool bInitReplicationReceived;
var transient float FirstTickTime;
var transient bool bTickExecuted;
var() globalconfig bool bUseEnhancedScoreboard;
var localized string strLocked, strUnlocked;

replication
{
    reliable if ( bNetInitial && Role == ROLE_Authority )
        bManualReload, bForceManualReload,
        bAllowWeaponLock;
}
function PostBeginPlay()
{
	if( bUseEnhancedScoreboard)
	{
			Level.Game.ScoreBoardType = string(class'SRScoreBoard');
	}
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if ( PlayerController(Other)!=None ) 
	{
        if ( KFPCServ(Other) != none ) 
		{
            KFPCServ(Other).MutV = self;
        }
        return true;
    }
    return true;
}
simulated function PostNetReceive()
{
    super.PostNetReceive();
    if ( bInitReplicationReceived && Role < ROLE_Authority ) 
	{
        TimeLog("Additional Settings received from a server.");
        ClientInitSettings();
    }
}

simulated function TimeLog(coerce string s)
{
    log("["$String(Level.TimeSeconds - FirstTickTime)$"s]" @ s, class.outer.name);
}

simulated function PostNetBeginPlay()
{
    super.PostNetBeginPlay();
    if ( Role < ROLE_Authority ) 
	{
        TimeLog("Initial Settings received from a server.");
        ClientInitSettings();
        bInitReplicationReceived = true;
    }
}

simulated function ClientInitSettings()
{
    local KFPCServ LocalPlayer;

    if ( Role == ROLE_Authority )
        return;

    default.bManualReload = bManualReload;
    default.bForceManualReload = bForceManualReload;
    LocalPlayer = KFPCServ(Level.GetLocalPlayerController());
    if ( LocalPlayer != none ) 
	{
        LocalPlayer.MutV = self;
        LocalPlayer.LoadMutSettings();
    }
}

function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
        local int i,N;
        N = ServerState.ServerInfo.Length;
        //if(N<2) return;
        for(i=0;i<N;i++)
        {
                if(ServerState.ServerInfo[i].Key ~= "Mutator")
                {
                        ServerState.ServerInfo[i].Value="AnWey Project";
                }
        }
}

defaultproperties
{
	bAddToServerPackages=True
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
	GroupName="Vepr12"
	FriendlyName="Vepr12 mut"
	Description="Gives Vepr12."
     bOnlyDirtyReplication=False
     bNetNotify=True
     bAllowWeaponLock=True
	 bUseEnhancedScoreboard=True
}