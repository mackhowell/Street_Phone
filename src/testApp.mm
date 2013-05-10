#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){
    ofEnableAlphaBlending();
	ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_PORTRAIT);
	
	finder.setup("haarcascade_frontalface_default.xml");
	
	//#ifdef USE_CAMERA
    ofSetFrameRate(30);
    grabber.setDesiredFrameRate(3);
    grabber.setDeviceID(2);
    grabber.initGrabber(480, 360);
    
    
    int w = grabber.getWidth();
    int h = grabber.getHeight();
    
    
    //we use different settings for the camera
    //so we can get a good frame rate
    colorCv.allocate(w,h);
    colorCvSmall.allocate(w/4, h/4);
    grayCv.allocate(w/4, h/4);
    
    finder.setNeighbors(1);
    finder.setScaleHaar(1.5);
	//#else
    //img.loadImage("test.jpg");
	//#endif
    
    //emoji stuff
    ofBackground(255);
    
    
    ofDirectory dir;
    
    int nFiles = dir.listDir("emojis");
    if(nFiles) {
        
        for(int i=0; i<dir.numFiles(); i++) {
            
            // add the image to the vector
            string filePath = dir.getPath(i);
            images.push_back(ofImage());
            images.back().loadImage(filePath);
        }
    }
    
    
    // this toggle will tell the sequence
    // be be indepent of the app fps
    bFrameIndependent = true;
    
    // this will set the speed to play
    // the animation back we set the
    // default to 24fps
    sequenceFPS = 24;
    
    // set the app fps
    appFPS = 60;
    ofSetFrameRate(appFPS);
    
}

//--------------------------------------------------------------
void testApp::update(){
	
	//#ifdef USE_CAMERA
    grabber.update();
    colorCv = grabber.getPixels();
    colorCvSmall.scaleIntoMe(colorCv, CV_INTER_NN);
    grayCv = colorCvSmall;
    finder.findHaarObjects(grayCv);
    faces = finder.blobs;
	//#else
    //we don't really need to do this every frame
    //but it simulates closer what the camera demo would be doing
    //finder.findHaarObjects(img);
	//#endif
    
	cout << " found " << faces.size() << endl;
	
}

//--------------------------------------------------------------
void testApp::draw(){
    
    
	//--------face detection----------
	ofSetColor(255);
	float scaleFactor = 1.0;
    //grabber.draw(0, 0);
    scaleFactor = 4.0;
	
	ofPushStyle();
    ofNoFill();
    ofSetColor(255, 0, 255);
    for(int k = 0; k < faces.size(); k++){
        ofRectangle rect(faces[k].boundingRect.x * scaleFactor, faces[k].boundingRect.y * scaleFactor, faces[k].boundingRect.width * scaleFactor, faces[k].boundingRect.width * scaleFactor);
        //ofRect(rect);
        
//some bounding box info
//        ofSetColor(50);
//        ofRect(0, 0, 200, 200);
//        ofSetColor(200);
//        string info;
//        info += ofToString(faces[k].boundingRect.width)+" BOUNDING WIDTH\n";
//        ofDrawBitmapString(info, 15, 20);

    }
	ofPopStyle();
    
    
    
    // -------emogis!----------
    // we need some images if not return
    if((int)images.size() <= 0) {
        ofSetColor(255);
        ofDrawBitmapString("No Images...", 150, ofGetHeight()/2);
        return;
    }
    
    // this is the total time of the animation based on fps
    //float totalTime = images.size() / sequenceFPS;
    
    int frameIndex = 0;
    
    if(bFrameIndependent) {
        // calculate the frame index based on the app time
        // and the desired sequence fps. then mod to wrap
        frameIndex = (int)(ofGetElapsedTimef() * sequenceFPS) % images.size();
    }
    else {
        // set the frame index based on the app frame
        // count. then mod to wrap.
        frameIndex = ofGetFrameNum() % images.size();
    }
    
//    // DRAW the image sequence at the new frame count
//    ofSetColor(255);
//    images[frameIndex].draw(ofGetWidth()/4,ofGetHeight()/3);
    
    
    
    //    // how fast is the app running and some other info
    //    ofSetColor(50);
    //    ofRect(0, 0, 200, 200);
    //    ofSetColor(200);
    //    string info;
    //    info += ofToString(frameIndex)+" sequence index\n";
    //    info += ofToString(appFPS)+"/"+ofToString(ofGetFrameRate(), 0)+" fps\n";
    //    info += ofToString(sequenceFPS)+" Sequence fps\n\n";
    //    info += "Keys:\nup & down arrows to\nchange app fps\n\n";
    //    info += "left & right arrows to\nchange sequence fps";
    //    info += "\n\n't' to toggle\nframe independent("+ofToString(bFrameIndependent)+")";
    //    
    //    ofDrawBitmapString(info, 15, 20);
    
    
    //-----draw random emoji when face is detected
    int randomEmoji;
    randomEmoji = ofRandom(images.size());
    
    if (faces.size() >= 1){
//        images[ofRandom(images.size())].draw(ofGetWidth()/4,ofGetHeight()/3);
        images[randomEmoji].draw(ofGetWidth()/4,ofGetHeight()/3);
        for(int k = 0; k < faces.size(); k++){
            newFrameRate = ofMap(faces[k].boundingRect.width,2, 50, 1, 2);
        }
        ofSetFrameRate(newFrameRate);
    }
    else {
        ofBackground(255);
    }
    
    
    
    //-----capture screen when a face stays for > 10 seconds
    if (faces.size() < 1){
        time = ofGetElapsedTimef();
    }
    else {
        if(ofGetElapsedTimef() - time > 4){
            grabber.draw(0, 0);
            ofPushStyle();
            ofNoFill();
            ofSetColor(255, 0, 255);
            for(int k = 0; k < faces.size(); k++){
                ofRectangle rect(faces[k].boundingRect.x * scaleFactor, faces[k].boundingRect.y * scaleFactor, faces[k].boundingRect.width * scaleFactor, faces[k].boundingRect.width * scaleFactor);
                //ofRect(rect);
            }
            ofPopStyle();
            //delegate to save images in photos app
            ofxiPhoneAppDelegate * delegate = ofxiPhoneGetAppDelegate();
            ofxiPhoneScreenGrab(delegate);
        }
        if(ofGetElapsedTimef() - time > 5){
            ofBackground(255);
        }
    }
}

//--------------------------------------------------------------
void testApp::exit(){
    
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs& touch){
    
}

//--------------------------------------------------------------
void testApp::lostFocus(){
    
}

//--------------------------------------------------------------
void testApp::gotFocus(){
    
}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){
    
}

