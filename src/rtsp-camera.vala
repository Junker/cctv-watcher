public enum RtspProto
{
	AUTO,
	UDP,
	TCP;

	public static RtspProto parse(string proto)
	{
		switch (proto)
		{
			case "udp":
				return RtspProto.UDP;
			case "tcp":
				return RtspProto.TCP;
			case "auto":
				return RtspProto.AUTO;
			default:
				return RtspProto.AUTO;
		}
	}
}



public class RtspCamera : Camera
{
	public string url {get;}
	private const string[] schemas = {"rtsp", "rtspu", "rtspt", "rtsph", "rtsp-sdp", "rtsps", "rtspsu", "rtspst", "rtspsh"};
	public RtspProto proto = RtspProto.AUTO;
	public bool auth = false;
	public string username = "";
	public string password = "";

	public RtspCamera(string name)
	{
		base(name);
	}

	public void set_url(string url) throws CameraError
	{
		var surl = url.strip();

		var scheme = Uri.parse_scheme(surl);

		if (array_search(scheme, schemas) == -1)
			throw new CameraError.WRONG_PARAM("URL should be RTSP url, e.g., rtsp://192.168.1.21:554/");

		this._url = surl;
	}

	public string get_proto_name()
	{
		switch(proto)
		{
			case RtspProto.UDP:
				return "udp";
			case RtspProto.TCP:
				return "tcp";
			case RtspProto.AUTO:
				return "auto";
		}

		return "auto";
	}
}