using Gst;

public class MjpegRenderer : Renderer
{

	public MjpegRenderer(string url)
	{
		base();

		var source = ElementFactory.make("souphttpsrc", "source");
		source.set("location", url);

		pipeline.add(source);

		if (!source.link(this.decoder))
		{
			stderr.printf("source<->decoder Elements could not be linked.\n");
			return;
		}
	}
}