using Gst;

public class TestRenderer : Renderer
{

	public TestRenderer()
	{
		base();

		var source = ElementFactory.make("videotestsrc", "source");

		pipeline.add(source);

		if (!source.link(this.decoder))
		{
			stderr.printf("source<->decoder Elements could not be linked.\n");
			return;
		}


	}
}