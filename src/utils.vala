
public void show_error_dialog(string message, Gtk.Window? transient_for)
{
	var dialog = new Gtk.MessageDialog(transient_for,
									   Gtk.DialogFlags.DESTROY_WITH_PARENT,
									   Gtk.MessageType.ERROR,
									   Gtk.ButtonsType.OK,
									   "%s", message);

	dialog.response.connect((id) =>
	{
		if (id == Gtk.ResponseType.OK)
		dialog.destroy();
	});

	dialog.run();
}



int array_search(string needle, string[] haystack)
{
    int result = -1;

	for (int i=0; i < haystack.length; i++)
	{
        if(needle == haystack[i]) return i;
    }

    return result;
}