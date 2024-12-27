// Written by Marco (2010)
Class MutSlotMachineSR extends Mutator
	Config(MutSlotMachineSR);

var const int VersionNumber;
var array<Controller> PendingPlayers;
var array<SlotsMachine> SlotMachinePlayers;
var array< class<SlotCard> > LoadedCards;

var() config float AlwaysWinChance,PerSlotPauseTime,AfterRoundPauseTime;
var() config int NewSlotKills;
var() config array<string> CardClasses;
var() config bool bNewSlotByScore,bAllowBotCards;

function PostBeginPlay()
{
	local SlotRules R;
	local int i,j;
	local class<SlotCard> C;
	local array< class<SlotCard> > Temp;
	local array<name> Packages;

	for( i=0; i<CardClasses.Length; ++i )
	{
		C = Class<SlotCard>(DynamicLoadObject(CardClasses[i],Class'Class'));
		if( C!=None )
		{
			Temp[Temp.Length] = C;
			for( j=0; j<Packages.Length; ++j )
				if( Packages[j]==C.Outer.Name )
					break;
			if( j==Packages.Length )
				Packages[Packages.Length] = C.Outer.Name;
		}
	}
	if( Temp.Length==0 )
	{
		Error("No cards available?!");
		return;
	}

	while( Temp.Length>0 ) // Randomize order.
	{
		i = Rand(Temp.Length);
		LoadedCards[LoadedCards.Length] = Temp[i];
		Temp.Remove(i,1);
	}

	Log("Adding"@Packages.Length@"additional serverpackages...",Class.Outer.Name);
	for( i=0; i<Packages.Length; ++i )
	{
		//Log(Packages[i],'Debug');
		if( Packages[i]!=Class.Outer.Name )
			AddToPackageMap(string(Packages[i]));
	}

	R = Spawn(Class'SlotRules');
	R.Mut = Self;
	R.NextGameRules = Level.Game.GameRulesModifiers;
	Level.Game.GameRulesModifiers = R;
}


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if( PlayerController(Other)!=None || (bAllowBotCards && Bot(Other)!=None) )
	{
		PendingPlayers[PendingPlayers.Length] = Controller(Other);
		SetTimer(0.1,false);
	}
	return true;
}
function Timer()
{
	local int i;
	
	for( i=0; i<PendingPlayers.Length; ++i )
	{
		if( PendingPlayers[i]!=None && (PlayerController(PendingPlayers[i])==None || PlayerController(PendingPlayers[i]).Player!=None) )
			InitPlayer(PendingPlayers[i]);
	}
	PendingPlayers.Length = 0;
}

final function InitPlayer( Controller P )
{
	local SlotsMachine S;

	S = Spawn(Class'SlotsMachine',P);
	if( S==None )
		return;
	S.Mut = Self;
	S.CardsList = LoadedCards;
	SlotMachinePlayers[SlotMachinePlayers.Length] = S;
	if( PlayerController(P)!=None && NetConnection(PlayerController(P).Player)!=None )
		S.GoToState('LoadingClient');
}
function AwardKill( Controller Other, Monster Victim )
{
	local int i;
	local SlotsMachine M;

	for( i=0; i<SlotMachinePlayers.Length; ++i )
	{
		if( SlotMachinePlayers[i].Owner==Other )
		{
			M = SlotMachinePlayers[i];
			break;
		}
	}
	if( M==None || M.NextAllowedTime>Level.TimeSeconds )
		return;
	if( bNewSlotByScore )
		M.TotalKills+=Victim.ScoringValue;
	else ++M.TotalKills;
	while( M.TotalKills>=NewSlotKills )
	{
		M.DrawNextCard();
		M.TotalKills-=NewSlotKills;
	}
}

function NotifyLogout(Controller Exiting)
{
	local int i;

	for( i=0; i<SlotMachinePlayers.Length; ++i )
	{
		if( SlotMachinePlayers[i]==None )
			SlotMachinePlayers.Remove(i--,1);
		else if( SlotMachinePlayers[i].Owner==None || SlotMachinePlayers[i].Owner==Exiting )
		{
			SlotMachinePlayers[i].Destroy();
			SlotMachinePlayers.Remove(i--,1);
		}
	}
	Super.NotifyLogout(Exiting);
}

