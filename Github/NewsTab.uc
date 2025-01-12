class NewsTab extends MidGamePanel;
var bool bClean;
var automated GUISectionBackground i_BGSec;
var automated GUIScrollTextBox lb_Text;
var() config array<string> NewsLine;
var(ServerNews) localized string DefaultText;
var bool bReceivedRules;
var automated GUISectionBackground	i_BGPerks;
var	automated SRStatListBox	lb_PerkSelect;
var automated   GUIButton			   b_Team, b_Settings, b_Browser, b_Quit, b_Favs,
										b_Leave, b_MapVote, b_KickVote, b_MatchSetup, b_Spec, b_Profile;
var() noexport  bool					bTeamGame, bFFAGame, bNetGame;
var localized   string				  LeaveMPButtonText, LeaveSPButtonText, SpectateButtonText, JoinGameButtonText;
var localized   array<string>		   ContextItems, DefaultItems;
var localized   string				  KickPlayer, BanPlayer;
var localized   string				  BuddyText;
var localized   string				  RedTeam, BlueTeam;
var			 string				  PlayerStyleName;
var			 GUIStyles			   PlayerStyle;
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;
	local int n;
	local string s;
	local eFontScale FS;
	Super.InitComponent(MyController, MyOwner);
	s = GetSizingCaption();
	for ( i = 0; i < Controls.Length; i++ )
	{
		if ( GUIButton(Controls[i]) != None && Controls[i] != b_Team )
		{
			GUIButton(Controls[i]).bAutoSize = true;
			GUIButton(Controls[i]).SizingCaption = s;
			GUIButton(Controls[i]).AutoSizePadding.HorzPerc = 0.04;
			GUIButton(Controls[i]).AutoSizePadding.VertPerc = 0.5;
		}
	}
	PlayerStyle = MyController.GetStyle(PlayerStyleName, fs);
       bClean = true;
       lb_Text.SetContent(DefaultText);
    lb_Text.OnDraw = OnLabelDraw;
	n = NewsLine.Length;
       for(i=0; i<n; i++)
       {
         lb_Text.AddText(NewsLine[i]);
       }
       lb_Text.AddText(" ");
       lb_Text.MyScrollBar.GripPos = 0;
       lb_Text.MyScrollBar.CurPos = 0;
       lb_Text.MyScrollBar.MyList.SetTopItem(0);
       lb_Text.MyScrollBar.AlignThumb();
       OnShow = Shown;
}
function bool OnLabelDraw(Canvas c)
{
    C.Style = 1;
    C.Font = class'ROHUD'.Static.GetSmallMenuFont(C);
    return false;
}
function Shown()
{
    lb_Text.MyScrollBar.GripPos = 0;
    lb_Text.MyScrollBar.CurPos = 0;
	lb_Text.MyScrollBar.MyList.SetTopItem(0);
	lb_Text.MyScrollBar.AlignThumb();
}
function string GetSizingCaption()
{
	local int i;
	local string s;
	for ( i = 0; i < Controls.Length; i++ )
	{
		if ( GUIButton(Controls[i]) != none && Controls[i] != b_Team )
		{
			if ( s == "" || Len(GUIButton(Controls[i]).Caption) > Len(s) )
			{
				s = GUIButton(Controls[i]).Caption;
			}
		}
	}
	return s;
}
function GameReplicationInfo GetGRI()
{
	return PlayerOwner().GameReplicationInfo;
}
function InitGRI()
{
	local PlayerController PC;
	local GameReplicationInfo GRI;
	GRI = GetGRI();
	PC = PlayerOwner();
	if ( PC == none || PC.PlayerReplicationInfo == none || GRI == none )
	{
		return;
	}
	bInit = False;
	if ( !bTeamGame && !bFFAGame )
	{
		if ( GRI.bTeamGame )
		{
			bTeamGame = True;
		}
		else if ( !(GRI.Gameclass ~= "Engine.GameInfo") )
		{
			bFFAGame = True;
		}
	}
	bNetGame = PC.Level.NetMode != NM_StandAlone;
	if ( bNetGame )
	{
		b_Leave.Caption = LeaveMPButtonText;
	}
	else
	{
		b_Leave.Caption = LeaveSPButtonText;
	}
	if ( PC.PlayerReplicationInfo.bOnlySpectator )
	{
		b_Spec.Caption = JoinGameButtonText;
	}
	else
	{
		b_Spec.Caption = SpectateButtonText;
	}
	SetupGroups();
}

