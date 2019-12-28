public enum CameraCodec
{
	AUTO,
	H264,
	H265,
	MJPEG;

	public static CameraCodec parse(string codec_name)
	{
		switch (codec_name)
		{
			case "h264":
				return CameraCodec.H264;
			case "h265":
				return CameraCodec.H265;
			case "mjpeg":
				return CameraCodec.MJPEG;
			default:
				return CameraCodec.AUTO;
		}
	}
}

public abstract class Camera : Object
{
	public string name;
	public CameraCodec codec = CameraCodec.AUTO;

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

