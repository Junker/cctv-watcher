using Gtk;
using Gee;

[GtkTemplate (ui = "/app/junker/cctv-watcher/main-window.ui")]
public class MainWindow : ApplicationWindow
{
	[GtkChild]
	public Grid camera_grid;

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

		var i = 0;

		foreach (Camera camera in cameras)
		{
			i++;

			if (camera is TestCamera)
			{
				var renderer = new TestRenderer();
				camera_grid.attach(renderer.getWidget(),1,i);
				renderer.play();
			}
			if (camera is V4lCamera)
			{
				var cam = (V4lCamera) camera;
				var renderer = new V4lRenderer(cam.device);
				camera_grid.attach(renderer.getWidget(),1,i);
				renderer.play();
			}
			if (camera is RtspCamera)
			{
				var cam = (RtspCamera) camera;
				var renderer = new RtspRenderer(cam.url);
				renderer.set_proto(cam.proto);
				camera_grid.attach(renderer.getWidget(),2,i);
				renderer.play();
			}
			if (camera is MjpegCamera)
			{
				var cam = (MjpegCamera) camera;
				var renderer = new MjpegRenderer(cam.url);
				camera_grid.attach(renderer.getWidget(),1,i);
				renderer.play();
			}
		}

		camera_grid.show_all();
	}

}