using Gtk;

[GtkTemplate (ui = "/app/junker/cctv-watcher/settings-dialog.ui")]
public class SettingsDialog : Dialog 
{
	[GtkChild] public CheckButton startup_checkbutton;
	[GtkChild] public CheckButton systray_checkbutton;
	[GtkChild] public CheckButton minimize_pause_checkbutton;

	private string desktop_autostart_file_path;

	construct
	{
		desktop_autostart_file_path = GLib.Path.build_filename(GLib.Environment.get_user_config_dir(), "autostart", "cctv-watcher.desktop");
	}


	public SettingsDialog()
	{
		startup_checkbutton.set_active(config.startup);
		systray_checkbutton.set_active(config.systray);
		minimize_pause_checkbutton.set_active(config.minimize_pause);
	}

	[GtkCallback]
	public void on_save_button_clicked(Button button)
	{
		config.startup = startup_checkbutton.get_active();
		config.systray = systray_checkbutton.get_active();
		config.minimize_pause = minimize_pause_checkbutton.get_active();

		config.save();

		systray.set_visible(config.systray);

		if (config.startup)
		{
			File desktop_file = File.new_build_filename(DATA_DIR, "cctv-watcher.desktop");
			File autostart_file = File.new_for_path(desktop_autostart_file_path);

			desktop_file.copy(autostart_file, FileCopyFlags.NONE);
		}
		else
		{
			File file = File.new_for_path(desktop_autostart_file_path);

			if (file.query_exists())
				file.@delete();
		}

		this.destroy();
	}


	[GtkCallback]
	public void on_cancel_button_clicked(Button button)
	{
		this.destroy();
	}
}