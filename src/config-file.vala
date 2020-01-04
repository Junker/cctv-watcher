public class ConfigFile
{
	public KeyFile file;
	public string filename;
	public bool startup = false;
	public bool systray = false;
	public bool minimize_pause = true;

	public ConfigFile()
	{
		this.file = new KeyFile();

		this.filename = GLib.Path.build_filename(GLib.Environment.get_home_dir(), ".config", GETTEXT_PACKAGE, "cctv-watcher.conf");
	}

	public bool load()
	{
		try
		{
			this.file.load_from_file(this.filename, KeyFileFlags.NONE);

			if (file.has_key("settings", "systray"))
				this.systray = file.get_boolean("settings", "systray");
			if (file.has_key("settings", "startup"))
				this.startup = file.get_boolean("settings", "startup");
			if (file.has_key("settings", "minimize_pause"))
				this.minimize_pause = file.get_boolean("settings", "minimize_pause");

			string[] groups = file.get_groups();

			foreach (string group in groups)
			{
				if (!group.has_prefix("camera:"))
					continue;

				var camera_type = file.get_string(group, "type");
				var camera_name = group.substring(7);

				try
				{
					Camera? new_camera = null;


					switch (camera_type)
					{
					case CameraType.RTSP:
					{
						new_camera = new RtspCamera(camera_name);
						var cam = new_camera as RtspCamera;

						cam.set_url(file.get_string(group, "url"));

						if (file.has_key(group, "proto"))
							cam.proto = RtspProto.parse(file.get_string(group, "proto"));

						if (file.has_key(group, "auth"))
							cam.auth = file.get_boolean(group, "auth");

						if (file.has_key(group, "username"))
						{
							cam.username = file.get_string(group, "username");
							cam.password = file.get_string(group, "password");
						}

						if (file.has_key(group, "codec"))
							cam.codec = CameraCodec.parse(file.get_string(group, "codec"));

						break;
					}
					case CameraType.MJPEG:
					{
						new_camera = new MjpegCamera(camera_name);
						var cam = new_camera as MjpegCamera;
						cam.set_url(file.get_string(group, "url"));

						if (file.has_key(group, "auth"))
							cam.auth = file.get_boolean(group, "auth");

						if (file.has_key(group, "username"))
						{
							cam.username = file.get_string(group, "username");
							cam.password = file.get_string(group, "password");
						}
						break;
					}
					case CameraType.ONVIF:
					{
						new_camera = new OnvifCamera(camera_name);
						break;
					}
					case CameraType.V4L:
					{
						new_camera = new V4lCamera(camera_name);
						var cam = new_camera as V4lCamera;
						cam.set_device(file.get_string(group, "device"));
						break;
					}
					}

					if (new_camera == null)
						continue;

					if (file.has_key(group, "codec"))
					{
						new_camera.codec = CameraCodec.parse(file.get_string(group, "codec"));
					}

					cameras.add(new_camera);
				}
				catch (CameraError e)
				{
					stderr.printf("load config error: %s\n", e.message);
					continue;
				}

			}
		}
		catch(KeyFileError err)
		{
			stderr.printf("load config error: %s\n", err.message);
			return false;
		}
		catch(FileError err)
		{
			stderr.printf("load config error: %s\n", err.message);
			return false;
		}

		return true;
	}

	public bool save()
	{
		file.set_boolean("settings", "startup", config.startup);
		file.set_boolean("settings", "systray", config.systray);
		file.set_boolean("settings", "minimize_pause", config.minimize_pause);

		//delete all cameras
		foreach (string group in file.get_groups())
		{
			if (group.has_prefix("camera:"))
				file.remove_group(group);
		}

		try
		{
			var config_dir = GLib.Path.get_dirname(this.filename);
			DirUtils.create(config_dir, 0755);

			foreach(Camera camera in cameras)
			{
				var group = "camera:"+camera.name;

				file.set_string(group, "type", camera.get_camera_type_name());

				if (camera is RtspCamera)
				{
					var cam = camera as RtspCamera;
					file.set_string(group, "url", cam.url);
					file.set_string(group, "proto", cam.get_proto_name());
					file.set_boolean(group, "auth", cam.auth);

					if (cam.auth)
					{
						file.set_string(group, "username", cam.username);
						file.set_string(group, "password", cam.password);
					}

					if (cam.codec != CameraCodec.AUTO)
						file.set_string(group, "codec", cam.get_codec_name());
				}
				if (camera is MjpegCamera)
				{
					var cam = camera as MjpegCamera;
					file.set_string(group, "url", cam.url);
					file.set_boolean(group, "auth", cam.auth);

					if (cam.auth)
					{
						file.set_string(group, "username", cam.username);
						file.set_string(group, "password", cam.password);
					}
				}
				if (camera is OnvifCamera)
				{
				}
				if (camera is V4lCamera)
				{
					file.set_string(group, "device", (camera as V4lCamera).device);
				}
			}

			return this.file.save_to_file(this.filename);
		}
		catch(KeyFileError err)
		{
			return false;
		}
		catch(FileError err)
		{
			return false;
		}
	}
}