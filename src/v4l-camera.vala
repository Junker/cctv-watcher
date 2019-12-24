
public class V4lCamera : Camera
{
	public string device {get;}

	public V4lCamera(string name)
	{
		base(name);
	}


	public void set_device(string device) throws CameraError
	{
		var sdevice = device.strip();

		var file = File.new_for_path(sdevice);

		if (!file.query_exists())
			throw new CameraError.WRONG_PARAM("Device doesn't exists");

		if (file.query_file_type(FileQueryInfoFlags.NONE) != FileType.SPECIAL)
			throw new CameraError.WRONG_PARAM("Wrong device, should be in /dev folder, e.g., /dev/video0");

		this._device = sdevice;
	}
}