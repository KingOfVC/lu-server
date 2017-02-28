/* 

	ViceLand LU Server
	
*/

Servers <-
{
	Name = "kiki's server",
	Gamemode = "yes",
	Password = "horny",
	Forum = "",
	MaxPlayers = 50,
	
	Players = [],




}


function onScriptLoad()
{
	print("\r[LOAD] Start loading script...");
	
	dofile( "Scripts/VL/server.nut", true );
	
	LoadModule( "lu_sqlite" );
	LoadModule( "lu_hashing2" );
	LoadModule( "sq_geoip" );

	LoadServerSetting();
}

function onPlayerJoin( player )
{
	Msg.All( player.ColouredName + " [#ffff00]joined the server from [#ffffff]" + Server.GetCountry( player.IP ) + ".", player );
	EchoMessage( "3** " + player.Name + " joined the server from " + Server.GetCountry( player.IP ) + "." );
	Discord_onPlayerConnect( player );

	Account[ player.ID ] = Accounts();
	playa[ player.ID ] = Playerr();
	playa[ player.ID ].onJoin( player );
	
	Servers.Players.push( player.ID );

}

function onPlayerPart( player, reason )
{
	if( Servers.Players.find( player.ID ) != null ) Servers.Players.remove( Servers.Players.find( player.ID ) );

	Account[ player.ID ].SaveAccount( player );
	
	Msg.All( "** " + player.ColouredName + " [#ffff00]left the server. [#ffffff](" + Server.GetPartReason( reason ) + ")", player );
	EchoMessage( "3** " + player.Name + " left the server. (" + Server.GetPartReason( reason ) + ")" );
	Discord_onPlayerPart( player, reason );
	
	Account[ player.ID ] = null;
	playa[ player.ID ] = null;

	
}

function onPlayerChat( player, text )
{
	EchoMessage( "13** " + player.Name + ": " + text );
	Discord_onPlayerChat( player, text );
}

function onPlayerSpawn( player, spawn )
{
	EchoMessage( player.Pos )
}
function onConsoleInput( cmd, text )
{
	if( cmd == "exe" )
	{
		if( !text ) print( "\r[EXE] Syntax, exe [code]" );
		else
		{
			try
			{
				local script = compilestring( text );
				if( script )
				{
					script();
					print( "\r[EXE] Done." );
				}
			}
			catch(e) print( "\r[EXE ERROR] " + e );
		}
	}
}

function onPlayerCommand( player, cmd, text )
{
	switch( cmd )
	{
		case "register":
		case "login":
		case "changepass":
		return Account[ player.ID ].onCommand( player, cmd, text );
		
		case "stats":
		case "wep":
		case "we":
		case "heal":
		case "disarm":
		case "goto":
		case "nogoto":
		return playa[ player.ID ].onCommand( player, cmd, text );
		
	}



}