function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	local int l;

	Super.GetServerDetails( ServerState );
	l = ServerState.ServerInfo.Length;
	ServerState.ServerInfo.Length = l+1;
	ServerState.ServerInfo[l].Key = "Slot Machines";
	ServerState.ServerInfo[l].Value = "Ver"@VersionNumber;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;
	local class<SlotCard> C;

	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.RulesGroup,"CardClasses","Cards",1,1,"Text","42",,,True);
	PlayInfo.AddSetting(default.RulesGroup,"AlwaysWinChance","Always win chance",1,0, "Text", "6;0.00:100.00");
	PlayInfo.AddSetting(default.RulesGroup,"PerSlotPauseTime","Per slot pause time",1,0, "Text", "6;0.00:999.00");
	PlayInfo.AddSetting(default.RulesGroup,"AfterRoundPauseTime","After round pause time",1,0, "Text", "6;0.00:999.00");
	PlayInfo.AddSetting(default.RulesGroup,"NewSlotKills","New card kills",1,0, "Text", "5;1:9999");
	PlayInfo.AddSetting(default.RulesGroup,"bNewSlotByScore","New cards by score",1,0, "Check");
	for( i=0; i<Default.CardClasses.Length; ++i )
	{
		C = Class<SlotCard>(DynamicLoadObject(Default.CardClasses[i],Class'Class'));
		if( C!=None )
		{
			C.Static.FillPlayInfo(PlayInfo);
			PlayInfo.PopClass();
		}
	}
}

static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "CardClasses":			return "Card classes.";
		case "AlwaysWinChance":		return "In percent, how likely it is that you always get 3 same cards.";
		case "PerSlotPauseTime":	return "Minimum pause time between earning new cards.";
		case "AfterRoundPauseTime":	return "Minimum pause time between rounds of cards.";
		case "NewSlotKills":		return "Minimum number of kills required before getting next card.";
		case "bNewSlotByScore":		return "New cards are earned by score rather than kills.";
	}
	return "";
}

final function string GrabCommand( out string S )
{
	local int i;
	local string R;
	
	i = InStr(S," ");
	if( i==-1 )
	{
		R = S;
		S = "";
	}
	else
	{
		R = Left(S,i);
		S = Mid(S,i+1);
	}
	return Caps(R);
}
/*function Mutate(string MutateString, PlayerController Sender)
{
	if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);

	if( (Level.NetMode==NM_StandAlone || Sender.PlayerReplicationInfo.bAdmin || Sender.PlayerReplicationInfo.bSilentAdmin) && Left(MutateString,4)~="SLOT" )
	{
		MutateString = Mid(MutateString,5);
		switch( GrabCommand(MutateString) )
		{
		case "HELP":
			Sender.ClientMessage("Commands for Slot Machines: Mutate SLOT <cmd>");
			Sender.ClientMessage("LIST - Show a list of all server cards and their desirability.");
			Sender.ClientMessage("USE <Num> - Use a card number on yourself (use LIST to get num values).");
			Sender.ClientMessage("REMOVE <Name> - Remove a card from server (will take effect upon mapchange).");
			Sender.ClientMessage("ADD <Name> - Add a card to the server (will take effect upon mapchange).");
			break;
		case "LIST":
			ListCards(Sender);
			break;
		case "USE":
			UseCard(int(MutateString),Sender);
			break;
		case "REMOVE":
			RemoveCard(Sender,MutateString);
			break;
		case "ADD":
			AddCard(Sender,MutateString);
			break;
		default:
			Sender.ClientMessage("Unknown slot machines command, for a list of commands use: Mutate SLOT HELP");
		}
		return;
	}
}*/

