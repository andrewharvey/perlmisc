
/**
* This file is part of libface.
*
* libface is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* libface is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with libface.  If not, see <http://www.gnu.org/licenses/>.
*
* This is a simple example of the use of the libface library.
* It implements face detection and recognition and uses the opencv libraries.
* @note: libface does not require users to have openCV knowledge, so here, openCV is treated as a "3rd-party" library for image manipulation convenience.
* @author: Aditya Bhatt, Alex Jironkin
*
* Modified by Andrew Harvey, to save face rectangle coordinates rather than draw a rectangle on the image.
* Original file from http://libface.svn.sourceforge.net/viewvc/libface/examples/FaceDetection.cpp?revision=116&view=markup
* Once OpenCV and libface are installed you should be able to compile with
* g++ -Wall -O2 -I /usr/local/include -L /usr/local/lib -lface -lhighgui -lcv -lcxcore -lcvaux -o DetectFaces -rdynamic -Wl,-rpath,/usr/local/lib DetectFaces.cpp
* Rectangle coordinates are saved to inputfilename.txt one rectangle per line as X1,Y1,X2,Y2
*
*/

#include <iostream>
#include <vector>
#include <fstream>
#include <string>

#include <math.h>

#include <libface/LibFace.h>
#include <libface/Face.h>	// Our library


// Extra libraries for use in client programs
#include<opencv/cv.h>
#include<opencv/highgui.h>

using namespace std;

//Use namespace libface in the library.
using namespace libface;

int main(int argc, char **argv) {

    if (argc<2)
    {
        cout << "Bad Args!!!\nUsage: " << argv[0] << " <image1> <image2> ..." << endl;
        return 0;
    }


    libface::Mode mode;
    mode = libface::DETECT;
    LibFace *libFace = new LibFace(mode, ".");

    int i;
    unsigned int j;
    IplImage *img;
    vector<Face> result;
    for (i = 1; i < argc; ++i)
    {
        // Load input image
        cout<<"Loading image "<<argv[i]<<endl;
        img = cvLoadImage(argv[1], CV_LOAD_IMAGE_GRAYSCALE);
	
        // We can give the filename to this function too, but a better method is the one done below, in which raw image data is passed
        result = libFace->detectFaces(img->imageData,img->width, img->height, img->widthStep, img->depth, img->nChannels);
        //cout<<" detected"<<endl;

        //Open a new file for the image to save face details to
        ofstream file;

        string imagefilename (argv[i]);
        string filename;
        filename = imagefilename + ".txt";
        
        file.open(filename.c_str());
        
        for (j = 0; j < result.size(); ++j)	// Save details of face location to file
        {
            Face* face = &result.at(j);
            file << face->getX1() << "," << face->getY1() << ","
                 << face->getX2() << "," << face->getY2()
                 << endl;
                 
            //cvRectangle( img, cvPoint(face->getX1(), face->getY1())
            //             , cvPoint(face->getX2(), face->getY2())
            //             , CV_RGB(255,0,0), 3, 2, 0);
        }

        file.close();

        result.clear();
    }

    return 0;
}


