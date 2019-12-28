using Gst;

public class V4lRenderer : Renderer
{

	public V4lRenderer(V4lCamera camera)
	{
		base(camera);

		var source = ElementFactory.make("v4l2src", "source");
		source.set("device", camera.device);
//
		pipeline.add(source);

		if (!source.link(this.decoder))
		{
			stderr.printf("source<->decoder Elements could not be linked.\n");
			return;
		}


	}
}