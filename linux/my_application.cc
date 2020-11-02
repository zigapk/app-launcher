#include "my_application.h"

#include <flutter_linux/flutter_linux.h>

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
};

static void screen_changed(GtkWidget *widget, GdkScreen *old_screen, gpointer user_data);
static gboolean expose_draw(GtkWidget *widget, GdkEventExpose *event, gpointer userdata);

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  GtkWidget *window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_default_size(GTK_WINDOW(window), 1280, 720); // TODO: too big, only here until layer-shell works

  // Before the window is first realized, set it up to be a layer surface
  // gtk_layer_init_for_window (GTK_WINDOW(window));

  // Order below normal windows
  // gtk_layer_set_layer (GTK_WINDOW(window), GTK_LAYER_SHELL_LAYER_TOP);

  // Push other windows out of the way
  //  gtk_layer_auto_exclusive_zone_enable (GTK_WINDOW(window));

  // gtk_layer_set_anchor(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_BOTTOM, TRUE);
  // gtk_layer_set_anchor(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_LEFT, TRUE);
  // gtk_layer_set_anchor(GTK_WINDOW(window), GTK_LAYER_SHELL_EDGE_RIGHT, TRUE);

  // gtk_window_set_title(GTK_WINDOW(window), "Alpha Demo");
  g_signal_connect(G_OBJECT(window), "delete-event", gtk_main_quit, NULL);
  gtk_widget_show(GTK_WIDGET(window));

  gtk_widget_set_app_paintable(window, TRUE);

  g_signal_connect(G_OBJECT(window), "draw", G_CALLBACK(expose_draw), NULL);
  g_signal_connect(G_OBJECT(window), "screen-changed", G_CALLBACK(screen_changed), NULL);

  gtk_window_set_type_hint(GTK_WINDOW(window), GDK_WINDOW_TYPE_HINT_DOCK);
  gtk_window_set_decorated(GTK_WINDOW(window), FALSE);

  g_autoptr(FlDartProject) project = fl_dart_project_new();

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
  screen_changed(window, NULL, NULL);

  gtk_widget_show_all(window);
  gtk_main();

}

gboolean supports_alpha = FALSE;
static void screen_changed(GtkWidget *widget, GdkScreen *old_screen, gpointer userdata) {
    GdkScreen *screen = gtk_widget_get_screen(widget);
    GdkVisual *visual = gdk_screen_get_rgba_visual(screen);

    if (!visual) {
        visual = gdk_screen_get_system_visual(screen);
        supports_alpha = FALSE;
    } else {
        supports_alpha = TRUE;
    }

        gtk_widget_set_visual(widget, visual);
}

static gboolean expose_draw(GtkWidget *widget, GdkEventExpose *event, gpointer userdata) {
    GdkWindow *window = gtk_widget_get_window (widget);
    cairo_surface_t *surface = gdk_window_create_similar_surface(
        window,
        CAIRO_CONTENT_COLOR_ALPHA,
        0,
        0
    );
    cairo_t *cr = cairo_create (surface);

    if (supports_alpha) {
        cairo_set_source_rgba (cr, 1.0, 1.0, 1.0, 0.0);
    } else {
        cairo_set_source_rgb (cr, 1.0, 1.0, 1.0);
    }

    cairo_set_operator (cr, CAIRO_OPERATOR_SOURCE);
    cairo_paint (cr);

    cairo_destroy(cr);

    return FALSE;
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     nullptr));
}
