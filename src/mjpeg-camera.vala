public class MjpegCamera : Camera
{
	public string url {
		get;
	}

	public RtspProto proto;

	public MjpegCamera(string name)
	{
		base(name);
	}

	public void set_url(string url) throws CameraError
	{
		var scheme = GLib.Uri.parse_scheme(url);

		if (scheme != "http" && scheme != "https")
			throw new CameraError.WRONG_PARAM("URL should be HTTP or HTTPS, e.g., http://192.168.1.21:2112/");

		this._url = url.strip();
	}
}