final function ListCards( PlayerController P )
{
	local float W;
	local int i;

	for( i=0; i<LoadedCards.Length; ++i )
		W+=LoadedCards[i].Default.Desireability;
	for( i=0; i<LoadedCards.Length; ++i )
		P.ClientMessage("Card["$i$"] '"$LoadedCards[i].Name$"' desire: "$LoadedCards[i].Default.Desireability$" chance: "$(LoadedCards[i].Default.Desireability/W*100.f)$" %");
}
final function UseCard( int i, PlayerController P )
{
	if( P.Pawn==None )
		P.ClientMessage("You need to be active in-game to use cards.");
	else if( i<0 || i>=LoadedCards.Length )
		P.ClientMessage("Invalid card range ("$i$"/"$(LoadedCards.Length-1)$")");
	else
	{
		P.ClientMessage("Activated card: "$LoadedCards[i].Name);
		LoadedCards[i].Static.ExecuteCard(P.Pawn);
	}
}
final function RemoveCard( PlayerController P, string S )
{
	local int i,j,z;

	if( S=="" )
		return;
	j = -1;
	z = -1;
	S = Caps(S);
	for( i=0; i<CardClasses.Length; ++i )
	{
		if( CardClasses[i]~=S )
			j = i;
		else if( InStr(Caps(CardClasses[i]),S)>=0 )
			z = i;
	}
	if( j==-1 )
		j = z;
	if( j==-1 )
		P.ClientMessage("Couldn't find card to remove: "$S);
	else
	{
		P.ClientMessage("Removed card: "$CardClasses[j]);
		CardClasses.Remove(j,1);
		SaveConfig();
	}
}
final function AddCard( PlayerController P, string S )
{
	local int i;
	local class<SlotCard> C;

	if( S=="" )
		return;
	C = Class<SlotCard>(DynamicLoadObject(S,Class'Class'));
	if( C==None )
	{
		P.ClientMessage("Couldn't add card because it failed to load: "$S);
		return;
	}
	S = string(C);
	for( i=0; i<CardClasses.Length; ++i )
	{
		if( CardClasses[i]~=S )
		{
			P.ClientMessage("Couldn't add card because it's already in the list: "$S);
			return;
		}
	}
	P.ClientMessage("Added card: "$S);
	CardClasses[CardClasses.Length] = S;
	SaveConfig();
}

defaultproperties
{
	bAddToServerPackages=true
	FriendlyName="Slot Machines"
	Description="Give players random rewards for kills."
	GroupName="KF-Slots"
	VersionNumber=200

	AlwaysWinChance=20
	bAllowBotCards=true
	CardClasses(0)="MutSlotMachineSR.CashCard"
	CardClasses(1)="MutSlotMachineSR.ToxicCard"
	CardClasses(2)="MutSlotMachineSR.HeartBreakCard"
	CardClasses(3)="MutSlotMachineSR.AmmoCard"
	CardClasses(4)="MutSlotMachineSR.ArmorCard"
	CardClasses(5)="MutSlotMachineSR.GrenadeCard"
	CardClasses(6)="MutSlotMachineSR.GodModeCard"
	CardClasses(7)="MutSlotMachineSR.StarmanCard"
	CardClasses(8)="MutSlotMachineSR.InstaDeathCard"
	CardClasses(9)="MutSlotMachineSR.ZedDeathCard"
	CardClasses(10)="MutSlotMachineSR.PipeSelfDestCard"
	CardClasses(11)="MutSlotMachineSR.PipeSelfDestBCard"
	CardClasses(12)="MutSlotMachineSR.FleshPoundCard"
	CardClasses(13)="MutSlotMachineSR.ClotCard"
	CardClasses(14)="MutSlotMachineSR.SirenCard"
	CardClasses(15)="MutSlotMachineSR.BloatCard"
	CardClasses(16)="MutSlotMachineSR.CashShareCard"
	CardClasses(17)="MutSlotMachineSR.AdrenalineCard"
	CardClasses(18)="MutSlotMachineSR.DrunkCard"
	CardClasses(19)="MutSlotMachineSR.TeamFatalityCard"
	CardClasses(20)="MutSlotMachineSR.CashJackpotCard"
	CardClasses(21)="MutSlotMachineSR.PatriarchCard"
	CardClasses(22)="MutSlotMachineSR.HolyGrenadeCard"
	CardClasses(23)="MutSlotMachineSR.MaskCard"
	CardClasses(24)="MutSlotMachineSR.NoDoshCard"
	CardClasses(25)="MutSlotMachineSR.SantaHatCard"
	CardClasses(26)="MutSlotMachineSR.HeadSizeCard"
	CardClasses(27)="MutSlotMachineSR.TeamNoAmmoCard"
	CardClasses(28)="MutSlotMachineSR.GeoViewCard"
	CardClasses(29)="MutSlotMachineSR.AssistCard"
	CardClasses(30)="MutSlotMachineSR.FleshPoundKF2Card"
	CardClasses(31)="MutSlotMachineSR.EndyCard"
	CardClasses(32)="MutSlotMachineSR.BruteCard"
	CardClasses(33)="MutSlotMachineSR.MFPCard"
	CardClasses(34)="MutSlotMachineSR.ChimeraCard"
	PerSlotPauseTime=0
	AfterRoundPauseTime=4
	NewSlotKills=4
}