function float ItemHeight(Canvas C)
{
	local float XL, YL, H;
	local eFontScale f;
	if ( bTeamGame )
	{
		f=FNS_Medium;
	}
	else
	{
		f=FNS_Large;
	}
	PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", XL, H, F);
	if ( C.ClipX > 640 && bNetGame )
	{
		PlayerStyle.TextSize(C, MSAT_Blurry, "Wqz, ", XL, YL, FNS_Small);
	}
	H += YL;
	H += (H * 0.2);
	return h;
}

function SetupGroups()
{
	local int i;
	local PlayerController PC;
	PC = PlayerOwner();
	if ( bTeamGame )
	{
		if ( PC.GameReplicationInfo != None && PC.GameReplicationInfo.bNoTeamChanges )
		{
			RemoveComponent(b_Team,true);
		}
	}
	else if ( bFFAGame )
	{
		RemoveComponent(b_Team, true);
	}
	else
	{
		for ( i = 0; i < Controls.Length; i++ )
		{
			if ( Controls[i] != i_BGPerks && Controls[i] != lb_PerkSelect )
			{
				RemoveComponent(Controls[i], True);
			}
		}
	}
	if ( PC.Level.NetMode != NM_Client )
	{
		RemoveComponent(b_Favs);
		RemoveComponent(b_Browser);
	}
	else if ( CurrentServerIsInFavorites() )
	{
		DisableComponent(b_Favs);
	}
	if ( PC.Level.NetMode == NM_StandAlone )
	{
		RemoveComponent(b_MapVote, True);
		RemoveComponent(b_MatchSetup, True);
		RemoveComponent(b_KickVote, True);
	}
	else if ( PC.VoteReplicationInfo != None )
	{
		if ( !PC.VoteReplicationInfo.MapVoteEnabled() )
		{
			RemoveComponent(b_MapVote,True);
		}
		if ( !PC.VoteReplicationInfo.KickVoteEnabled() )
		{
			RemoveComponent(b_KickVote);
		}
		if ( !PC.VoteReplicationInfo.MatchSetupEnabled() )
		{
			RemoveComponent(b_MatchSetup);
		}
	}
	else
	{
		RemoveComponent(b_MapVote);
		RemoveComponent(b_KickVote);
		RemoveComponent(b_MatchSetup);
	}
	RemapComponents();
}

