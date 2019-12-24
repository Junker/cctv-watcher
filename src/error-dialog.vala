using Gtk;

public class ErrorDialog : MessageDialog
{
    public ErrorDialog(Object parent, string text)
	{
		base(parent,
			Gtk.DialogFlags.MODAL,
			Gtk.MessageType.WARNING,
			Gtk.ButtonsType.OK,
			message);

		this.show();
	}
}