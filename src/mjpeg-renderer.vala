using Gst;

public class MjpegRenderer : Renderer
{
	public MjpegRenderer(MjpegCamera camera)
	{
		base(camera);

		var source = ElementFactory.make("souphttpsrc", "source");

		source.set("location", camera.url);

		if (camera.auth)
		{
			source.set("user-id", camera.username);
			source.set("user-pw", camera.password);
		}

		pipeline.add(source);

		if (!source.link(this.decoder))
		{
			warning("source<->decoder Elements could not be linked.");
			return;
		}
	}
}