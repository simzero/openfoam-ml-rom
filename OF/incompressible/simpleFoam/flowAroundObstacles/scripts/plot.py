import pyvista as pv
import onnxruntime as rt
import numpy as np
import argparse


parser = argparse.ArgumentParser(description="Process CFD and ROM vtu files.")
parser.add_argument('cfd', type=str, help='Path to CFD input vtu file')
parser.add_argument('ml', type=str, help='Path to ML input vtu file')
parser.add_argument('png', type=str, help='Path to image output file')
parser.add_argument('title', type=str, help='Image title')

args = parser.parse_args()

font_size = 8
zoom = 1.2
camera_position = 'xz'

if pv.OFF_SCREEN:
  pv.start_xvfb(wait=0.1)

pv.global_theme.anti_aliasing = 'msaa'
pv.global_theme.multi_samples = 8

pl = pv.Plotter(shape=(2, 3), border=False, window_size=(1600, 900))

truth_grid = pv.read(args.cfd)
ml_grid = pv.read(args.ml)

truth_grid.cell_data['diff_U'] = truth_grid['U'] - ml_grid['U']
truth_grid.cell_data['diff_p'] = truth_grid['p'] - ml_grid['p']

min_val_U = np.min(truth_grid['U'])
max_val_U = np.max(truth_grid['U'])
min_val_p = np.min(truth_grid['p'])
max_val_p = np.max(truth_grid['p'])

pl.subplot(0, 0)
pl.add_mesh(
    truth_grid.copy(),
    scalars='U',
    show_scalar_bar=True,
    scalar_bar_args={
        'title': 'Umag (m/s)',
        'title_font_size': 16,
        'label_font_size': 14,
        'n_labels': 3,
        'position_x': 0.25,
        'color': 'black',
    },
    line_width=5,
    cmap='jet',
    clim=[min_val_U, max_val_U]
)
pl.add_text("CFD", position="lower_left", color='black', font_size=font_size)
pl.camera_position = camera_position
pl.camera.zoom(zoom)

pl.subplot(0, 1)
pl.add_mesh(
    ml_grid.copy(),
    scalars='U',
    show_scalar_bar=True,
    scalar_bar_args={
        'title': 'Umag (m/s) ',
        'title_font_size': 16,
        'label_font_size': 14,
        'n_labels': 3,
        'position_x': 0.25,
        'color': 'black',
    },
    cmap='jet',
    clim=[min_val_U, max_val_U]
)
pl.add_text("ROM", position="lower_left", color='black', font_size=font_size)
pl.add_text(args.title, position="upper_edge", color='black', font_size=font_size)
pl.camera_position = camera_position
pl.camera.zoom(zoom)

pl.subplot(0, 2)
pl.add_mesh(
    truth_grid.copy(),
    scalars='diff_U',
    show_scalar_bar=True,
    scalar_bar_args={
        'title': 'Umag (m/s)  ',
        'title_font_size': 16,
        'label_font_size': 14,
        'n_labels': 3,
        'position_x': 0.25,
        'color': 'black',
    },
    cmap='jet'
)
pl.add_text("Error", position="lower_left", color='black', font_size=font_size)
pl.camera_position = camera_position
pl.camera.zoom(zoom)

pl.subplot(1, 0)
pl.add_mesh(
    truth_grid.copy(),
    scalars='p',
    show_scalar_bar=True,
    scalar_bar_args={
        'title': 'p (m\u00b2/s\u00b2)',
        'title_font_size': 16,
        'label_font_size': 14,
        'n_labels': 3,
        'position_x': 0.25,
        'color': 'black',
    },
    cmap='jet',
    clim=[min_val_p, max_val_p]
)
pl.add_text("CFD", position="lower_left", color='black', font_size=font_size)
pl.camera_position = camera_position
pl.camera.zoom(zoom)

pl.subplot(1, 1)
pl.add_mesh(
    ml_grid.copy(),
    scalars='p',
    show_scalar_bar=True,
    scalar_bar_args={
        'title': 'p (m\u00b2/s\u00b2) ',
        'title_font_size': 16,
        'label_font_size': 14,
        'n_labels': 3,
        'position_x': 0.25,
        'color': 'black',
    },
    cmap='jet',
    clim=[min_val_p, max_val_p]
)
pl.add_text("ROM", position="lower_left", color='black', font_size=font_size)
pl.camera_position = camera_position
pl.camera.zoom(zoom)

pl.subplot(1, 2)
pl.add_mesh(
    truth_grid.copy(),
    scalars='diff_p',
    show_scalar_bar=True,
    scalar_bar_args={
        'title': 'p (m\u00b2/s\u00b2)  ',
        'title_font_size': 16,
        'label_font_size': 14,
        'n_labels': 3,
        'position_x': 0.25,
        'color': 'black',
    },
    cmap='jet'
)
pl.add_text("Error", position="lower_left", color='black', font_size=font_size)
pl.camera_position = camera_position
pl.camera.zoom(zoom)

pl.background_color = 'white'

if pv.OFF_SCREEN:
  image = pl.screenshot(args.png)
else:
  pl.show()
