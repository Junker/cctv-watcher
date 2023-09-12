[DBus (name = "app.junker.CCTVWatcher")]
public class DbusServer : Object
{
	public void show() throws GLib.Error
	{
		app.show();
	}

	public void hide() throws GLib.Error
	{
		app.hide();
	}
}