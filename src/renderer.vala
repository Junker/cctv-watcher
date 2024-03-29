using Gst;

public abstract class Renderer : GLib.Object
{
	public Element sink;
	public Element decoder;
	public Element convert;
	public Pipeline pipeline;
	public Gst.Bus bus;
	public Camera camera;
	public RendererWidget widget;

	protected Renderer(Camera camera)
	{
		this.camera = camera;

		pipeline = new Gst.Pipeline("pipeline");
		convert = ElementFactory.make("videoconvert", "convert");
		sink	= ElementFactory.make("gtksink", "sink");

		if (camera.codec == CameraCodec.H264)
			decoder = ElementFactory.make("avdec_h264", "decoder");
		else if (camera.codec == CameraCodec.H265)
			decoder = ElementFactory.make("avdec_h265", "decoder");
		else if (camera.codec == CameraCodec.MJPEG)
			decoder = ElementFactory.make("jpegdec", "decoder");
		else
			decoder = ElementFactory.make("decodebin", "decoder");

		if (decoder == null)
		{
			show_error_dialog(camera.name+": Decoder could not be created.", main_window);
		}
		if (convert == null)
		{
			show_error_dialog(camera.name+": Convert could not be created.", main_window);
		}
		if (sink == null)
		{
			show_error_dialog(camera.name+": Sink could not be created.", main_window);
		}

		pipeline.add_many(decoder, convert, sink);

		if (decoder.get_static_pad("src") != null)
		{
			if(!decoder.link(convert))
			{
				show_error_dialog("decoder<->convert Elements could not be linked.", main_window);
			}
		}
		else
			decoder.pad_added.connect(on_decoder_pad_added);

		if (!convert.link(sink))
		{
			show_error_dialog("convert<->sink Elements could not be linked.", main_window);
		}

		widget = new RendererWidget(this, camera.name);

		bus = pipeline.get_bus();
		bus.add_watch (0, this.on_pipeline_message);
	}

	public Gtk.Widget get_widget()
	{
		return widget;
	}

	private void on_decoder_pad_added(Gst.Element src, Gst.Pad new_pad)
	{
		Gst.Pad sink_pad = this.convert.get_static_pad ("sink");
		debug("Received new pad '%s' from '%s':", new_pad.name, src.name);

		// If our converter is already linked, we have nothing to do here:
		if (sink_pad.is_linked ()) {
			debug("	 We are already linked. Ignoring.");
			return ;
		}

		// Check the new pad's type:
		Gst.Caps new_pad_caps = new_pad.query_caps (null);
		weak Gst.Structure new_pad_struct = new_pad_caps.get_structure (0);
		string new_pad_type = new_pad_struct.get_name ();
		if (!new_pad_type.has_prefix ("video/x-raw")) {
			debug("	  It has type '%s' which is not raw video. Ignoring.", new_pad_type);
			return ;
		}

		// Attempt the link:
		Gst.PadLinkReturn ret = new_pad.link (sink_pad);
		if (ret != Gst.PadLinkReturn.OK)
			debug("	 Type is '%s' but link failed.", new_pad_type);
		else
			debug("	 Link succeeded (type '%s').", new_pad_type);
	}

	private bool on_pipeline_message(Gst.Bus bus, Gst.Message msg)
	{
		//Receive application messages from the bus.//
		if(msg.type == MessageType.ERROR)
		{
			GLib.Error err;
			string debug_info;

			msg.parse_error (out err, out debug_info);
			show_error_dialog("Camera:'%s', element: '%s': %s".printf(camera.name, msg.src.name, err.message), main_window);
			debug("Debugging information: %s", (debug_info != null)? debug_info : "none");

			widget.hide_spinner();
		}

		if (msg.type == MessageType.EOS)
		{
			widget.hide_spinner();
			stdout.printf ("end of stream\n");
		}
		if (msg.type == MessageType.STATE_CHANGED)
		{
			Gst.State oldstate;
			Gst.State newstate;
			Gst.State pending;
			msg.parse_state_changed (out oldstate, out newstate, out pending);

			if (newstate == Gst.State.PLAYING)
				widget.hide_spinner();

			if (newstate == Gst.State.PAUSED && pending == Gst.State.PLAYING)
				widget.show_spinner();

			debug("state changed: %s->%s:%s",
				  oldstate.to_string (), newstate.to_string (),
				  pending.to_string ());
		}

		return true;
	}

	public void play()
	{
		Gst.StateChangeReturn ret = this.pipeline.set_state(Gst.State.PLAYING);

		if (ret == Gst.StateChangeReturn.FAILURE)
		{
			show_error_dialog("Camera '%s': Unable to set the pipeline to the playing state".printf(camera.name), main_window);
		}
	}

	public void stop()
	{
		this.pipeline.set_state(Gst.State.NULL);
	}

	public void pause()
	{
		this.pipeline.set_state(Gst.State.PAUSED);
	}

	public void restart()
	{
		this.stop();
		this.play();
	}
}