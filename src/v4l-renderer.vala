using Gst;

public class V4lRenderer : Renderer
{

	public V4lRenderer(string device)
	{
		base();

		var source = ElementFactory.make("v4l2src", "source");
		source.set("device", device);
//
		pipeline.add(source);

		if (!source.link(this.decoder))
		{
			stderr.printf("source<->decoder Elements could not be linked.\n");
			return;
		}


	}
}