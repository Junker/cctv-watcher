using Gst;

public class TestRenderer : Renderer
{

	public TestRenderer(TestCamera camera)
	{
		base(camera);

		var source = ElementFactory.make("videotestsrc", "source");

		pipeline.add(source);

		if (!source.link(this.decoder))
		{
			warning("source<->decoder Elements could not be linked.");
			return;
		}


	}
}