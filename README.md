## Description ##
A code to generate an unique .png image of a series of random walks constrained to a box. 
Each walker is required to stay within the box region and cannot walk on locations 
previously walked by other walkers. This allows for clear separation of colors in the 
resulting image. Each walk is uniquely colored based on an input colormap, and therefore 
generates an aesthetically pleasing image. The Gradient version requires walkers to start
on the left hand side of image as room allows. This creates a gradient of color from left
to right.


Default image

<img src="images/Random_walk_art.png" height=500/>

Gradient image

<img src="images/Random_walk_art_gradient.png" height=500/>

## Installation ##

To install with Unix:
```
cd <install_dir>
git clone https://github.com/kjdoore/Random_Walk_Art.git
```


## Generating an Image ##

To run the code to generate an default image, enter the following into a MATLAB command line:
```
addpath('<install_dir>/Random_Walk_Art/')
random_walk_art
```
or for the gradient version
```
addpath('<install_dir>/Random_Walk_Art/')
random_walk_art_gradient
```

The following dialog box will open for inputs to be entered.

<img src="images/dialog_box.png" height=400/>

1. `Enter size of box region (x, y)`: two numbers separated by a comma or space. These 
respective values give the x and y dimensions of the box that the walkers are constrained. 
The larger the box is, the more area the walkers have and longer they will walk.
**NOTE**: If this value is exceedingly large (total area > 250,000), then the code may take 
several minutes to generate the image. 

2. `Enter colormap name`: the name of the colormap to use for each walker. A list of native
colormaps can be found [here](https://www.mathworks.com/help/matlab/ref/colormap.html). User
defined colormaps can also be used if they are defined before running.

3. `Invert color map (y or n)`: Inverts the colormap. Colors at the start of the colormap
will likely cover larger areas of the image due to the walkers not being constrained by
previous walkers.

4. `Enter line thickness`: the thickness of the line to use for each walker. Values larger
than the default of 1 will result in thicker lines. Smaller values result in thinner lines.

5. `Background color as normalized RGB triplet`: a normalized (max value of 1) RGB triplet
containing the color of the background. Values must be separated by a space or comma.

6. `Path of directory to save image`: the path to the directory that the image will be 
saved.

7. `Resolution of image in dpi`: the resolution of the .png image in dpi (dots per inch). 
High values will result in high resolution images.