function SetButtonPositions(Canvas C)
{
	local int i, j, ButtonsPerRow, ButtonsLeftInRow, NumButtons;
	local float Width, Height, Center, X, Y, YL, ButtonSpacing;
	Width = b_Settings.ActualWidth();
	Height = b_Settings.ActualHeight();
	Center = ActualLeft() + (ActualWidth() / 2.0);
	ButtonSpacing = Width * 0.05;
	YL = Height * 1.2;
	Y = b_Settings.ActualTop();
	ButtonsPerRow = ActualWidth() / (Width + ButtonSpacing);
	ButtonsLeftInRow = ButtonsPerRow;
	for ( i = 0; i < Components.Length; i++)
	{
		if ( Components[i].bVisible && GUIButton(Components[i]) != none && Components[i] != b_Team )
		{
			NumButtons++;
		}
	}
	if ( NumButtons < ButtonsPerRow )
	{
		X = Center - (((Width * float(NumButtons)) + (ButtonSpacing * float(NumButtons - 1))) * 0.5);
	}
	else if ( ButtonsPerRow > 1 )
	{
		X = Center - (((Width * float(ButtonsPerRow)) + (ButtonSpacing * float(ButtonsPerRow - 1))) * 0.5);
	}
	else
	{
		X = Center - Width / 2.0;
	}
	for ( i = 0; i < Components.Length; i++)
	{
		if ( !Components[i].bVisible || GUIButton(Components[i]) == none || Components[i]==b_Team )
		{
			continue;
		}
		Components[i].SetPosition( X, Y, Width, Height, true );
		if ( --ButtonsLeftInRow > 0 )
		{
			X += Width + ButtonSpacing;
		}
		else
		{
			Y += YL;
			for ( j = i + 1; j < Components.Length && ButtonsLeftInRow < ButtonsPerRow; j++)
			{
				if ( Components[i].bVisible && GUIButton(Components[i]) != none && Components[i] != b_Team )
				{
					ButtonsLeftInRow++;
				}
			}
			if ( ButtonsLeftInRow > 1 )
			{
				X = Center - (((Width * float(ButtonsLeftInRow)) + (ButtonSpacing * float(ButtonsLeftInRow - 1))) * 0.5);
			}
			else
			{
				X = Center - Width / 2.0;
			}
		}
	}
}
function bool CurrentServerIsInFavorites()
{
	local ExtendedConsole.ServerFavorite Fav;
	local string address,portString;
	if ( PlayerOwner() == None )
	{
		return true;
	}
	address = PlayerOwner().GetServerNetworkAddress();
	if( address == "" )
	{
		return true;
	}
	if ( Divide(address, ":", Fav.IP, portstring) )
	{
		Fav.Port = int(portString);
	}
	else
	{
		Fav.IP = address;
	}
	return class'KFConsole'.static.InFavorites(Fav);
}
function bool ButtonClicked(GUIComponent Sender)
{
	local PlayerController PC;
	local GUIController C;
	C = Controller;
	PC = PlayerOwner();
	if ( Sender == b_Settings )
	{
		Controller.OpenMenu(Controller.GetSettingsPage());
	}
	else if ( Sender == b_Browser )
	{
		Controller.OpenMenu("KFGUI.KFServerBrowser");
	}
	else if ( Sender == b_Leave )
	{
		PC.ConsoleCommand("DISCONNECT");
		KFGUIController(C).ReturnToMainMenu();
	}
	else if ( Sender == b_Favs )
	{
		PC.ConsoleCommand( "ADDCURRENTTOFAVORITES" );
		b_Favs.MenuStateChange(MSAT_Disabled);
	}
	else if ( Sender == b_Quit )
	{
		Controller.OpenMenu(Controller.GetQuitPage());
	}
	else if ( Sender == b_MapVote )
	{
		Controller.OpenMenu(Controller.MapVotingMenu);
	}
	else if ( Sender == b_KickVote )
	{
		Controller.OpenMenu(Controller.KickVotingMenu);
	}
	else if ( Sender == b_MatchSetup )
	{
		Controller.OpenMenu(Controller.MatchSetupMenu);
	}
	else if ( Sender == b_Spec )
	{
		Controller.CloseMenu();
		if ( PC.PlayerReplicationInfo.bOnlySpectator )
		{
			PC.BecomeActivePlayer();
		}
		else
		{
			PC.BecomeSpectator();
		}
	}
	else if( Sender==b_Profile )
	{
		Controller.OpenMenu(string(class'SRProfilePage'));
	}
	return true;
}

function bool InternalOnPreDraw(Canvas C)
{
	local GameReplicationInfo GRI;
	GRI = GetGRI();
	if ( GRI != none )
	{
		if ( bInit )
		{
			InitGRI();
		}
		SetButtonPositions(C);
		if ( (PlayerOwner().myHUD == None || !PlayerOwner().myHUD.IsInCinematic()) && GRI != none && GRI.bMatchHasBegun && !PlayerOwner().IsInState('GameEnded') )
		{
			EnableComponent(b_Spec);
		}
		else
		{
			DisableComponent(b_Spec);
		}
	}
	return false;
}

