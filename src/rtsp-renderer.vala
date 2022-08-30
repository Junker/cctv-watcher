using Gst;

public class RtspRenderer : Renderer
{
	public Element queue;
	public Element source;
	public Element depay;

	public RtspRenderer(RtspCamera camera)
	{
		base(camera);

		source = ElementFactory.make("rtspsrc", "rtsp");
		source.set("location", camera.url);

		this.set_proto(camera.proto);

		if (camera.auth)
		{
			source.set("user-id", camera.username);
			source.set("user-pw", camera.password);
		}

		pipeline.add(source);
		source.pad_added.connect(on_rtsp_pad_added);

		if (camera.codec != CameraCodec.AUTO)
		{
			string depay_name = "";

			switch (camera.codec)
			{
				case CameraCodec.H264:
					depay_name = "rtph264depay";
					break;
				case CameraCodec.H265:
					depay_name = "rtph265depay";
					break;
			 	case CameraCodec.MJPEG:
					depay_name = "rtpjpegdepay";
					break;
			 	case CameraCodec.AUTO:
					break;
			}

			depay = ElementFactory.make(depay_name, "depay");

			pipeline.add(depay);

			if (!depay.link(decoder))
			{
				warning("depay<->decoder Elements could not be linked.");
				return;
			}

		}

		source.pad_added.connect(on_rtsp_pad_added);
	}

	public void set_proto(RtspProto proto)
	{
		switch (proto)
		{
			case RtspProto.TCP:
			{
				source.set("protocols", RTSP.LowerTrans.TCP);
				break;
			}
			case RtspProto.UDP:
			{
				source.set("protocols", RTSP.LowerTrans.UDP);
				break;
			}
			case RtspProto.AUTO:
				break;
		}
	}

	public void on_rtsp_pad_added(Gst.Element src, Gst.Pad new_pad)
	{
		var next_element = this.camera.codec == CameraCodec.AUTO ? this.decoder : this.depay;

		Gst.Pad sink_pad = next_element.get_static_pad("sink");
		debug("Received new pad '%s' from '%s'", new_pad.name, src.name);

		Gst.Caps new_pad_caps = new_pad.query_caps(null);
		weak Gst.Structure new_pad_struct = new_pad_caps.get_structure(0);
		string new_pad_type = new_pad_struct.get_name();
		debug("RTSP: It has type '%s'", new_pad_type);

		new_pad.link(sink_pad);
	}
}