using Gtk;
using Gee;
using GUdev;

[GtkTemplate (ui = "/app/junker/cctv-watcher/camera-list-dialog.ui")]
public class CameraListDialog : Dialog
{
	[GtkChild] public TreeView camera_tree_view;
	[GtkChild] public TreeSelection camera_tree_selection;
	[GtkChild] public Gtk.ListStore camera_list_store;
	[GtkChild] public Button edit_button;
	[GtkChild] public Button delete_button;

	enum Columns
	{
		NAME,
		TYPE,
		CAMERA
	}

	public CameraListDialog()
	{
		this.load_camera_list();
	}

	[GtkCallback]
	public void on_edit_button_clicked(Button button)
	{
		Gtk.TreeModel model;
		Gtk.TreeIter iter;
		Camera camera;

		if (camera_tree_selection.get_selected(out model, out iter))
		{
			camera_list_store.get(iter, Columns.CAMERA, out camera);

			if (EditCameraDialog.edit_camera(camera).run() == Gtk.ResponseType.OK)
			{
				this.load_camera_list();
			}
		}
	}

	[GtkCallback]
	public void on_delete_button_clicked(Button button)
	{
		Gtk.TreeModel model;
		Gtk.TreeIter iter;
		Camera camera;

		if (camera_tree_selection.get_selected(out model, out iter))
		{
			camera_list_store.get(iter, Columns.CAMERA, out camera);
			cameras.remove(camera);
			camera_list_store.remove(ref iter);

			config.save();
			main_window.refresh_cameras();
		}
	}

	[GtkCallback]
	public void on_cancel_button_clicked(Button button)
	{
		this.destroy();
	}


	[GtkCallback]
	public void on_camera_tree_view_row_activated(TreeView tree_view, TreePath path, TreeViewColumn column)
	{
		edit_button.sensitive = true;
		delete_button.sensitive = true;
	}

	public void load_camera_list()
	{
		camera_list_store.clear();

		foreach (Camera camera in cameras)
		{
			Gtk.TreeIter iter;
			camera_list_store.append(out iter);
			camera_list_store.set(iter,
								  Columns.NAME, camera.name,
								  Columns.TYPE, camera.get_camera_type_name(),
								  Columns.CAMERA, camera);
		}
	}
}