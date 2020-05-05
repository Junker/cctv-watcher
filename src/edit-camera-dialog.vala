using Gtk;
using Gee;
using GUdev;

[GtkTemplate (ui = "/app/junker/cctv-watcher/edit-camera-dialog.ui")]
public class EditCameraDialog : Dialog 
{
	private Camera? camera = null;

	[GtkChild] public ComboBoxText type_combobox;
	[GtkChild] public Entry name_entry;
	[GtkChild] public Grid rtsp_grid;
	[GtkChild] public Grid onvif_grid;
	[GtkChild] public Grid mjpeg_grid;
	[GtkChild] public Grid v4l_grid;
	[GtkChild] public Entry rtsp_url_entry;
	[GtkChild] public CheckButton rtsp_auth_checkbutton;
	[GtkChild] public Entry rtsp_username_entry;
	[GtkChild] public Entry rtsp_password_entry;
	[GtkChild] public ComboBoxText rtsp_proto_combobox;
	[GtkChild] public ComboBoxText rtsp_codec_combobox;
	[GtkChild] public Entry mjpeg_url_entry;
	[GtkChild] public CheckButton mjpeg_auth_checkbutton;
	[GtkChild] public Entry mjpeg_username_entry;
	[GtkChild] public Entry mjpeg_password_entry;
	[GtkChild] public ComboBoxText v4l_device_combobox;


	public EditCameraDialog()
	{
		this.on_type_combobox_changed(type_combobox);

		this.v4l_load_camera_list();
	}

	[GtkCallback]
	public void on_rtsp_auth_checkbutton_toggled(ToggleButton button)
	{
		rtsp_username_entry.sensitive = rtsp_auth_checkbutton.active;
		rtsp_password_entry.sensitive = rtsp_auth_checkbutton.active;
	}

	[GtkCallback]
	public void on_mjpeg_auth_checkbutton_toggled(ToggleButton button)
	{
		mjpeg_username_entry.sensitive = mjpeg_auth_checkbutton.active;
		mjpeg_password_entry.sensitive = mjpeg_auth_checkbutton.active;
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
			if (this.camera == null && camera_name == camera.name)
			{
				show_error_dialog("This name already used ", this);
				return;
			}
		}

		try
		{
			Camera new_camera = null;

			switch (camera_type)
			{
				case CameraType.RTSP:
				{
					new_camera = new RtspCamera(camera_name);
					var cam = new_camera as RtspCamera;

					cam.set_url(rtsp_url_entry.text);
					cam.proto = RtspProto.parse(rtsp_proto_combobox.active_id);

					cam.auth = rtsp_auth_checkbutton.active;
					cam.username = rtsp_username_entry.text.strip();
					cam.password = rtsp_password_entry.text.strip();

					cam.codec = CameraCodec.parse(rtsp_codec_combobox.active_id);

					break;
				}
				case CameraType.MJPEG:
				{
					new_camera = new MjpegCamera(camera_name);
					var cam = new_camera as MjpegCamera;

					cam.set_url(mjpeg_url_entry.text);

					cam.auth = rtsp_auth_checkbutton.active;
					cam.username = rtsp_username_entry.text.strip();
					cam.password = rtsp_password_entry.text.strip();

					break;
				}
				case CameraType.ONVIF:
				{
					new_camera = new OnvifCamera(camera_name);
					var cam = new_camera as OnvifCamera;

					break;
				}
				case CameraType.V4L:
				{
					new_camera = new V4lCamera(camera_name);
					var cam = new_camera as V4lCamera;

					cam.set_device(v4l_device_combobox.active_id);

					break;
				}
			}

			if (new_camera == null)
				return;

			if (this.camera != null)
			{
				cameras.insert(cameras.index_of(this.camera), new_camera);
				cameras.remove(this.camera);
			}
			else
				cameras.add(new_camera);

		}
		catch (CameraError e)
		{
			show_error_dialog(e.message, this);
		}



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
			dialog.type_combobox.set_active_id(CameraType.RTSP);

			var cam = camera as RtspCamera;
			dialog.rtsp_url_entry.text = cam.url;
			dialog.rtsp_auth_checkbutton.active = cam.auth;
			dialog.rtsp_username_entry.text = cam.username;
			dialog.rtsp_password_entry.text = cam.password;
			dialog.rtsp_proto_combobox.set_active_id(cam.get_proto_name());
			dialog.rtsp_codec_combobox.set_active_id(cam.get_codec_name());

		}
		else if (camera is MjpegCamera)
		{
			dialog.type_combobox.set_active_id(CameraType.MJPEG);

			var cam = camera as MjpegCamera;
			dialog.mjpeg_url_entry.text = cam.url;
			dialog.mjpeg_auth_checkbutton.active = cam.auth;
			dialog.mjpeg_username_entry.text = cam.username;
			dialog.mjpeg_password_entry.text = cam.password;
		}
		else if (camera is V4lCamera)
		{
			dialog.type_combobox.set_active_id(CameraType.V4L);

			var cam = camera as V4lCamera;

			dialog.v4l_device_combobox.set_active_id(cam.device);

			if (dialog.v4l_device_combobox.active_id == null)
			{
				dialog.v4l_device_combobox.append(cam.device, cam.device);
				dialog.v4l_device_combobox.set_active_id(cam.device);
			}
		}

		dialog.show();

		return dialog;
	}

	private void v4l_load_camera_list()
	{
		var client = new GUdev.Client(null);
		var devices = client.query_by_subsystem("video4linux");

		foreach (var dev in devices)
		{
			v4l_device_combobox.append(dev.get_device_file(), "%s (%s)".printf(dev.get_property("ID_V4L_PRODUCT"), dev.get_device_file()));
		}
	}
}