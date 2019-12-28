using Gtk;
using Gee;

[GtkTemplate (ui = "/app/junker/cctv-watcher/edit-camera-dialog.ui")]
public class EditCameraDialog : Dialog 
{
	private Camera? camera;

	[GtkChild] public ComboBoxText type_combobox;
	[GtkChild] public Entry name_entry;
	[GtkChild] public Grid rtsp_grid;
	[GtkChild] public Grid onvif_grid;
	[GtkChild] public Grid mjpeg_grid;
	[GtkChild] public Grid v4l_grid;
	[GtkChild] public Entry rtsp_url_entry;
	[GtkChild] public ComboBoxText rtsp_proto_combobox;
	[GtkChild] public Entry mjpeg_url_entry;
	[GtkChild] public Entry v4l_device_entry;


	public EditCameraDialog()
	{
		this.on_type_combobox_changed(type_combobox);
	}

	
	[GtkCallback]
	public void on_save_button_clicked(Button button)
	{
		string camera_name = name_entry.text.strip();
		string camera_type = type_combobox.active_id;

		if (camera_name == "")
		{
			show_error_dialog("Name is empty", this);
			return;
		}

		foreach (Camera camera in cameras)
		{
			if (camera_name == camera.name)
			{
				show_error_dialog("This name already used ", this);
				return;
			}

		}

		try
		{
			switch (camera_type)
			{
				case CameraType.RTSP:
				{
					var new_camera = new RtspCamera(camera_name);
					new_camera.set_url(rtsp_url_entry.text);
					new_camera.proto = RtspProto.parse(rtsp_proto_combobox.active_id);

					cameras.add(new_camera);
					break;
				}
				case CameraType.MJPEG:
				{
					var new_camera = new MjpegCamera(camera_name);
					new_camera.set_url(mjpeg_url_entry.text);

					cameras.add(new_camera);
					break;
				}
				case CameraType.ONVIF:
				{
					var new_camera = new OnvifCamera(camera_name);

					cameras.add(new_camera);
					break;
				}
				case CameraType.V4L:
				{
					var new_camera = new V4lCamera(camera_name);
					new_camera.set_device(v4l_device_entry.text);

					cameras.add(new_camera);
					break;
				}
			}
		}
		catch (CameraError e)
		{
			show_error_dialog(e.message, this);
		}


		if (this.camera != null)
			cameras.remove(this.camera);

		config.save();

		stdout.printf("add camera: %s, type: %s\n", camera_name, camera_type);

		main_window.refresh_cameras();

		this.destroy();
	}

	[GtkCallback]
	public void on_cancel_button_clicked(Button button)
	{
		this.destroy();
	}


	[GtkCallback]
	public void on_type_combobox_changed(ComboBox combobox)
	{
		rtsp_grid.visible = false;
		onvif_grid.visible = false;
		mjpeg_grid.visible = false;
		v4l_grid.visible = false;

		switch (combobox.active_id)
		{
			case CameraType.RTSP:
			{
				rtsp_grid.visible = true;
				break;
			}
			case CameraType.MJPEG:
			{
				mjpeg_grid.visible = true;
				break;
			}
			case CameraType.ONVIF:
			{
				onvif_grid.visible = true;
				break;
			}
			case CameraType.V4L:
			{
				v4l_grid.visible = true;
				break;
			}
		}
	}

	public static EditCameraDialog add_camera()
	{
		var dialog = new EditCameraDialog();
		dialog.name_entry.text = "New camera";
		dialog.show();

		return dialog;
	}

	public static EditCameraDialog edit_camera(Camera camera)
	{
		var dialog = new EditCameraDialog();

		dialog.camera = camera;

		dialog.name_entry.text = camera.name;

		if (camera is RtspCamera)
		{
			dialog.rtsp_url_entry.text = (camera as RtspCamera).url;
		}

		dialog.show();

		return dialog;
	}
}