using Gtk;

public class SysTray : StatusIcon 
{
	public Gtk.Menu context_menu;

	construct 
	{
		this.set_from_icon_name("camera-web");

		this.popup_menu.connect(() => 
		{
			this.context_menu.popup_at_pointer();
		});

		this.button_release_event.connect((event) =>
		{
			if (event.button == 1)
			{
				if (main_window.is_active)
				{
					if (config.minimize_pause)
					{
						main_window.stop_renderers();
					}

					main_window.hide();
				}
				else
				{
					main_window.play_renderers();

					main_window.show();
					main_window.present();
				}
			}
		});

		this.set_visible(config.systray);

		this.build_menu();
	}

	public void build_menu()
	{
		context_menu = new Gtk.Menu();

		var menu_settings = new Gtk.MenuItem.with_mnemonic("_Settings");
		menu_settings.activate.connect(menu_settings_clicked);
		context_menu.append(menu_settings);

		// var menu_about = new Gtk.MenuItem.with_mnemonic(_("_About"));
		// menu_about.activate.connect(menu_about_clicked);
		// context_menu.append(menu_about);

		context_menu.append(new SeparatorMenuItem());

		var menu_quit = new Gtk.MenuItem.with_mnemonic(_("_Quit"));
		menu_quit.activate.connect(() => {app.destroy();});
		context_menu.append(menu_quit);

		context_menu.show_all();
	}

	public void menu_settings_clicked()
	{
		var dialog = new SettingsDialog();
		dialog.show_all();
	}



}