function bool ContextMenuOpened(GUIContextMenu Menu)
{
	local GUIList List;
	local PlayerReplicationInfo PRI;
	local byte Restriction;
	local GameReplicationInfo GRI;
	GRI = GetGRI();
	if ( GRI == None )
	{
		return false;
	}
	List = GUIList(Controller.ActiveControl);
	if ( List == None )
	{
		log(Name @ "ContextMenuOpened active control was not a list - active:" $ Controller.ActiveControl.Name);
		return False;
	}
	if ( !List.IsValid() )
	{
		return False;
	}
	PRI = GRI.FindPlayerByID(int(List.GetExtra()));
	if ( PRI == None || PRI.bBot || PlayerIDIsMine(PRI.PlayerID) )
	{
		return False;
	}
	Restriction = PlayerOwner().ChatManager.GetPlayerRestriction(PRI.PlayerID);
	if ( bool(Restriction & 1) )
	{
		Menu.ContextItems[0] = ContextItems[0];
	}
	else
	{
		Menu.ContextItems[0] = DefaultItems[0];
	}
	if ( bool(Restriction & 2) )
	{
		Menu.ContextItems[1] = ContextItems[1];
	}
	else
	{
		Menu.ContextItems[1] = DefaultItems[1];
	}
	if ( bool(Restriction & 4) )
	{
		Menu.ContextItems[2] = ContextItems[2];
	}
	else
	{
		Menu.ContextItems[2] = DefaultItems[2];
	}
	if ( bool(Restriction & 8) )
	{
		Menu.ContextItems[3] = ContextItems[3];
	}
	else
	{
		Menu.ContextItems[3] = DefaultItems[3];
	}
	Menu.ContextItems[4] = "-";
	Menu.ContextItems[5] = BuddyText;
	if ( PlayerOwner().PlayerReplicationInfo.bAdmin )
	{
		Menu.ContextItems[6] = "-";
		Menu.ContextItems[7] = KickPlayer $ "["$List.Get() $ "]";
		Menu.ContextItems[8] = BanPlayer $ "["$List.Get() $ "]";
	}
	else if ( Menu.ContextItems.Length > 6 )
	{
		Menu.ContextItems.Remove(6,Menu.ContextItems.Length - 6);
	}
	return True;
}
function ContextClick(GUIContextMenu Menu, int ClickIndex)
{
	local bool bUndo;
	local byte Type;
	local GUIList List;
	local PlayerController PC;
	local PlayerReplicationInfo PRI;
	local GameReplicationInfo GRI;
	GRI = GetGRI();
	if ( GRI == None )
	{
		return;
	}
	PC = PlayerOwner();
	bUndo = Menu.ContextItems[ClickIndex] == ContextItems[ClickIndex];
	List = GUIList(Controller.ActiveControl);
	if ( List == None )
	{
		return;
	}
	PRI = GRI.FindPlayerById(int(List.GetExtra()));
	if ( PRI == None )
	{
		return;
	}
	if ( ClickIndex > 5 )
	{
		switch ( ClickIndex )
		{
			case 6:
			case 7: PC.AdminCommand("admin kick"@List.GetExtra()); break;
			case 8: PC.AdminCommand("admin kickban"@List.GetExtra()); break;
		}
		return;
	}
	if ( ClickIndex > 3 )
	{
		Controller.AddBuddy(List.Get());
		return;
	}
	Type = 1 << ClickIndex;
	if ( bUndo )
	{
		if ( PC.ChatManager.ClearRestrictionID(PRI.PlayerID, Type) )
		{
			PC.ServerChatRestriction(PRI.PlayerID, PC.ChatManager.GetPlayerRestriction(PRI.PlayerID));
			ModifiedChatRestriction(Self, PRI.PlayerID);
		}
	}
	else
	{
		if ( PC.ChatManager.AddRestrictionID(PRI.PlayerID, Type) )
		{
			PC.ServerChatRestriction(PRI.PlayerID, PC.ChatManager.GetPlayerRestriction(PRI.PlayerID));
			ModifiedChatRestriction(Self, PRI.PlayerID);
		}
	}
}
defaultproperties
{
     Begin Object class=GUISectionBackground Name=BGSec
         Caption="Новичку"
         WinTop=0.018000
         WinLeft=0.019240
         WinWidth=0.961520
         WinHeight=0.798982
         bFillClient=True
         OnPreDraw=BGSec.InternalPreDraw
     End Object
     i_BGSec=GUISectionBackground'NewsTab.BGSec'
     Begin Object class=GUIScrollTextBox Name=InfoText
         CharDelay=0.002500
         EOLDelay=0.000000
         WinTop=0.082000
         WinLeft=0.052000
         WinWidth=0.945000
         WinHeight=0.720000
         bNoTeletype=True
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
         OnCreateComponent=InfoText.InternalOnCreateComponent
     End Object
     lb_Text=GUIScrollTextBox'NewsTab.InfoText'
	NewsLine(0) = "ПАМЯТКА НОВИЧКУ:"
	NewsLine(1) = "=================================="
	NewsLine(2) = "1. НЕ ЛЕЗЬ ПОД ПРИЦЕЛ, НЕ ХОДИ ПО МИНАМ"
	NewsLine(3) = "Если ты по своей неосторожности попал под дружественный огонь -"
	NewsLine(4) = "виноват только ты сам."
    NewsLine(5) = "2. ЛЕЧИ СВОИХ"
    NewsLine(6) = "За лечение дают деньги, и оно быстрее восстанавливается если лечишь товарища."
    NewsLine(7) = "Полечи товарища, полечат и тебя. Зарабатывай хорошую репутацию на сервере."
	NewsLine(8) = "3. НЕ СТРЕЛЯЙ ПО КРУПНЫМ МОБАМ"
	NewsLine(9) = "Крупных мобов можно убить, имея хоть какойто игровой опыт. Оставляй их на"
	NewsLine(10)= "более опытных игроков. Постояльцы сервера научат как вести себя с"
	NewsLine(11)= "крупным противником. Не бойся задавать вопросы."
	NewsLine(12)= "4. ВЫПОЛНЯЙ РОЛЬ В КОМАНДЕ, КОТОРАЯ ОПРЕДЕЛЕНА ТВОИМ ПЕРКОМ"
	NewsLine(13)= "=================================="
	NewsLine(14)= "БЕРСЕРКЕР"
	NewsLine(15)= "-"
	NewsLine(16)= "Твоя задача в команде - убивать тех кто близко подошел. Двигайся осторожно - "
	NewsLine(17)= "ты действуешь в ближнем бою и можешь попасть под огонь союзников. Если видишь "
	NewsLine(18)= "Scrake - бери топор и обходи его со спины, бей альтернативной атакой до его смерти."
	NewsLine(19)= "Если рядом с ним много монстров, или он всегда поворачивается к тебе - не нападай."
	NewsLine(20)= "Берсеркер - трудный перк для новичка - спрашивай совета у опытных товарищей."
	NewsLine(21)= "=================================="
	NewsLine(22)= "КОММАНДОС"
	NewsLine(23)= "-"
	NewsLine(24)= "Твоя задача - убивать слабых и средних монстров, а также Shiver. Зеленые полоски"
	NewsLine(25)= "над головами монстров - их здоровье. Сообщай команде о состоянии здоровья сильных"
	NewsLine(26)= "монстров. Убивай невидимок - ты обнаруживаешь их, и наносишь дополнительный ущерб."
	NewsLine(27)= "Для поднятия уровня нужно убивать невидимок."
	NewsLine(28)= "=================================="
	NewsLine(29)= "ПОДРЫВНИК"
	NewsLine(30)= "-"
	NewsLine(31)= "Твои цели - скопления слабых монстров. Если купишь кольт Python, стреляй"
	NewsLine(32)= "по Husk, Siren, Demolisher, Reaver. Твой перк может помочь в уничтожении"
	NewsLine(33)= "сильных мутантов, но для этого нужно хорошее вооружение и опыт - спрашивай"
	NewsLine(34)= "совета у опытных игроков. Не стреляй рядом с собой - можешь взорваться."
	NewsLine(35)= "=================================="
	NewsLine(36)= "МЕДИК"
	NewsLine(37)= "-"
	NewsLine(38)= "Твоя основная задача - ЛЕЧИТЬ. Не кидайся на мобов. Не проси денег."
	NewsLine(39)= "Просто стой сзади и лечи. Медик может не только лечить, но для остального"
	NewsLine(40)= "нужен более высокий уровень и опыт, поэтому - ЛЕЧИ и набирай уровень, спрашивай"
	NewsLine(41)= "подсказки у опытных товарищей. Вместо гранат ты кидаешь аптечки. Используй это."
	NewsLine(42)= "=================================="
	NewsLine(43)= "ОГНЕМЕТЧИК"
	NewsLine(44)= "-"
	NewsLine(45)= "Твои задача - сжигать слабых мутантов в огне преисподней. Ни в коем случае"
	NewsLine(46)= "даже не поворачивай свое оружие против сильных монстров. Убивай Siren и всех"
	NewsLine(47)= "кто слабее ее. Когда видишь Brute - поджигай его, это единственный сильный"
	NewsLine(48)= "монстр, которого ты должен помогать убивать команде. Не пытайся поджечь Husk"
	NewsLine(49)= " - он уже обгорел, и получает слабый ущерб от огня. Высади ему очередь MAC10 в голову."
	NewsLine(50)= "=================================="
	NewsLine(51)= "ДЖАГГЕРНАУТ"
	NewsLine(52)= "-"
	NewsLine(53)= "Твои задача - поддерживать команду! Убивай слабых и средних мутантов, раздавай"
	NewsLine(54)= "патроны тем кто просит. Заваривай броню команде. Если видишь что у товарища"
	NewsLine(55)= "закончились патроны а он молчит - дай ему патроны без разговоров!"
	NewsLine(56)= "Патроны раздаются вместо бросания гранат. Это не все что умеет джаггернаут."
	NewsLine(57)= "Поднимай уровень и узнавай тонкости игры от опытных товарищей."
	NewsLine(58)= "=================================="
	NewsLine(59)= "ДИВЕРСАНТ"
	NewsLine(60)= "-"
	NewsLine(61)= "Твое оружие не обладает большой огневой мощью, но очень скорострельно. Трать"
	NewsLine(62)= "патроны с осторожностью. Твои гранаты оглушают мутантов - спасай окруженных"
	NewsLine(63)= "товарищей - граната не нанесет им вреда. Если увидел разьяренного монстра с"
	NewsLine(64)= "красной лампочкой на груди - кидай гранату - ее дым снимет с него состояние"
	NewsLine(65)= "бешенства. Потенциал твоего перка раскрывается с уровнем и опытом. Не брезгуй"
	NewsLine(66)= "спрашивать совета у более опытных игроков."
	NewsLine(67)= "=================================="
	NewsLine(68)= "СНАЙПЕР"
	NewsLine(69)= "-"
	NewsLine(70)= "Целься в ГОЛОВУ! Только в голову ты наносишь серьезный ущерб мутантам."
	NewsLine(71)= "Когда мало денег - покупай винтовку: она достаточно мощная и дешевая."
	NewsLine(72)= "Твои основные цели - Siren, Husk, Demolisher. Снайпер может убивать и"
	NewsLine(73)= "более крупных мобов, но нужно дорогое оружие, и желателен уровень."
	NewsLine(74)= "Советуйся с опытными игроками."
	NewsLine(75)= "=================================="
	NewsLine(76)= "ПОДДЕРЖКА"
	NewsLine(77)= "-"
	NewsLine(78)= "Твое оружие это дробовики. Стреляй по собравшимся в ряд толпам - "
	NewsLine(79)= "эффект не заставит себя ждать. Подпускай врагов поближе, но не"
	NewsLine(80)= "давай себя окружить - чем ближе цель тем больше ущерб нанесенный"
	NewsLine(81)= "дробовиком. Но если они окружат тебя - низкая скорострельность не"
	NewsLine(82)= "даст тебе отстреляться. В любой удобный момент ПЕРЕЗАРЯЖАЙСЯ, у"
	NewsLine(83)= "дробовиков не быстрая перезарядка. Не лезь на крупных мобов, пока"
	NewsLine(84)= "не научишься с ними обращаться. Спрашивай совета у опытного товарища."
	NewsLine(85)= "=================================="
	PlayerStyleName="TextLabel"
	OnPreDraw=InternalOnPreDraw
	PropagateVisibility=False
	WinWidth=.5
	WinHeight=.75
	WinTop=0.125
	WinLeft=0.25
	LeaveMPButtonText="Отключиться"
	SpectateButtonText="Наблюдать"
	JoinGameButtonText="Войти"
	Begin Object class=GUIContextMenu name=PlayerListContextMenu
		OnSelect=ContextClick
		OnOpen=ContextMenuOpened
	End Object
	ContextMenu=PlayerListContextMenu
	KickPlayer="Kick "
	BanPlayer="Ban "
	Begin Object class=GUIButton Name=SettingsButton
		Caption="Настройки"
		StyleName="SquareButton"
		OnClick=ButtonClicked
  		WinWidth=0.147268
		WinHeight=0.048769
		WinLeft=0.194420
		WinTop=0.878657
		TabOrder=0
		bBoundToParent=true
		bScaleToParent=true
	End Object
	b_Settings=SettingsButton
	Begin Object class=GUIButton Name=BrowserButton
		Caption="Сервера"
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.05000
		WinLeft=0.375000
		WinTop=0.85000//0.675
		bAutoSize=True
		TabOrder=1
		bBoundToParent=true
		bScaleToParent=true
	End Object
	b_Browser=BrowserButton
	Begin Object class=GUIButton Name=LeaveMatchButton
		Caption=""
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.05000
		WinLeft=0.7250000
		WinTop=0.87//0.750
		bAutoSize=True
		TabOrder=10
		bBoundToParent=true
		bScaleToParent=true
	End Object
	b_Leave=LeaveMatchButton
	Begin Object class=GUIButton Name=FavoritesButton
		Caption="В избранное"
		Hint="Add this server to your Favorites"
		StyleName="SquareButton"
		WinWidth=0.20000
		WinHeight=0.05000
		WinLeft=0.02500
		WinTop=0.870
		bBoundToParent=true
		bScaleToParent=true
		OnClick=ButtonClicked
		bAutoSize=True
		TabOrder=3
	End Object
	b_Favs=FavoritesButton
	Begin Object class=GUIButton Name=QuitGameButton
		Caption="Выход"
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.05000
		WinLeft=0.725000
		WinTop=0.870
		bAutoSize=True
		TabOrder=11
	End Object
	b_Quit=QuitGameButton
	Begin Object class=GUIButton Name=MapVotingButton
		Caption="Карты"
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.050000
		WinLeft=0.025000
		WinTop=0.890
		bAutoSize=True
		TabOrder=5
	End Object
	b_MapVote=MapVotingButton
	Begin Object class=GUIButton Name=KickVotingButton
		Caption="Исключение"
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.050000
		WinLeft=0.375000
		WinTop=0.890
		bAutoSize=True
		TabOrder=6
	End Object
	b_KickVote=KickVotingButton
	Begin Object class=GUIButton Name=MatchSetupButton
		Caption="Match Setup"
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.050000
		WinLeft=0.725000
		WinTop=0.890
		bAutoSize=True
		TabOrder=7
	End Object
	b_MatchSetup=MatchSetupButton
	Begin Object class=GUIButton Name=SpectateButton
		Caption="Наблюдать"
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.050000
		WinLeft=0.725000
		WinTop=0.890
		bAutoSize=True
		TabOrder=9
	End Object
	b_Spec=SpectateButton
	Begin Object class=GUIButton Name=ProfileButton
		Caption="Профиль"
		StyleName="SquareButton"
		OnClick=ButtonClicked
		WinWidth=0.20000
		WinHeight=0.050000
		WinLeft=0.725000
		WinTop=0.890
		bAutoSize=True
		TabOrder=10
	End Object
	b_Profile=ProfileButton
}