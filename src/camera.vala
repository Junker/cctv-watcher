public abstract class Camera : Object
{
	public string name;

	protected Camera(string name)
	{
		this.name = name;
	}

	public string? get_camera_type_name()
	{
		switch(this.get_type().name())
		{
			case "RtspCamera":
				return CameraType.RTSP;
			case "MjpegCamera":
				return CameraType.MJPEG;
			case "OnvifCamera":
				return CameraType.ONVIF;
			case "V4lCamera":
				return CameraType.V4L;
			default:
				return null;
		}
	}

}

namespace CameraType
{
	public const string RTSP  = "rtsp";
	public const string ONVIF = "onvif";
	public const string MJPEG = "mjpeg";
	public const string V4L   = "v4l";
}

public errordomain CameraError
{
	WRONG_PARAM,
	ERROR
}

