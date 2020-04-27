
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

		Gtk.main();
	}

	public void destroy()
	{
		main_window.stop_renderers();

		this.quit();
		Gtk.main_quit();
	}

	public App()
	{
		Object(application_id: "app.junker.cctv-watcher");
	}
}

static int main (string[] args) 
{
	Gst.init (ref args);

	app = new App();

	return app.run(args);
}