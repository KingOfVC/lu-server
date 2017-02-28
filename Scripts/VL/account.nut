Account <- array( GetMaxPlayers(), null );

class Accounts
{
	Logged = false;
	Level = 0;
	Password = null;
	UID = null;
	
	function LoadAccount( player )
	{
		local q = ::sqlite_query( ::IsDB, "SELECT * FROM account WHERE NameLower = '" + player.Name.tolower() + "' " );
		if( ::sqlite_column_data( q, 1 ) )
		{
			this.Password = ::sqlite_column_data( q, 4 );
			this.UID = ::sqlite_column_data( q, 3 );
			
			if( this.UID == player.LUID )
			{
				this.Level = ::sqlite_column_data( q, 5 ).tointeger();
				this.Logged = true;
				playa[ player.ID ].LoadInfo( player );
				Msg.Sucess( "You has been auto logged. Admin level [#ffffff]" + Server.GetLevel( this.Level ) + ".", player );
				Msg.All( player.ColouredName + " [#ffff00]has been auto logged as [#ffffff]" + Server.GetLevel( this.Level ) + ".", player  );
				::EchoMessage( "5** " + player.Name + " has been auto logged as " + Server.GetLevel( this.Level ) + "." );
			}
			
			else
			{
				this.Level = 1;
				Msg.Warn( "You are not logged, please use /login to login into your account.", player );
			}
		}
		
		else
		{
			Msg.Warn( "You are not registered. Please register your account with /register .", player );
		}
		::sqlite_free( q );
	}
	
	function RegisterAccount( player, password )
	{
		::sqlite_query( ::IsDB, "INSERT INTO account VALUES ( '" + player.Name + "', '" + player.Name.tolower() + "', '" + player.IP + "', '" + player.LUID + "', '" + ::SHA256( password ) + "', '1', '" + ::time() + "', '" + ::time() + "' ) " );
		::sqlite_query( ::IsDB, "INSERT INTO account VALUES ( '" + player.Name + "', '" + player.Name.tolower() + "', '0', '0', '0', '0', 'false', 'null', 'null' )" );
		this.Level = 1;
		this.Logged = true;
		Msg.Sucess( "You sucessfully registered.", player );
		Msg.All( player.ColouredName + " [#ffff00]has been registered sucessfully.", player );
		::EchoMessage( "5** " + player.Name + " has been registered sucessfully.");
	}
	
	function LoginAccount( player )
	{
		local q = ::sqlite_query( ::IsDB, "SELECT * FROM account WHERE NameLower = '" + player.Name.tolower() + "' " );
		this.Level = ::sqlite_column_data( q, 5 ).tointeger();
		::sqlite_free( q );
		this.Logged = true;
		playa[ player.ID ].LoadInfo( player );
		Msg.Sucess( "You has been auto logged. Admin level [#ffffff]" + Server.GetLevel( this.Level ) + ".", player );
		Msg.All( player.ColouredName + " [#ffff00]has been logged as [#ffffff]" + Server.GetLevel( this.Level ) + ".", player );
		::EchoMessage( "5** " + player.Name + " has been logged as " + Server.GetLevel( this.Level ) + "." );
	}
	
	function SaveAccount( player )
	{
		if( this.Logged == true )
		{
			::sqlite_query( ::IsDB, "UPDATE account Level = '" + this.Level + "', Password = '" + this.Password + "' WHERE NameLower = '" + player.Name.tolower() + "'" );
			playa[ player.ID ].SaveData( player );
		}
	}
	
	function onCommand( player ,cmd, text )
	{
		switch( cmd.tolower() )
		{
		
			case "register":
			if( this.Logged == true ) Msg.Warn( "You already registered.", player );
			else if( this.Level != 0 ) Msg.Warn( "You already registered.", player );
			else if( !text ) Msg.Warn( "Syntax, /register [password]", player );
			else
			{
				this.RegisterAccount( player, text );
			}
			break;
			
			case "login":
			if( this.Logged == true ) Msg.Warn( "You already logged..", player );
			else if( this.Level == 0 ) Msg.Warn( "You are not registered.", player );
			else if( !text ) Msg.Warn( "Syntax, /login [password]", player );
			else if( this.Password != ::SHA256( text ) ) Msg.Warn( "Invalid password.", player );
			else
			{
				this.LoginAccount( player );
			}
			break;
			
			case "changepass":
			if( this.Logged == false ) Msg.Warn( "You are not logged.", player );
			else if( this.Level == 0 ) Msg.Warn( "You are not registered.", player );
			else if( !text ) Msg.Warn( "Syntax, /changepass [old password] [new password]", player );
			else
			{
				local old = ::GetTok ( text, " ", 1 ), new = ::GetTok ( text, " ", 2 );
				if( !old | !new ) Msg.Warn( "Syntax, /changepass [old password] [new password]", player );
				else if( this.Password != ::SHA256( text ) ) Msg.Warn( "Invalid old password.", player );
				else
				{
					this.Password = ::SHA256( text );
					Msg.Sucess( "Sucessfully changed your password.", player );
				}
			}
			break;

		}
	}
}

function IsLogged( player )
{
	return account[ player.ID ].Logged;
}

function IsRegistered( player )
{
	if( account[ player.ID ].Level == 0 ) return false;
	else return true;
}
