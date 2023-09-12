
using Gtk;
using Gee;
// using Gst;

static ConfigFile config;
static ArrayList<Camera> cameras;
static ArrayList<Renderer> renderers;
static App app;
static MainWindow main_window;
static SysTray systray;

extern const string GETTEXT_PACKAGE;
extern const string DATA_DIR;

const string APP_ID = "app.junker.CCTVWatcher";

class App : Gtk.Application
{
	protected override void activate ()
	{
		config = new ConfigFile();

		cameras   = new ArrayList<Camera>();
		renderers = new ArrayList<Renderer>();

		main_window = new MainWindow(this);

		if (config.load())
		{
			main_window.maximize();
			main_window.refresh_cameras();

			if (config.systray)
				main_window.stop_renderers();
			else
				main_window.show();
		}

		systray = new SysTray();

		Bus.own_name(BusType.SESSION, APP_ID, BusNameOwnerFlags.ALLOW_REPLACEMENT, on_dbus_aquired);

		Gtk.main();
	}

	public void destroy()
	{
		main_window.stop_renderers();

		this.quit();
		Gtk.main_quit();
	}

	public void show()
	{
		main_window.play_renderers();

		main_window.show();
		main_window.present();
	}

	public void hide()
	{
		if (config.minimize_pause)
		{
			main_window.stop_renderers();
		}

		main_window.hide();
	}

	private void on_dbus_aquired(DBusConnection conn) {
		try {
			conn.register_object("/app/junker/CCTVWatcher", new DbusServer());
		} catch (IOError e) {
			stderr.printf("Could not register DBUS service\n");
		}
	}

	public App()
	{
		Object(application_id: APP_ID);
	}
}

static int main (string[] args)
{
	Gst.init (ref args);

	app = new App();

	return app.run(args);
}