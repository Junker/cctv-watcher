using Gtk;
using Gee;

[GtkTemplate (ui = "/app/junker/cctv-watcher/main-window.ui")]
public class MainWindow : ApplicationWindow
{
	[GtkChild] public Grid camera_grid;
	[GtkChild] public Alignment camera_view;
	[GtkChild] public ToolButton back_button;

	private RendererWidget empty_renderer_widget;

	public MainWindow (Gtk.Application application)
	{
		GLib.Object (application: application);
	}

	[GtkCallback]
	public bool on_delete_event(Gdk.Event event)
	{
		if (config.systray)
		{
			this.hide();

			foreach (Renderer renderer in renderers)
			{
				renderer.stop();
			}
		}
		else
			this.destroy();

		return true;
	}

	[GtkCallback]
	public void on_add_button_clicked(ToolButton button)

	{
		EditCameraDialog.add_camera();
	}

	[GtkCallback]
	public void on_refresh_button_clicked(ToolButton button)
	{
		refresh_cameras();
	}

	[GtkCallback]
	public void on_settings_button_clicked(ToolButton button)
	{
		var dialog = new SettingsDialog();
		dialog.run();
	}

	[GtkCallback]
	public void on_back_button_clicked()
	{
		back_button.hide();

		Widget widget = camera_view.get_children().data;

		camera_view.remove(widget);
		empty_renderer_widget.add(widget);

		camera_grid.show();
	}

	[GtkCallback]
	public bool on_window_state_event(Gdk.EventWindowState event)
	{
		if (config.systray && (event.new_window_state & Gdk.WindowState.ICONIFIED) != 0)
		{
//			this.hide();
		}

		return true;
	}


	[GtkCallback]
	public void on_destroy()
	{
		app.destroy();
	}

	public void refresh_cameras()
	{
		foreach (Renderer renderer in renderers)
		{
			renderer.pipeline.set_state(Gst.State.NULL);
		}
		renderers = new ArrayList<Renderer>();

		foreach(Widget widget in camera_grid.get_children())
		{
			camera_grid.remove(widget);
		}

		int camera_count = cameras.size;
		int per_row;

		if (camera_count == 1)
			per_row = 1;
		else if (camera_count >= 2 && camera_count <= 4) 
			per_row = 2;
		else if (camera_count > 4 && camera_count <= 9) 
			per_row = 3;
		else
			per_row = 4;

		int i = 0;
		foreach (Camera camera in cameras)
		{

			int row = 0;
			int col = 0;

			if (i > 0)
			{
				row = (int) Math.floor(i / per_row);
				col = i - (row * per_row);
			}

			Renderer renderer;

			if (camera is TestCamera)
				renderer = new TestRenderer(camera as TestCamera);
			else if (camera is V4lCamera)
				renderer = new V4lRenderer(camera as V4lCamera);
			else if (camera is RtspCamera)
				renderer = new RtspRenderer(camera as RtspCamera);
			else if (camera is MjpegCamera)
				renderer = new MjpegRenderer(camera as MjpegCamera);
			else
				continue;

			camera_grid.attach(renderer.get_widget(), row, col);
			renderer.play();

			renderers.add(renderer);

			i++;
		}

		camera_grid.show_all();
	}

	public void show_renderer_fullscreen(RendererWidget widget)
	{
		empty_renderer_widget = widget;
		widget.remove(widget.gst_widget);
		camera_view.add(widget.gst_widget);

		camera_grid.hide();
		back_button.show();
	}


}