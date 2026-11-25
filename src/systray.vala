using Gtk;

// Иконка в системном трее.
//
// На Wayland (Plasma 6) старый GtkStatusIcon (XEmbed) не отображается —
// KDE его не рисует. Поэтому при наличии AppIndicator используем
// StatusNotifierItem, который Plasma 6 поддерживает нативно.
public class SysTray : Object
{
	public Gtk.Menu context_menu;

#if HAVE_APPINDICATOR
	private AppIndicator.Indicator indicator;
#else
	private Gtk.StatusIcon status_icon;
#endif

	construct
	{
		this.build_menu();

#if HAVE_APPINDICATOR
		indicator = new AppIndicator.Indicator(
			"cctv-watcher", "camera-web", AppIndicator.IndicatorCategory.APPLICATION_STATUS);
		indicator.set_status(AppIndicator.IndicatorStatus.ACTIVE);
		indicator.set_title("CCTV Watcher");
		indicator.set_menu(context_menu);
		// Левый клик по иконке — показать/скрыть окно.
		indicator.set_secondary_activate_target(null);
		indicator.activate.connect(() =>
		{
			app.toggle();
		});
		this.set_visible(config.systray);
#else
		status_icon = new Gtk.StatusIcon();
		status_icon.set_from_icon_name("camera-web");

		status_icon.popup_menu.connect(() =>
		{
			this.context_menu.popup_at_pointer();
		});

		status_icon.button_release_event.connect((event) =>
		{
			if (event.button == 1)
			{
				app.toggle();
			}
			return false;
		});

		this.set_visible(config.systray);
#endif
	}

	public void set_visible(bool visible)
	{
#if HAVE_APPINDICATOR
		if (visible)
			indicator.set_status(AppIndicator.IndicatorStatus.ACTIVE);
		else
			indicator.set_status(AppIndicator.IndicatorStatus.PASSIVE);
#else
		if (status_icon != null)
			status_icon.set_visible(visible);
#endif
	}

	public void build_menu()
	{
		context_menu = new Gtk.Menu();

		var menu_toggle = new Gtk.MenuItem.with_mnemonic(_("_Show / Hide"));
		menu_toggle.activate.connect(() => { app.toggle(); });
		context_menu.append(menu_toggle);

		var menu_settings = new Gtk.MenuItem.with_mnemonic(_("_Settings"));
		menu_settings.activate.connect(menu_settings_clicked);
		context_menu.append(menu_settings);

		context_menu.append(new SeparatorMenuItem());

		var menu_quit = new Gtk.MenuItem.with_mnemonic(_("_Quit"));
		menu_quit.activate.connect(() => { app.destroy(); });
		context_menu.append(menu_quit);

		context_menu.show_all();
	}

	public void menu_settings_clicked()
	{
		var dialog = new SettingsDialog();
		dialog.show_all();
	}
}
