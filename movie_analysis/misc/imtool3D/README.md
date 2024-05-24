This is an image viewer designed to view a 3D stack of image slices. For example, if you load into matlab a DICOM series of CT images, you can visualizethe images easily using this tool. It lets you scroll through slices, adjust the window and level, make ROI measurements, and export images into standard image formats (e.g., .png, .jpg, or .tif). This tool is written using the object-oriented features of matlab. This means that you can treat the tool like any graphics object and it can easily be embedded into any figure. So if you're designing a GUI in which you need the user to visualize and scroll tthrough image slices, you don't need to write all the code for that! Its already done in this tool! Just create an imtool3D object and put it in your GUI figure. This tool requires the image processing toolbox to work.

Each .m file in the repository defines a new class (inhereted from the handle class, see http://www.mathworks.com/help/matlab/ref/handle-class.html). The main class is imtool3D.m and all other classes simply support imtool3D. The methods and properties of the imtool3D class is well described in its .m file. 

Written by Justin Solomon
10/23/15
