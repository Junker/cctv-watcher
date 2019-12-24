public class ConfigFile
{
	public KeyFile file;
	public string filename;

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

			string[] groups = file.get_groups();

			foreach (string group in groups)
			{
				if (!group.has_prefix("camera:"))
					continue;

				var camera_type = file.get_string(group, "type");
				var camera_name = file.get_string(group, "name");


				try
				{
					switch (camera_type)
					{
					case CameraType.RTSP:
					{
						var new_camera = new RtspCamera(camera_name);
						new_camera.set_url(file.get_string(group, "url"));

						if (file.has_key(group, "proto"))
							new_camera.proto = RtspProto.parse(file.get_string(group, "proto"));

						cameras.add(new_camera);
						break;
					}
					case CameraType.MJPEG:
					{
						var new_camera = new MjpegCamera(camera_name);
						new_camera.set_url(file.get_string(group, "url"));

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
						new_camera.set_device(file.get_string(group, "device"));

						cameras.add(new_camera);
						break;
					}
					}
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
		try
		{
			var config_dir = GLib.Path.get_dirname(this.filename);
			Posix.mkdir(config_dir, 0755);

			foreach(Camera camera in cameras)
			{
				var group = "camera: "+camera.name;

				file.set_string(group, "name", camera.name);
				file.set_string(group, "type", camera.get_camera_type_name());

				if (camera is RtspCamera)
				{
					file.set_string(group, "url", (camera as RtspCamera).url);
					file.set_string(group, "proto", (camera as RtspCamera).get_proto_name());
				}
				if (camera is MjpegCamera)
				{
					file.set_string(group, "url", (camera as MjpegCamera).url);
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