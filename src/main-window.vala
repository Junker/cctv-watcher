using Gtk;
using Gee;

[GtkTemplate (ui = "/app/junker/cctv-watcher/main-window.ui")]
public class MainWindow : ApplicationWindow
{
	[GtkChild] public Grid camera_grid;

	public MainWindow (Gtk.Application application)
	{
		GLib.Object (application: application);
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

	public void refresh_cameras()
	{
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

			i++;
		}

		camera_grid.show_all();
	}

}