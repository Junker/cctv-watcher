
using Gtk;
using Gee;
// using Gst;

static ConfigFile config;
static ArrayList<Camera> cameras;
static ArrayList<Renderer> renderers;
static App app;
static MainWindow main_window;

extern const string GETTEXT_PACKAGE;


class App : Gtk.Application
{
	protected override void activate ()
	{
		config = new ConfigFile();

		cameras   = new ArrayList<Camera>();
		renderers = new ArrayList<Renderer>();

		main_window = new MainWindow(this);
		main_window.show();

		if (config.load())
		{
			main_window.refresh_cameras();
		}

		Gtk.main();
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