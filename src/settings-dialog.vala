using Gtk;

[GtkTemplate (ui = "/app/junker/cctv-watcher/settings-dialog.ui")]
public class SettingsDialog : Dialog 
{
	[GtkChild] public CheckButton startup_checkbutton;
	[GtkChild] public CheckButton systray_checkbutton;

	public SettingsDialog()
	{
		startup_checkbutton.set_active(config.startup);
		systray_checkbutton.set_active(config.systray);
	}

	[GtkCallback]
	public void on_save_button_clicked(Button button)
	{
		config.startup = startup_checkbutton.get_active();
		config.systray = systray_checkbutton.get_active();

		config.save();

		systray.set_visible(config.systray);

		this.destroy();
	}


	[GtkCallback]
	public void on_cancel_button_clicked(Button button)
	{
		this.destroy();
	}
}