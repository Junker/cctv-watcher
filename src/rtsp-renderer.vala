using Gst;

public class RtspRenderer : Renderer
{
	public Element queue;
	public Element source;

	public RtspRenderer(string url)
	{
		base();

		source = ElementFactory.make("rtspsrc", "rtsp");
		source.set("location", url);
		// source.set("protocols", RTSP.LowerTrans.TCP);

		queue = ElementFactory.make("queue", "queue");

		pipeline.add_many(source, queue);

		source.pad_added.connect(on_rtsp_pad_added);

		// if (!queue.link(decoder))
		// {
		// 	stderr.printf("queue<->decoder Elements could not be linked.\n");
		// 	return;
		// }

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
		}
	}

	public void on_rtsp_pad_added(Gst.Element src, Gst.Pad new_pad)
	{
		Gst.Pad sink_pad = this.decoder.get_static_pad("sink");
		stdout.printf("Received new pad '%s' from '%s':\n", new_pad.name, src.name);

		Gst.Caps new_pad_caps = new_pad.query_caps (null);
		weak Gst.Structure new_pad_struct = new_pad_caps.get_structure (0);
		string new_pad_type = new_pad_struct.get_name ();
		stdout.printf("RTSP:  It has type '%s'\n", new_pad_type);

		Gst.PadLinkReturn ret = new_pad.link (sink_pad);
	}
}