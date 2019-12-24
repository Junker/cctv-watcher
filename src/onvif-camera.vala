public class OnvifCamera : Camera
{
	public string host;
	public int port;
	public string? username;
	public string? password;

	public OnvifCamera(string name)
	{
		base(name);
	}

}